import UIKit

/**
 * ZoronShaderGUIViewController - Metal Shader Optimizer Dashboard
 */
public class ZoronShaderGUIViewController: UIViewController {

    private let blurCard = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let closeButton = UIButton(type: .system)

    private let fastMathRow = UIView()
    private let fastMathLabel = UILabel()
    private let fastMathSwitch = UISwitch()

    private let blurOptRow = UIView()
    private let blurOptLabel = UILabel()
    private let blurOptSwitch = UISwitch()

    private let blendOptRow = UIView()
    private let blendOptLabel = UILabel()
    private let blendOptSwitch = UISwitch()

    private let prewarmButton = UIButton(type: .system)
    private let logsTextView = UITextView()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addLog("Zoron Shader Optimization Engine Ready")
        if ZoronMetalHookEngine.shared.isHooked {
            addLog("Metal Device & Shaders Hooked")
        }
    }

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)

        blurCard.layer.cornerRadius = 24
        blurCard.clipsToBounds = true
        blurCard.layer.borderWidth = 1.0
        blurCard.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        blurCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurCard)

        let content = blurCard.contentView

        titleLabel.text = "⚡ ZORON SHADER OPTIMIZER"
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .black)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(titleLabel)

        subtitleLabel.text = "Metal Fast-Math & Pipeline Pre-Warmer"
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.textColor = UIColor(white: 0.75, alpha: 1.0)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(subtitleLabel)

        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(closeButton)

        // Switch Rows
        setupToggleRow(row: fastMathRow, label: fastMathLabel, toggle: fastMathSwitch, title: "🚀 Fast-Math & Half4 SIMD", isOn: ZoronMetalHookEngine.shared.isFastMathEnabled, action: #selector(didToggleFastMath), parent: content)
        setupToggleRow(row: blurOptRow, label: blurOptLabel, toggle: blurOptSwitch, title: "✨ Fast Separable Blur (W/H)", isOn: ZoronMetalHookEngine.shared.isSeparableBlurOptimized, action: #selector(didToggleBlurOpt), parent: content)
        setupToggleRow(row: blendOptRow, label: blendOptLabel, toggle: blendOptSwitch, title: "🎨 Fast Blend Modes", isOn: ZoronMetalHookEngine.shared.isBlendOptimized, action: #selector(didToggleBlendOpt), parent: content)

        prewarmButton.setTitle("🔥 Pre-Warm Render Pipelines", for: .normal)
        prewarmButton.backgroundColor = UIColor(red: 0.95, green: 0.45, blue: 0.1, alpha: 0.9)
        prewarmButton.setTitleColor(.white, for: .normal)
        prewarmButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        prewarmButton.layer.cornerRadius = 12
        prewarmButton.addTarget(self, action: #selector(didTapPrewarm), for: .touchUpInside)
        prewarmButton.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(prewarmButton)

        logsTextView.backgroundColor = UIColor(white: 0.1, alpha: 0.6)
        logsTextView.textColor = UIColor(red: 0.4, green: 0.9, blue: 1.0, alpha: 1.0)
        logsTextView.font = UIFont.monospacedSystemFont(ofSize: 10, weight: .bold)
        logsTextView.isEditable = false
        logsTextView.layer.cornerRadius = 12
        logsTextView.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(logsTextView)

        NSLayoutConstraint.activate([
            blurCard.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blurCard.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            blurCard.widthAnchor.constraint(equalToConstant: 340),
            blurCard.heightAnchor.constraint(equalToConstant: 490),

            titleLabel.topAnchor.constraint(equalTo: content.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),

            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),

            fastMathRow.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            fastMathRow.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
            fastMathRow.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
            fastMathRow.heightAnchor.constraint(equalToConstant: 36),

            blurOptRow.topAnchor.constraint(equalTo: fastMathRow.bottomAnchor, constant: 10),
            blurOptRow.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
            blurOptRow.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
            blurOptRow.heightAnchor.constraint(equalToConstant: 36),

            blendOptRow.topAnchor.constraint(equalTo: blurOptRow.bottomAnchor, constant: 10),
            blendOptRow.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
            blendOptRow.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
            blendOptRow.heightAnchor.constraint(equalToConstant: 36),

            prewarmButton.topAnchor.constraint(equalTo: blendOptRow.bottomAnchor, constant: 16),
            prewarmButton.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
            prewarmButton.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
            prewarmButton.heightAnchor.constraint(equalToConstant: 42),

            logsTextView.topAnchor.constraint(equalTo: prewarmButton.bottomAnchor, constant: 16),
            logsTextView.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 18),
            logsTextView.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -18),
            logsTextView.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -18)
        ])
    }

    private func setupToggleRow(row: UIView, label: UILabel, toggle: UISwitch, title: String, isOn: Bool, action: Selector, parent: UIView) {
        row.backgroundColor = UIColor(white: 0.15, alpha: 0.4)
        row.layer.cornerRadius = 8
        row.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(row)

        label.text = title
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(label)

        toggle.isOn = isOn
        toggle.onTintColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
        toggle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        toggle.addTarget(self, action: action, for: .valueChanged)
        toggle.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(toggle)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            toggle.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -6),
            toggle.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
    }

    @objc private func didToggleFastMath() {
        ZoronMetalHookEngine.shared.setFastMath(enabled: fastMathSwitch.isOn)
        addLog("Fast-Math: \(fastMathSwitch.isOn ? "ENABLED" : "DISABLED")")
    }

    @objc private func didToggleBlurOpt() {
        ZoronMetalHookEngine.shared.setBlurOptimization(enabled: blurOptSwitch.isOn)
        addLog("Fast Blur Pass: \(blurOptSwitch.isOn ? "ENABLED" : "DISABLED")")
    }

    @objc private func didToggleBlendOpt() {
        ZoronMetalHookEngine.shared.setBlendOptimization(enabled: blendOptSwitch.isOn)
        addLog("Fast Blend Modes: \(blendOptSwitch.isOn ? "ENABLED" : "DISABLED")")
    }

    @objc private func didTapPrewarm() {
        ZoronShaderPipelineCache.shared.prewarmPipelines()
        addLog("Pipelines Pre-Warming Triggered")
    }

    private func addLog(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let time = formatter.string(from: Date())

        let newLog = "[\(time)] \(message)\n"
        logsTextView.text = newLog + (logsTextView.text ?? "")
    }

    @objc private func didTapClose() {
        ZoronShaderOverlayWindow.shared.toggleMenu()
    }
}
