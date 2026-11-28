# Downloads the official ONNX Runtime 1.32.0 (Microsoft NuGet package) once per build tree and extracts
# the native library of the current platform. Replaces the 1.15.1 binaries of the original package,
# which cannot run the int8 Muaalem model (no ConvInteger with int8 weights).
set(ORT_VERSION "1.32.0")
set(ORT_URL "https://api.nuget.org/v3-flatcontainer/microsoft.ml.onnxruntime/${ORT_VERSION}/microsoft.ml.onnxruntime.${ORT_VERSION}.nupkg")
set(ORT_SHA256 "a9150bc2992cbbb6722070da9910e1ffa989a8bfc67bdd5bb8e745ca755641db")
set(ORT_DIR "${CMAKE_BINARY_DIR}/ort-${ORT_VERSION}")
set(ORT_PKG "${ORT_DIR}/ort.nupkg")
if(NOT EXISTS "${ORT_PKG}")
  message(STATUS "Downloading ONNX Runtime ${ORT_VERSION}")
  file(DOWNLOAD "${ORT_URL}" "${ORT_PKG}" EXPECTED_HASH SHA256=${ORT_SHA256} SHOW_PROGRESS TLS_VERIFY ON)
endif()
if(NOT EXISTS "${ORT_DIR}/runtimes/${ORT_RID}/native")
  file(ARCHIVE_EXTRACT INPUT "${ORT_PKG}" DESTINATION "${ORT_DIR}" PATTERNS "runtimes/${ORT_RID}/native/*" LICENSE ThirdPartyNotices.txt)
endif()
