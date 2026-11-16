#!/bin/bash
# Builds E16ConsoleRange.kext (x86_64) from src/E16ConsoleRange with the macOS SDK's Kernel.framework.
# Flags follow watchthelight-labs/WTLNvidiaGfx build/nvgfx/build_igpurange.sh (intel-xe branch) for the same kind of kext.
set -euo pipefail
cd "$(dirname "$0")"
SDK=${SDKROOT:-$(xcrun --sdk macosx --show-sdk-path)}
K="$SDK/System/Library/Frameworks/Kernel.framework/Headers"
[ -d "$K" ] || { echo "STOP: no Kernel.framework headers in $SDK"; exit 1; }
SRC=src/E16ConsoleRange
OUT=out
rm -rf "$OUT"; mkdir -p "$OUT/E16ConsoleRange.kext/Contents/MacOS"
FLAGS=(-arch x86_64 -mmacosx-version-min=11.0 -fapple-kext -mkernel -nostdinc -isysroot "$SDK" -I"$K" -I"$SRC"
       -DKERNEL -DKERNEL_PRIVATE -DDRIVER_PRIVATE -DAPPLE -DNeXT
       -std=c++17 -fno-rtti -fno-exceptions -fno-builtin -fno-common -O2 -Wall -Wno-unused-parameter -g0
       -Wno-deprecated-declarations -Wno-inconsistent-missing-override -Wno-overloaded-virtual -Wno-unused-function -Wno-sign-conversion)
xcrun clang++ "${FLAGS[@]}" -c "$SRC/consolerange.cpp" -o "$OUT/consolerange.o"
xcrun clang++ -arch x86_64 -mmacosx-version-min=11.0 -fapple-kext -nostdlib -Xlinker -kext -lkmodc++ -lkmod -lcc_kext \
  "$OUT/consolerange.o" -o "$OUT/E16ConsoleRange.kext/Contents/MacOS/E16ConsoleRange"
cp "$SRC/Info.plist" "$OUT/E16ConsoleRange.kext/Contents/Info.plist"
plutil -lint "$OUT/E16ConsoleRange.kext/Contents/Info.plist"
BIN="$OUT/E16ConsoleRange.kext/Contents/MacOS/E16ConsoleRange"
echo "--- file";      file "$BIN"
echo "--- header";    otool -hv "$BIN"
echo "--- undefined"; nm -u "$BIN"
echo "--- kmod";      nm "$BIN" | grep -E "_kmod_info|_start|_stop" || true
echo "--- sha256";    shasum -a 256 "$BIN"
(cd "$OUT" && zip -qr E16ConsoleRange.kext.zip E16ConsoleRange.kext && shasum -a 256 E16ConsoleRange.kext.zip)
