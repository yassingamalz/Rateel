// Audio features for the Muaalem model: a Dart port of transformers' SeamlessM4TFeatureExtractor
// (80 kaldi mel bins, povey window 400, hop 160, FFT 512, pre-emphasis 0.97, DC offset removal,
// log mel, per-mel-bin normalisation, frames stacked by 2 -> 160 values per frame).
// The window and the mel filter bank are the extractor's own arrays (assets/window.f32, mel.f32).
import 'dart:math' as math;
import 'dart:typed_data';

const int sampleRate = 16000;
const int _frameLength = 400;
const int _hop = 160;
const int _fftLength = 512;
const int _bins = _fftLength ~/ 2 + 1; // 257
const int melBins = 80;
const int stride = 2;
const double _melFloor = 1.192092955078125e-07;
const double _padValue = 1.0; // preprocessor_config.json "padding_value"

class Wav {
  final Float32List samples; // mono, [-1, 1)
  final int rate;
  Wav(this.samples, this.rate);
  double get seconds => samples.length / rate;
}

/// Reads a RIFF/WAVE file with 16-bit PCM samples (any rate, mono or stereo: left channel kept).
Wav parseWav(Uint8List bytes) {
  final b = ByteData.sublistView(bytes);
  String tag(int o) => String.fromCharCodes(bytes.sublist(o, o + 4));
  if (bytes.length < 12 || tag(0) != 'RIFF' || tag(8) != 'WAVE') {
    throw const FormatException('not a WAV file');
  }
  int channels = 1, rate = sampleRate, bits = 16;
  int o = 12;
  while (o + 8 <= bytes.length) {
    final id = tag(o);
    var size = b.getUint32(o + 4, Endian.little);
    final body = o + 8;
    if (id == 'fmt ') {
      final format = b.getUint16(body, Endian.little);
      channels = b.getUint16(body + 2, Endian.little);
      rate = b.getUint32(body + 4, Endian.little);
      bits = b.getUint16(body + 14, Endian.little);
      if ((format != 1 && format != 0xFFFE) || bits != 16) {
        throw FormatException('only 16-bit PCM is supported (format $format, $bits bit)');
      }
    } else if (id == 'data') {
      // Some recorders write 0 or a too large size while recording: use what is there.
      if (size == 0 || body + size > bytes.length) size = bytes.length - body;
      final n = size ~/ (2 * channels);
      final out = Float32List(n);
      for (var i = 0; i < n; i++) {
        out[i] = b.getInt16(body + i * 2 * channels, Endian.little) / 32768.0;
      }
      return Wav(out, rate);
    }
    o = body + size + (size & 1);
  }
  throw const FormatException('no data chunk');
}

/// Linear resampling to 16 kHz (only used if the recorder did not honour 16 kHz).
Float32List resampleTo16k(Float32List x, int rate) {
  if (rate == sampleRate) return x;
  final n = (x.length * sampleRate / rate).floor();
  final out = Float32List(n);
  final step = rate / sampleRate;
  for (var i = 0; i < n; i++) {
    final p = i * step;
    final j = p.floor();
    final f = p - j;
    final a = x[j];
    final c = j + 1 < x.length ? x[j + 1] : a;
    out[i] = (a + (c - a) * f).toDouble();
  }
  return out;
}

class Features {
  final Float32List values; // [frames * 160]
  final Int32List mask; // [frames]
  final int frames;
  Features(this.values, this.mask, this.frames);
}

class _Fft {
  final int n;
  final Float64List cosT, sinT;
  final Int32List rev;
  _Fft(this.n)
      : cosT = Float64List(n ~/ 2),
        sinT = Float64List(n ~/ 2),
        rev = Int32List(n) {
    for (var i = 0; i < n ~/ 2; i++) {
      cosT[i] = math.cos(2 * math.pi * i / n);
      sinT[i] = -math.sin(2 * math.pi * i / n);
    }
    final bits = (math.log(n) / math.ln2).round();
    for (var i = 0; i < n; i++) {
      var r = 0, v = i;
      for (var k = 0; k < bits; k++) {
        r = (r << 1) | (v & 1);
        v >>= 1;
      }
      rev[i] = r;
    }
  }

