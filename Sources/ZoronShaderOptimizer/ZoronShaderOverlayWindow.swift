import UIKit

/**
 * ZoronShaderOverlayWindow - Floating Action Button & Modal Overlay Window
 */
public final class ZoronShaderOverlayWindow: NSObject {

    public static let shared = ZoronShaderOverlayWindow()

    private var overlayWindow: UIWindow?
    private var floatingButton: UIButton?
    private var isMenuVisible = false
    private var guiVC: ZoronShaderGUIViewController?

    private override init() {
        super.init()
    }

    public func present(in scene: UIWindowScene) {
        guard overlayWindow == nil else { return }

        let window = UIWindow(windowScene: scene)
        window.windowLevel = .statusBar + 101 // High priority overlay
        window.backgroundColor = .clear
        window.isHidden = false

        let rootVC = UIViewController()
        rootVC.view.backgroundColor = .clear
        window.rootViewController = rootVC

        setupFloatingButton(in: rootVC.view)

        self.overlayWindow = window
    }

    private func setupFloatingButton(in parentView: UIView) {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 20, y: 160, width: 44, height: 44)
        button.layer.cornerRadius = 22
        button.backgroundColor = UIColor(red: 0.95, green: 0.45, blue: 0.1, alpha: 0.9)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.white.cgColor
        button.setTitle("⚡", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 6

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        button.addGestureRecognizer(pan)
        button.addTarget(self, action: #selector(didTapFloatingButton), for: .touchUpInside)

        parentView.addSubview(button)
        self.floatingButton = button
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let button = floatingButton, let superview = button.superview else { return }
        let translation = gesture.translation(in: superview)
        button.center = CGPoint(x: button.center.x + translation.x, y: button.center.y + translation.y)
        gesture.setTranslation(.zero, in: superview)
    }

    @objc private func didTapFloatingButton() {
        toggleMenu()
    }

    public func toggleMenu() {
        guard let rootVC = overlayWindow?.rootViewController else { return }

        if isMenuVisible {
            guiVC?.dismiss(animated: true) { [weak self] in
                self?.guiVC = nil
                self?.isMenuVisible = false
            }
        } else {
            let vc = ZoronShaderGUIViewController()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            rootVC.present(vc, animated: true) { [weak self] in
                self?.isMenuVisible = true
            }
            self.guiVC = vc
        }
    }
}
