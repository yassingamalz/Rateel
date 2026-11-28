// The model on the PC: ONNX Runtime 1.15.1 (package `onnxruntime`, FFI, bundled for Linux and Windows)
// running in its own isolate, so the window never freezes while the model works.
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:onnxruntime/onnxruntime.dart';

class EngineResult {
  final Float32List logits; // [frames * classes] of the phonemes head
  final int frames, classes, ms;
  EngineResult(this.logits, this.frames, this.classes, this.ms);
}

class Engine {
  Isolate? _isolate;
  SendPort? _port;
  int _nextId = 0;
  final _pending = <int, Completer<Object?>>{};
  ReceivePort? _rx;

  bool get loaded => _port != null;

  /// Loads the model (returns the load time in ms).
  Future<int> load(String modelPath, {int threads = 4}) async {
    await close();
    final rx = ReceivePort();
    _rx = rx;
    final ready = Completer<Object?>();
    rx.listen((msg) {
      if (msg is SendPort) {
        _port = msg;
      } else if (msg is List && msg.length == 2 && msg[0] == 'loaded') {
        ready.complete(msg[1]);
      } else if (msg is List && msg[0] == 'error' && !ready.isCompleted) {
        ready.completeError(Exception(msg[1]));
      } else if (msg is List && msg.length == 3) {
        final c = _pending.remove(msg[0] as int);
        if (msg[1] == 'ok') {
          c?.complete(msg[2]);
        } else {
          c?.completeError(Exception(msg[2]));
        }
      }
    });
    _isolate = await Isolate.spawn(_main, [rx.sendPort, modelPath, threads]);
    final ms = await ready.future;
    return ms as int;
  }

  Future<EngineResult> run(Float32List features, Int32List mask) async {
    final port = _port;
    if (port == null) throw StateError('model not loaded');
    final id = _nextId++;
    final c = Completer<Object?>();
    _pending[id] = c;
    port.send([id, TransferableTypedData.fromList([features]), TransferableTypedData.fromList([mask])]);
    final r = await c.future as List;
    return EngineResult(
        (r[0] as TransferableTypedData).materialize().asFloat32List(), r[1] as int, r[2] as int, r[3] as int);
  }

  Future<void> close() async {
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _port = null;
    _rx?.close();
    _rx = null;
    for (final c in _pending.values) {
      c.completeError(StateError('engine closed'));
    }
    _pending.clear();
  }
}

void _main(List args) {
  final out = args[0] as SendPort;
  final path = args[1] as String;
  final threads = args[2] as int;
  final rx = ReceivePort();
  OrtSession session;
  try {
    final sw = Stopwatch()..start();
    OrtEnv.instance.init();
    final opts = OrtSessionOptions()..setIntraOpNumThreads(threads);
    session = OrtSession.fromFile(File(path), opts);
    out.send(rx.sendPort);
    out.send(['loaded', sw.elapsedMilliseconds]);
  } catch (e) {
    out.send(['error', '$e']);
    return;
  }
  final runOptions = OrtRunOptions();
  rx.listen((msg) {
    final m = msg as List;
    final id = m[0] as int;
    try {
      final features = (m[1] as TransferableTypedData).materialize().asFloat32List();
      final mask = (m[2] as TransferableTypedData).materialize().asInt32List();
      final frames = mask.length;
      final sw = Stopwatch()..start();
      final x = OrtValueTensor.createTensorWithDataList(features, [1, frames, 160]);
      final a = OrtValueTensor.createTensorWithDataList(mask, [1, frames]);
      final outs = session.run(runOptions, {'input_features': x, 'attention_mask': a}, ['phonemes']);
      final v = outs[0]!.value as List; // [1][T][C]
      final t = (v[0] as List).length;
      final c = ((v[0] as List)[0] as List).length;
      final flat = Float32List(t * c);
      var k = 0;
      for (final row in v[0] as List) {
        for (final e in row as List) {
          flat[k++] = (e as num).toDouble();
        }
      }
      x.release();
      a.release();
      for (final o in outs) {
        o?.release();
      }
      out.send([id, 'ok', [TransferableTypedData.fromList([flat]), t, c, sw.elapsedMilliseconds]]);
    } catch (e) {
      out.send([id, 'error', '$e']);
    }
  });
}
