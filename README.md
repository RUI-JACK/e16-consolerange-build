# E16ConsoleRange build

GitHub Actions build of **E16ConsoleRange.kext** (x86_64) for a Hackintosh on an Intel Arrow Lake-H laptop.

On Meteor/Arrow Lake the firmware lights the panel from stolen memory, which lies outside every PCI BAR of the iGPU.
Apple's `IOBootNDRV` only accepts a boot console inside the device's memory ranges, so `IONDRVFramebuffer` never
adopts the firmware screen and WindowServer has no display. E16ConsoleRange appends the console range to the iGPU's
device memory and declines, so `IONDRVFramebuffer` matches next. It depends only on IOPCIFamily and KPIs, so OpenCore
can inject it into the boot kernel collection (unlike framebuffer drivers that need IOGraphicsFamily).

- Source: `src/E16ConsoleRange/` copied unchanged from
  [taqieallah/ThinkPad-E16-ArrowLake-macOS](https://github.com/taqieallah/ThinkPad-E16-ArrowLake-macOS)
  at commit `422a3b044e55bc962f471740c872780e8f48c473`, BSD 2-Clause (see `LICENSE`, Copyright (c) 2026, taqieallah).
- Build flags follow watchthelight-labs/WTLNvidiaGfx `build/nvgfx/build_igpurange.sh` (intel-xe branch).
- The binary is in the workflow run's artifact `E16ConsoleRange-kext`. Not tested by its builder on every machine;
  use at your own risk. Boot-arg `-e16croff` turns it off.
