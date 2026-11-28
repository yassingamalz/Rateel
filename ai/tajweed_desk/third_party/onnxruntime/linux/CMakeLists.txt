cmake_minimum_required(VERSION 3.18)
set(PROJECT_NAME "onnxruntime")
project(${PROJECT_NAME} LANGUAGES CXX)
set(ORT_RID "linux-x64")
include("${CMAKE_CURRENT_SOURCE_DIR}/../ort_fetch.cmake")
set(onnxruntime_bundled_libraries
  "${ORT_DIR}/runtimes/linux-x64/native/libonnxruntime.so"
  PARENT_SCOPE
)