  /// In-place complex FFT.
  void run(Float64List re, Float64List im) {
    for (var i = 0; i < n; i++) {
      final j = rev[i];
      if (j > i) {
        var t = re[i];
        re[i] = re[j];
        re[j] = t;
        t = im[i];
        im[i] = im[j];
        im[j] = t;
      }
    }
    for (var size = 2; size <= n; size <<= 1) {
      final half = size >> 1, step = n ~/ size;
      for (var start = 0; start < n; start += size) {
        for (var k = 0; k < half; k++) {
          final c = cosT[k * step], s = sinT[k * step];
          final a = start + k, b = a + half;
          final tr = re[b] * c - im[b] * s;
          final ti = re[b] * s + im[b] * c;
          re[b] = re[a] - tr;
          im[b] = im[a] - ti;
          re[a] += tr;
          im[a] += ti;
        }
      }
    }
  }
}

/// [window] 400 values, [mel] 257*80 values row-major [frequency][mel].
Features extractFeatures(Float32List wave16k, Float32List window, Float32List mel) {
  final n = wave16k.length;
  if (n < _frameLength) throw const FormatException('recording too short');
  final frames = 1 + (n - _frameLength) ~/ _hop;
  final fbank = Float64List(frames * melBins);
  final fft = _Fft(_fftLength);
  final re = Float64List(_fftLength), im = Float64List(_fftLength);
  final power = Float64List(_bins);
  for (var f = 0; f < frames; f++) {
    final t = f * _hop;
    var mean = 0.0;
    for (var i = 0; i < _frameLength; i++) {
      re[i] = wave16k[t + i] * 32768.0; // Kaldi compliance: 16-bit integer scale
      mean += re[i];
    }
    mean /= _frameLength;
    for (var i = 0; i < _frameLength; i++) {
      re[i] -= mean;
    }
    for (var i = _frameLength - 1; i >= 1; i--) {
      re[i] -= 0.97 * re[i - 1];
    }
    re[0] *= 1 - 0.97;
    for (var i = 0; i < _frameLength; i++) {
      re[i] *= window[i];
    }
    for (var i = _frameLength; i < _fftLength; i++) {
      re[i] = 0;
    }
    for (var i = 0; i < _fftLength; i++) {
      im[i] = 0;
    }
    fft.run(re, im);
    for (var k = 0; k < _bins; k++) {
      // the Python code keeps the spectrum as complex64: round to float32 like it does
      final r = _f32(re[k]), i = _f32(im[k]);
      power[k] = r * r + i * i;
    }
    for (var m = 0; m < melBins; m++) {
      var s = 0.0;
      for (var k = 0; k < _bins; k++) {
        s += mel[k * melBins + m] * power[k];
      }
      fbank[f * melBins + m] = math.log(s < _melFloor ? _melFloor : s);
    }
  }
  // per-mel-bin normalisation (variance with ddof = 1)
  for (var m = 0; m < melBins; m++) {
    var mean = 0.0;
    for (var f = 0; f < frames; f++) {
      mean += _f32(fbank[f * melBins + m]);
    }
    mean /= frames;
    var v = 0.0;
    for (var f = 0; f < frames; f++) {
      final d = _f32(fbank[f * melBins + m]) - mean;
      v += d * d;
    }
    v = frames > 1 ? v / (frames - 1) : 0.0;
    final sd = math.sqrt(v + 1e-7);
    for (var f = 0; f < frames; f++) {
      fbank[f * melBins + m] = (_f32(fbank[f * melBins + m]) - mean) / sd;
    }
  }
  // pad to a multiple of 2 frames, then stack pairs of frames
  final padded = frames.isOdd ? frames + 1 : frames;
  final out = Float32List(padded * melBins);
  for (var i = 0; i < frames * melBins; i++) {
    out[i] = fbank[i];
  }
  for (var i = frames * melBins; i < padded * melBins; i++) {
    out[i] = _padValue;
  }
  final stacked = padded ~/ stride;
  final mask = Int32List(stacked);
  for (var j = 0; j < stacked; j++) {
    mask[j] = (2 * j + 1) < frames ? 1 : 0; // attention_mask[:, 1::2]
  }
  return Features(out, mask, stacked); // [stacked, 160] is the same memory as [padded, 80]
}

final _f32buf = Float32List(1);
double _f32(double x) {
  _f32buf[0] = x;
  return _f32buf[0];
}
