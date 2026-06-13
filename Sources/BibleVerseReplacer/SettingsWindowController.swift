import AppKit
import Foundation

final class SettingsWindowController: NSWindowController {
    private let preferences: UserPreferences
    private let bibleStore: BibleStore
    private let notifier: UserNotifier

    private let shortcutButton: ShortcutRecorderButton
    private let outputPopup = NSPopUpButton(frame: .zero, pullsDown: false)
    private let referenceLabelPopup = NSPopUpButton(frame: .zero, pullsDown: false)
    private let combinedPassagePopup = NSPopUpButton(frame: .zero, pullsDown: false)
    private let quotationStylePopup = NSPopUpButton(frame: .zero, pullsDown: false)
    private let permissionStatusLabel = NSTextField(labelWithString: "")
    private let autoUpdateCheckbox = NSButton(checkboxWithTitle: "自动检查更新", target: nil, action: nil)
    private let loginItemCheckbox = NSButton(checkboxWithTitle: "开机自启动", target: nil, action: nil)
    private let loginStatusLabel = NSTextField(labelWithString: "")
    private let bibleInfoLabel = NSTextField(labelWithString: "")
    private let footerInfoLabel = NSTextField(labelWithString: "")
    private let repositoryInfoLabel = NSTextField(labelWithString: AppInfo.repositoryURLString)

    init(
        preferences: UserPreferences = .shared,
        bibleStore: BibleStore = .shared,
        notifier: UserNotifier
    ) {
        self.preferences = preferences
        self.bibleStore = bibleStore
        self.notifier = notifier
        self.shortcutButton = ShortcutRecorderButton(shortcut: preferences.shortcut)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 560),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "经文替换设置"
        window.center()

        super.init(window: window)
        setupContent()
        refresh()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        refresh()
        guard let window else {
            return
        }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func refresh() {
        shortcutButton.update(shortcut: preferences.shortcut)
        selectCurrentOutputFormat()
        selectCurrentReferenceLabelMode()
        selectCurrentCombinedPassageMode()
        selectCurrentQuotationStyle()
        permissionStatusLabel.stringValue = PermissionManager.isAccessibilityTrusted ? "辅助功能权限：已允许" : "辅助功能权限：未允许，可重新申请"
        autoUpdateCheckbox.state = preferences.autoCheckUpdates ? .on : .off
        loginItemCheckbox.state = LoginItemManager.isEnabled ? .on : .off
        loginStatusLabel.stringValue = "开机启动：\(LoginItemManager.statusText)"
        bibleInfoLabel.stringValue = "经文库：\(bibleStore.sourceSummary)"
        footerInfoLabel.stringValue = "作者：大侠请留步 · 版本：\(AppInfo.versionDisplay)"
    }

    private func setupContent() {
        guard let window else {
            return
        }

        let root = NSStackView()
        root.orientation = .vertical
        root.alignment = .leading
        root.spacing = 12
        root.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = NSTextField(labelWithString: "经文替换")
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)

        let subtitleLabel = NSTextField(labelWithString: "设置全局快捷键、输出格式和系统权限。")
        subtitleLabel.textColor = .secondaryLabelColor
        subtitleLabel.font = .systemFont(ofSize: 13)

        outputPopup.addItems(withTitles: OutputFormat.allCases.map(\.title))
        outputPopup.target = self
        outputPopup.action = #selector(outputFormatChanged)

        referenceLabelPopup.addItems(withTitles: ReferenceLabelMode.allCases.map(\.title))
        referenceLabelPopup.target = self
        referenceLabelPopup.action = #selector(referenceLabelModeChanged)

        combinedPassagePopup.addItems(withTitles: CombinedPassageMode.allCases.map(\.title))
        combinedPassagePopup.target = self
        combinedPassagePopup.action = #selector(combinedPassageModeChanged)

        quotationStylePopup.addItems(withTitles: QuotationStyle.allCases.map(\.title))
        quotationStylePopup.target = self
        quotationStylePopup.action = #selector(quotationStyleChanged)

        shortcutButton.onShortcutRecorded = { [weak self] shortcut in
            self?.preferences.shortcut = shortcut
        }

