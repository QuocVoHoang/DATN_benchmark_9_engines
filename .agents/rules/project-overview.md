---
trigger: always_on
description: Project overview and file structure for the Unified 9-Engine WASM motion detection benchmark
---

# Project Overview

This is a **browser-based benchmark** comparing the performance of **9 execution engines (Vanilla JavaScript vs WebAssembly Scalar / SIMD / Pthreads / SIMD+Pthreads)** for real-time motion detection on 4K video.

## Tech Stack

- **Frontend**: Vanilla HTML/CSS/JS (ES6 modules, NO frameworks, NO build tools like Vite/Webpack)
- **WASM**: C++ compiled via Emscripten (`emcc`) into 4 WASM artifacts (`wasm_scalar`, `wasm_simd`, `wasm_pthread`, `wasm_simd_pthread`)
- **Server**: Python HTTP server (`server.py` with COOP/COEP headers for `SharedArrayBuffer`)
- **Browser APIs**: Canvas 2D, Video (`requestVideoFrameCallback`), Performance API

## File Structure

| File | Role |
|---|---|
| `index.html` | Official 9-engine benchmark UI |
| `diagnostic/index.html` | Single-engine diagnostic UI |
| `js/app.js` | Official 9-engine benchmark orchestrator, FPS/latency measurement, JSON/CSV export |
| `js/diagnostic.js` | Single-engine diagnostic runner |
| `js/js_scalar_engine.js` | Pure JavaScript (`JsScalarEngine`) implementation of motion detection algorithm |
| `js/stats.js` | Statistical utilities: mean, P50, P95, P99 |
| `cpp/motion_detection.cpp` | Unified C++ implementation (compiled to 4 WASM variants via Emscripten) |
| `pthread_cleanup.js` | Post-JS hook to terminate Emscripten pthread worker pool cleanly |
| `build_wasm.sh` | Build script: compiles `cpp/motion_detection.cpp` into 4 WASM artifacts in `build/` |
| `run_benchmark.sh` | Builds WASM and starts `server.py` |

## Motion Detection Algorithm (shared across all 9 engines)

1. **Grayscale conversion**: RGBA → luminance using fixed-point integer approximation `(77*R + 150*G + 29*B) >> 8`
2. **Box blur**: Separable 2-pass (`blurH` + `blurV`) with $O(1)$ sliding window, 7×7 kernel (radius = 3, area = 49)
3. **Frame differencing**: Compare current blurred frame vs previous (`|curr - prev| > threshold`, default threshold = 30), using 128-bit SIMD in SIMD builds

## Key Conventions

- All 9 engines (JS and WASM variants) MUST use the **exact same algorithm** for fair comparison
- Generated files in `build/` (`wasm_*.js`, `wasm_*.wasm`, `wasm_*.worker.js`) are build artifacts — do not edit manually
