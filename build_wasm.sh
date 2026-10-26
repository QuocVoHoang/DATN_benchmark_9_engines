#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; mkdir -p "$ROOT/build"
EMCC="${EMCC:-$(command -v emcc || true)}"; [[ -n "$EMCC" ]] || { echo 'emcc not found; source emsdk_env.sh' >&2; exit 1; }
common=(-O3 -s WASM=1 -s ALLOW_MEMORY_GROWTH=1 -s MODULARIZE=1 -s EXPORT_ES6=1 -s ENVIRONMENT=web -s EXPORTED_FUNCTIONS='["_malloc","_free","_processMotion","_resetMotionDetector","_getChangedPixelCount","_getOutput","_setThreadCount","_getThreadCount"]' -s EXPORTED_RUNTIME_METHODS='["HEAPU8"]')
"$EMCC" "$ROOT/cpp/motion_detection.cpp" "${common[@]}" -fno-vectorize -fno-slp-vectorize -s EXPORT_NAME=createWasmScalar -o "$ROOT/build/wasm_scalar.js"
"$EMCC" "$ROOT/cpp/motion_detection.cpp" "${common[@]}" -msimd128 -s EXPORT_NAME=createWasmSimd -o "$ROOT/build/wasm_simd.js"
"$EMCC" "$ROOT/cpp/motion_detection.cpp" "${common[@]}" -fno-vectorize -fno-slp-vectorize -pthread -s PTHREAD_POOL_SIZE=4 --post-js "$ROOT/pthread_cleanup.js" -s EXPORT_NAME=createWasmPthread -o "$ROOT/build/wasm_pthread.js"
"$EMCC" "$ROOT/cpp/motion_detection.cpp" "${common[@]}" -msimd128 -pthread -s PTHREAD_POOL_SIZE=4 --post-js "$ROOT/pthread_cleanup.js" -s EXPORT_NAME=createWasmSimdPthread -o "$ROOT/build/wasm_simd_pthread.js"
echo 'Built four WebAssembly artifacts in build/'
