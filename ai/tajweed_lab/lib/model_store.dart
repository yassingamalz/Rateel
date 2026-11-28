// Where the int8 ONNX model lives on the phone, and how it gets there:
// - download: a manifest.json with the parts of the file (each < 30 MB), checked with SHA-256,
//   appended in order to the model file (resumes after the last complete part);
// - import: a file chosen on the phone (copied into the app's storage).
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

/// Default place of the parts: a GitHub release of the Rateel repository (to be created by the owner).
const defaultManifestUrl =
    'https://github.com/yassingamalz/Rateel/releases/download/tajweed-lab-model-v1/manifest.json';

class ModelStore {
  late final Directory dir;
  File get model => File('${dir.path}/muaalem-v3_2-int8.onnx');
  File get _progress => File('${dir.path}/download-progress.json');

  Future<void> init() async {
    final base = await getApplicationSupportDirectory();
    await initAt(Directory('${base.path}/model'));
  }

  /// Also used by the tests.
  Future<void> initAt(Directory d) async {
    dir = d;
    await dir.create(recursive: true);
  }

  Future<bool> get ready async => await model.exists() && !await _progress.exists();

  Future<int> get size async => await model.exists() ? await model.length() : 0;

  Future<void> delete() async {
    if (await model.exists()) await model.delete();
    if (await _progress.exists()) await _progress.delete();
  }

  /// Downloads the model described by [manifestUrl]. [onProgress] gets (bytes done, total bytes).
  Future<void> download(String manifestUrl, void Function(int done, int total) onProgress) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 30);
    try {
      final manifest = jsonDecode(utf8.decode(await _get(client, Uri.parse(manifestUrl)))) as Map<String, dynamic>;
      final parts = (manifest['parts'] as List).cast<Map<String, dynamic>>();
      final total = (manifest['size'] as num).toInt();
      var done = 0;
      // resume: keep only complete, verified parts
      var completed = 0;
      if (await _progress.exists() && await model.exists()) {
        completed = (jsonDecode(await _progress.readAsString()) as Map)['parts'] as int;
      } else if (await model.exists()) {
        await model.delete();
      }
      for (var k = 0; k < completed; k++) {
        done += (parts[k]['size'] as num).toInt();
      }
      final raf = await model.open(mode: FileMode.append);
      await raf.truncate(done);
      await raf.setPosition(done);
      await _progress.writeAsString(jsonEncode({'parts': completed}));
      for (var k = completed; k < parts.length; k++) {
        final p = parts[k];
        final url = Uri.parse(manifestUrl).resolve(p['name'] as String);
        final bytes = await _get(client, url, onChunk: (n) => onProgress(done + n, total));
        if (bytes.length != (p['size'] as num).toInt() || sha256.convert(bytes).toString() != p['sha256']) {
          throw Exception('part ${p['name']} is damaged (size or SHA-256): retry');
        }
        await raf.writeFrom(bytes);
        await raf.flush();
        done += bytes.length;
        await _progress.writeAsString(jsonEncode({'parts': k + 1}));
        onProgress(done, total);
      }
      await raf.close();
      await _progress.delete();
    } finally {
      client.close(force: true);
    }
  }

  Future<List<int>> _get(HttpClient c, Uri url, {void Function(int)? onChunk}) async {
    final req = await c.getUrl(url);
    final res = await req.close();
    if (res.statusCode != 200) throw HttpException('HTTP ${res.statusCode} for $url');
    final out = BytesBuilder(copy: false);
    await for (final chunk in res) {
      out.add(chunk);
      onChunk?.call(out.length);
    }
    return out.takeBytes();
  }

  /// Copies a model file chosen on the phone.
  Future<void> importFrom(String path) async {
    if (await _progress.exists()) await _progress.delete();
    await File(path).copy(model.path);
  }
}
