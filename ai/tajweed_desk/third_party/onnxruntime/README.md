# onnxruntime (vendored, modified)

Copy of the pub package `onnxruntime` 1.4.1 by gtbluesky (MIT, see LICENSE), used by the desktop test app.
Changes (Rateel, 2026-11-28):
- the bundled ONNX Runtime 1.15.1 binaries are replaced by the official Microsoft ONNX Runtime 1.32.0, downloaded
  from NuGet at build time with a SHA-256 check (`ort_fetch.cmake`): 1.15.1 cannot run the int8 Muaalem model
  (`ConvInteger` with int8 weights);
- the model path is passed as UTF-16 on Windows (ORTCHAR_T is wchar_t there; the original passed UTF-8 and ONNX Runtime
  could not find the file);
- only the Linux and Windows platforms are kept; on Linux the library is loaded as `libonnxruntime.so`.
The Dart API (C API version 14) is unchanged.
