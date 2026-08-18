import Foundation
import Metal

/**
 * ZoronShaderPipelineCache - Pre-warms and caches Metal render pipelines
 * to eliminate frame drops and UI stutter when scrubbing the timeline in Alight Motion.
 */
public final class ZoronShaderPipelineCache: NSObject {

    public static let shared = ZoronShaderPipelineCache()

    private var pipelineCache: [String: MTLRenderPipelineState] = [:]
    private let cacheQueue = DispatchQueue(label: "com.zoron.shader.pipeline.cache", qos: .userInitiated)

    public private(set) var isPrewarmed: Bool = false

    private override init() {
        super.init()
    }

    /// Pre-warm render pipeline states in background thread
    public func prewarmPipelines() {
        guard !isPrewarmed else { return }

        guard let device = MTLCreateSystemDefaultDevice() else { return }

        cacheQueue.async { [weak self] in
            guard let self = self else { return }

            print("[ZoronShaderOptimizer] 🔥 Pre-warming Metal render pipeline states...")

            let compileOptions = MTLCompileOptions()
            compileOptions.fastMathEnabled = true

            guard let library = try? device.makeLibrary(source: ZoronShaderKernels.metalSourceCode, options: compileOptions) else {
                return
            }

            let kernelNames = [
                "zoron_fast_blur_w",
                "zoron_fast_blur_h",
                "zoron_multiply_fragment",
                "zoron_screen_fragment",
                "zoron_overlay_fragment",
                "zoron_effect_brightnessContrast_fragment"
            ]

            for name in kernelNames {
                if let function = library.makeFunction(name: name) {
                    let desc = MTLRenderPipelineDescriptor()
                    desc.fragmentFunction = function
                    desc.colorAttachments[0].pixelFormat = .bgra8Unorm
                    
                    if let pipelineState = try? device.makeRenderPipelineState(descriptor: desc) {
                        self.pipelineCache[name] = pipelineState
                    }
                }
            }

            self.isPrewarmed = true
            print("[ZoronShaderOptimizer] ✅ Pre-warmed \(self.pipelineCache.count) pipeline states successfully!")
        }
    }

    public func cachedPipeline(for name: String) -> MTLRenderPipelineState? {
        return pipelineCache[name]
    }
}
