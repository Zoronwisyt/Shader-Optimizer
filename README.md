# ⚡ Zoron Shader Optimizer (iOS Dylib & Framework)

High-performance Metal pipeline & shader acceleration dylib for **Alight Motion iOS**.

---

## 🚀 Features

- **Metal Runtime Shader Interception:** Intercepts `MTLLibrary.makeFunction(name:)` and dynamic render pipeline construction.
- **Half-Precision Vector Acceleration:** Replaces heavy 32-bit float calculations in blurs and blend modes with 16-bit `half4` SIMD vector mathematics.
- **Fast Separable Blur Kernel:** 9-tap separable Gaussian blur filter with unrolled loops and texture cache alignment for `alight_blurW` and `alight_blurH`.
- **Fast-Math & Compiler Optimizations:** Enables Apple Silicon hardware fast-math instructions (`-ffast-math`, `fma`).
- **Render Pipeline Pre-Warming:** Pre-compiles Metal pipeline states asynchronously on startup to eliminate timeline scrubbing stutter.
- **Interactive In-App HUD:** Glassmorphic floating dashboard with real-time toggles and shader logs.

---

## 📂 Project Structure

```text
Zoron_ShaderOptimizer_Swift_Project/
├── .github/workflows/
│   └── build-ios-framework.yml        # Automated GitHub Actions iOS arm64 build
├── Package.swift                      # SPM configuration (iOS 15+)
├── Sources/
│   └── ZoronShaderOptimizer/
│       ├── ZoronEntry.c               # C constructor auto-initializer
│       ├── ZoronShaderLoader.swift    # Lifecycle initializer
│       ├── ZoronShaderKernels.swift   # High-efficiency Metal shading sources
│       ├── ZoronMetalHookEngine.swift # Metal API swizzler & pipeline interceptor
│       ├── ZoronShaderPipelineCache.swift # Pre-warmer & state cache
│       ├── ZoronShaderGUIViewController.swift # Floating settings HUD
│       └── ZoronShaderOverlayWindow.swift     # Window overlay & gesture handler
└── README.md
```

---

## 🛠️ How to Build & Inject

### 1. Build via GitHub Actions (Recommended)
1. Push this project to your GitHub repository.
2. The workflow `.github/workflows/build-ios-framework.yml` will automatically build the iOS arm64 dynamic framework and `.dylib`.
3. Download the zipped `ZoronShaderOptimizer-iOS-Dylib` artifact from the GitHub Actions summary page.

### 2. Inject into Alight Motion IPA
- Use **Sideloadly**, **Scarlet**, **ESign**, **TrollStore**, or `optool` / `insert_dylib` to inject `ZoronShaderOptimizer.dylib` into the Alight Motion app bundle (`Payload/AlightMotion.app/Frameworks/`).
