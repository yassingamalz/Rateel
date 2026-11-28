// Download in parts with SHA-256 checks, against a local HTTP server (set LAB_PARTS_URL to run it).
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tajweed_core/model_store.dart';

void main() {
  final url = Platform.environment['LAB_PARTS_URL'];
  test('download parts, verify, join', () async {
    final store = ModelStore();
    await store.initAt(Directory.systemTemp.createTempSync('lab'));
    var last = 0;
    await store.download('$url/manifest.json', (d, t) => last = d);
    final digest = await sha256.bind(store.model.openRead()).first;
    // ignore: avoid_print
    print('downloaded ${store.model.lengthSync()} bytes, sha256 $digest');
    expect(await store.ready, isTrue);
    expect(last, store.model.lengthSync());
    expect(digest.toString(), Platform.environment['LAB_SHA']);
  }, skip: url == null ? 'LAB_PARTS_URL not set' : false, timeout: const Timeout(Duration(minutes: 10)));
}