        let permissionButton = NSButton(title: "重新申请辅助功能权限", target: self, action: #selector(repairAccessibilityPermission))
        permissionButton.bezelStyle = .rounded

        loginItemCheckbox.target = self
        loginItemCheckbox.action = #selector(loginItemChanged)

        autoUpdateCheckbox.target = self
        autoUpdateCheckbox.action = #selector(autoUpdateChanged)

        let sourceButton = NSButton(title: "打开 eBible 来源页面", target: self, action: #selector(openSourcePage))
        sourceButton.bezelStyle = .rounded

        let repositoryButton = NSButton(title: "打开 GitHub 仓库", target: self, action: #selector(openRepository))
        repositoryButton.bezelStyle = .rounded

        footerInfoLabel.textColor = .secondaryLabelColor
        footerInfoLabel.font = .systemFont(ofSize: 12)

        repositoryInfoLabel.textColor = .secondaryLabelColor
        repositoryInfoLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        repositoryInfoLabel.lineBreakMode = .byTruncatingMiddle

        root.addArrangedSubview(titleLabel)
        root.addArrangedSubview(subtitleLabel)
        root.addArrangedSubview(separator())
        root.addArrangedSubview(row(label: "快捷键", view: shortcutButton))
        root.addArrangedSubview(row(label: "输出格式", view: outputPopup))
        root.addArrangedSubview(row(label: "引用标签", view: referenceLabelPopup))
        root.addArrangedSubview(row(label: "组合显示", view: combinedPassagePopup))
        root.addArrangedSubview(row(label: "引号样式", view: quotationStylePopup))
        root.addArrangedSubview(separator())
        root.addArrangedSubview(row(label: "权限", view: permissionStatusLabel))
        root.addArrangedSubview(permissionButton)
        root.addArrangedSubview(row(label: "更新", view: autoUpdateCheckbox))
        root.addArrangedSubview(row(label: "启动", view: loginItemCheckbox))
        root.addArrangedSubview(loginStatusLabel)
        root.addArrangedSubview(separator())
        root.addArrangedSubview(bibleInfoLabel)
        root.addArrangedSubview(sourceButton)
        root.addArrangedSubview(separator())
        root.addArrangedSubview(footerInfoLabel)
        root.addArrangedSubview(repositoryFooter(repositoryButton: repositoryButton))

        window.contentView = NSView()
        window.contentView?.addSubview(root)

        NSLayoutConstraint.activate([
            root.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor, constant: 28),
            root.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor, constant: -28),
            root.topAnchor.constraint(equalTo: window.contentView!.topAnchor, constant: 24),
            shortcutButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 160),
            outputPopup.widthAnchor.constraint(greaterThanOrEqualToConstant: 220),
            referenceLabelPopup.widthAnchor.constraint(greaterThanOrEqualToConstant: 220),
            combinedPassagePopup.widthAnchor.constraint(greaterThanOrEqualToConstant: 220),
            quotationStylePopup.widthAnchor.constraint(greaterThanOrEqualToConstant: 220)
        ])
    }

    private func row(label: String, view: NSView) -> NSView {
        let stack = NSStackView()
        stack.orientation = .horizontal
        stack.alignment = .centerY
        stack.spacing = 14

        let labelView = NSTextField(labelWithString: label)
        labelView.font = .systemFont(ofSize: 13, weight: .medium)
        labelView.textColor = .secondaryLabelColor
        labelView.widthAnchor.constraint(equalToConstant: 76).isActive = true

        stack.addArrangedSubview(labelView)
        stack.addArrangedSubview(view)
        return stack
    }

    private func repositoryFooter(repositoryButton: NSButton) -> NSView {
        let stack = NSStackView()
        stack.orientation = .horizontal
        stack.alignment = .centerY
        stack.spacing = 10
        stack.addArrangedSubview(repositoryInfoLabel)
        stack.addArrangedSubview(repositoryButton)
        repositoryInfoLabel.widthAnchor.constraint(equalToConstant: 430).isActive = true
        return stack
    }

    private func separator() -> NSView {
        let separator = NSBox()
        separator.boxType = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.widthAnchor.constraint(equalToConstant: 480).isActive = true
        return separator
    }

    private func selectCurrentOutputFormat() {
        let allCases = OutputFormat.allCases
        guard let index = allCases.firstIndex(of: preferences.outputFormat) else {
            return
        }
        outputPopup.selectItem(at: index)
    }

    private func selectCurrentReferenceLabelMode() {
        let allCases = ReferenceLabelMode.allCases
        guard let index = allCases.firstIndex(of: preferences.referenceLabelMode) else {
            return
        }
        referenceLabelPopup.selectItem(at: index)
    }

    private func selectCurrentCombinedPassageMode() {
        let allCases = CombinedPassageMode.allCases
        guard let index = allCases.firstIndex(of: preferences.combinedPassageMode) else {
            return
        }
        combinedPassagePopup.selectItem(at: index)
    }

    private func selectCurrentQuotationStyle() {
        let allCases = QuotationStyle.allCases
        guard let index = allCases.firstIndex(of: preferences.quotationStyle) else {
            return
        }
        quotationStylePopup.selectItem(at: index)
    }

    @objc private func outputFormatChanged() {
        let index = outputPopup.indexOfSelectedItem
        guard OutputFormat.allCases.indices.contains(index) else {
            return
        }
        preferences.outputFormat = OutputFormat.allCases[index]
    }

    @objc private func referenceLabelModeChanged() {
        let index = referenceLabelPopup.indexOfSelectedItem
        guard ReferenceLabelMode.allCases.indices.contains(index) else {
            return
        }
        preferences.referenceLabelMode = ReferenceLabelMode.allCases[index]
    }

    @objc private func combinedPassageModeChanged() {
        let index = combinedPassagePopup.indexOfSelectedItem
        guard CombinedPassageMode.allCases.indices.contains(index) else {
            return
        }
        preferences.combinedPassageMode = CombinedPassageMode.allCases[index]
    }

    @objc private func quotationStyleChanged() {
        let index = quotationStylePopup.indexOfSelectedItem
        guard QuotationStyle.allCases.indices.contains(index) else {
            return
        }
        preferences.quotationStyle = QuotationStyle.allCases[index]
    }

    @objc private func repairAccessibilityPermission() {
        PermissionManager.repairAccessibilityPermission()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.refresh()
        }
    }

    @objc private func loginItemChanged() {
        do {
            try LoginItemManager.setEnabled(loginItemCheckbox.state == .on)
        } catch {
            notifier.notify(error.localizedDescription)
        }
        refresh()
    }

    @objc private func autoUpdateChanged() {
        preferences.autoCheckUpdates = autoUpdateCheckbox.state == .on
    }

    @objc private func openSourcePage() {
        if let url = URL(string: "https://ebible.org/Scriptures/details.php?id=cmn-cu89s") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func openRepository() {
        NSWorkspace.shared.open(AppInfo.repositoryURL)
    }
}
