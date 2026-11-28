# ONNX Runtime calls these classes from native code (JNI): keep them whole.
-keep class ai.onnxruntime.** { *; }
