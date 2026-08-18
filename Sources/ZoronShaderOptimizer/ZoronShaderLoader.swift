import UIKit

/**
 * ZoronShaderLoader - Auto-initializing entrypoint hook for Shader Optimizer
 */
public final class ZoronShaderLoader: NSObject {

    @objc public static let shared: ZoronShaderLoader = {
        let instance = ZoronShaderLoader()
        instance.setup()
        return instance
    }()

    private var retryTimer: Timer?

    private override init() {
        super.init()
    }

    private func setup() {
        // Enable Metal Hooks & Prewarm Cache
        ZoronMetalHookEngine.shared.enableMetalHooks()
        ZoronShaderPipelineCache.shared.prewarmPipelines()

        // Schedule floating HUD presentation
        DispatchQueue.main.async {
            self.retryTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] timer in
                let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
                let activeScene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first

                if let scene = activeScene {
                    ZoronShaderOverlayWindow.shared.present(in: scene)
                    self?.showSuccessAlert(in: scene)
                    timer.invalidate()
                }
            }
        }
    }

    private func showSuccessAlert(in scene: UIWindowScene) {
        if let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            let alert = UIAlertController(
                title: "⚡ Zoron Shader Optimizer Active",
                message: "Metal Fast-Math & Shader Pipeline Cache injected into Alight Motion!",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Awesome!", style: .default))
            root.present(alert, animated: true)
        }
    }
}

// C-Bridge function called by the C constructor in ZoronEntry.c
@_cdecl("zoron_shader_opt_swift_entry")
public func zoron_shader_opt_swift_entry() {
    _ = ZoronShaderLoader.shared
}
