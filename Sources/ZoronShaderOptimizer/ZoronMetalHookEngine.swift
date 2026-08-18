import Foundation
import Metal
import ObjectiveC.runtime

/**
 * ZoronMetalHookEngine - Dynamic Metal pipeline and shader interception engine
 */
public final class ZoronMetalHookEngine: NSObject {

    public static let shared = ZoronMetalHookEngine()

    public private(set) var isHooked: Bool = false
    public private(set) var isFastMathEnabled: Bool = true
    public private(set) var isSeparableBlurOptimized: Bool = true
    public private(set) var isBlendOptimized: Bool = true

    private var customLibrary: MTLLibrary?
    private var defaultDevice: MTLDevice?

    // Function mapping from Alight Motion's shader names to Zoron optimized versions
    private let functionMap: [String: String] = [
        "alight_blurW": "zoron_fast_blur_w",
        "alight_blurH": "zoron_fast_blur_h",
        "multiply_fragment": "zoron_multiply_fragment",
        "screen_fragment": "zoron_screen_fragment",
        "overlay_fragment": "zoron_overlay_fragment",
        "effect_brightnessContrast_fragment": "zoron_effect_brightnessContrast_fragment"
    ]

    private override init() {
        super.init()
    }

    public func enableMetalHooks() {
        guard !isHooked else { return }

        guard let device = MTLCreateSystemDefaultDevice() else {
            print("[ZoronShaderOptimizer] ⚠️ Metal is not supported on this device.")
            return
        }

        self.defaultDevice = device

        let compileOptions = MTLCompileOptions()
        compileOptions.fastMathEnabled = true

        do {
            self.customLibrary = try device.makeLibrary(source: ZoronShaderKernels.metalSourceCode, options: compileOptions)
            print("[ZoronShaderOptimizer] ✅ Custom Metal Library compiled successfully with fast-math!")
        } catch {
            print("[ZoronShaderOptimizer] ⚠️ Failed to compile custom Metal library: \(error.localizedDescription)")
        }

        swizzleMetalLibrary()
        self.isHooked = true
        print("[ZoronShaderOptimizer] 🚀 Metal shader hooks active.")
    }

    private func swizzleMetalLibrary() {
        // Find the internal implementation class for MTLLibrary on Apple Silicon
        guard let mtlLibraryClass = NSClassFromString("_MTLLibrary") ?? NSClassFromString("MTLLibrary") else {
            print("[ZoronShaderOptimizer] ℹ️ Standard Metal library swizzling fallback.")
            return
        }

        let originalSelector = #selector(MTLLibrary.makeFunction(name:))
        let swizzledSelector = #selector(NSObject.zoron_makeFunction(name:))

        if let originalMethod = class_getInstanceMethod(mtlLibraryClass, originalSelector),
           let swizzledMethod = class_getInstanceMethod(ZoronMetalHookEngine.self, swizzledSelector) {
            method_exchangeImplementations(originalMethod, swizzledMethod)
            print("[ZoronShaderOptimizer] 🔀 Hooked MTLLibrary makeFunction(name:)")
        }
    }

    public func getOptimizedFunction(named name: String) -> MTLFunction? {
        guard let customLib = self.customLibrary else { return nil }

        // Check if blur optimization is enabled
        if !isSeparableBlurOptimized && (name == "alight_blurW" || name == "alight_blurH") {
            return nil
        }

        // Check if blend optimization is enabled
        if !isBlendOptimized && (name.contains("multiply") || name.contains("screen") || name.contains("overlay")) {
            return nil
        }

        if let mappedName = functionMap[name] {
            return customLib.makeFunction(name: mappedName)
        }

        return nil
    }

    public func setFastMath(enabled: Bool) {
        self.isFastMathEnabled = enabled
    }

    public func setBlurOptimization(enabled: Bool) {
        self.isSeparableBlurOptimized = enabled
    }

    public func setBlendOptimization(enabled: Bool) {
        self.isBlendOptimized = enabled
    }
}

// MARK: - Swizzled Extension
extension NSObject {
    @objc func zoron_makeFunction(name: String) -> MTLFunction? {
        // If Zoron has an optimized version for this shader, return it
        if let optimized = ZoronMetalHookEngine.shared.getOptimizedFunction(named: name) {
            print("[ZoronShaderOptimizer] ⚡ Replaced shader '\(name)' with Zoron fast kernel!")
            return optimized
        }
        // Fall back to calling original makeFunction implementation
        return self.zoron_makeFunction(name: name)
    }
}
