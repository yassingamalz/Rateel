cmake_minimum_required(VERSION 3.18)
set(PROJECT_NAME "onnxruntime")
project(${PROJECT_NAME} LANGUAGES CXX)
set(ORT_RID "win-x64")
include("${CMAKE_CURRENT_SOURCE_DIR}/../ort_fetch.cmake")
set(onnxruntime_bundled_libraries
  "${ORT_DIR}/runtimes/win-x64/native/onnxruntime.dll"
  "${ORT_DIR}/runtimes/win-x64/native/onnxruntime_providers_shared.dll"
  PARENT_SCOPE
)
