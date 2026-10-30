---
trigger: always_on
description: WASM build conventions and Emscripten configuration
---

# WASM Build Conventions

## Build Command

All WASM artifacts are built via `./build_wasm.sh` from the unified source `cpp/motion_detection.cpp`. Never edit generated files in `build/` manually.

## Generated Artifacts (`build/`)

`./build_wasm.sh` compiles `cpp/motion_detection.cpp` with `-O3` into 4 modularized ES6 factories:

| Artifact | Flags | Engine Configurations |
|---|---|---|
| `build/wasm_scalar.js` | `-O3 -fno-vectorize -fno-slp-vectorize` | `wasm-scalar` |
| `build/wasm_simd.js` | `-O3 -msimd128` | `wasm-simd` |
| `build/wasm_pthread.js` | `-O3 -fno-vectorize -fno-slp-vectorize -pthread -s PTHREAD_POOL_SIZE=4` | `wasm-pthread-1`, `wasm-pthread-2`, `wasm-pthread-4` |
| `build/wasm_simd_pthread.js` | `-O3 -msimd128 -pthread -s PTHREAD_POOL_SIZE=4` | `wasm-simd-pthread-1`, `wasm-simd-pthread-2`, `wasm-simd-pthread-4` |

## Exported Functions

Every C++ function called from JS must be listed in `EXPORTED_FUNCTIONS`:

| Export | Purpose |
|---|---|
| `_malloc` | Allocate WASM heap memory for input pixel data |
| `_free` | Free allocated memory after processing |
| `_processMotion` | Main motion detection entry point |
| `_resetMotionDetector` | Clear previous frame state |
| `_getChangedPixelCount` | Get motion pixel count after processing |
| `_getOutput` | Get pointer to output RGBA motion buffer |
| `_setThreadCount` | Configure active worker threads (1, 2, or 4) |
| `_getThreadCount` | Query active worker threads |

## Runtime Methods

`EXPORTED_RUNTIME_METHODS` must include:
- `HEAPU8` — for reading/writing pixel data to WASM linear memory
