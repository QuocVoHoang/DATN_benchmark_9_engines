source /Users/vohoangquoc/emsdk/emsdk_env.sh
./run_benchmark.sh

# Nếu chưa có phiên bản Emscripten:
cd /Users/vohoangquoc/emsdk
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh