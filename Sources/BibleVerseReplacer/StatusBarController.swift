import AppKit
import Foundation

final class StatusBarController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let onReplace: () -> Void
    private let onSettings: () -> Void
    private let onCheckUpdates: () -> Void
    private let onQuit: () -> Void

    init(
        onReplace: @escaping () -> Void,
        onSettings: @escaping () -> Void,
        onCheckUpdates: @escaping () -> Void,
        onQuit: @escaping () -> Void
    ) {
        self.onReplace = onReplace
        self.onSettings = onSettings
        self.onCheckUpdates = onCheckUpdates
        self.onQuit = onQuit
        super.init()
        configure()
    }

    func refresh() {
        statusItem.menu = buildMenu()
    }

    private func configure() {
        if let button = statusItem.button {
            button.title = "经"
            button.font = .systemFont(ofSize: 15, weight: .semibold)
            button.toolTip = "经文替换"
        }
        statusItem.menu = buildMenu()
    }

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()

        let replaceItem = NSMenuItem(title: "替换所选经文", action: #selector(replaceSelected), keyEquivalent: "")
        replaceItem.target = self
        menu.addItem(replaceItem)

        let shortcutItem = NSMenuItem(title: "当前快捷键：\(UserPreferences.shared.shortcut.displayString)", action: nil, keyEquivalent: "")
        shortcutItem.isEnabled = false
        menu.addItem(shortcutItem)

        let authorItem = NSMenuItem(title: "作者：大侠请留步", action: nil, keyEquivalent: "")
        authorItem.isEnabled = false
        menu.addItem(authorItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "设置...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        let permissionTitle = PermissionManager.isAccessibilityTrusted ? "辅助功能权限：已允许" : "辅助功能权限：未允许"
        let permissionItem = NSMenuItem(title: permissionTitle, action: #selector(openAccessibilitySettings), keyEquivalent: "")
        permissionItem.target = self
        menu.addItem(permissionItem)

        let sourceItem = NSMenuItem(title: "打开 eBible 来源页面", action: #selector(openSourcePage), keyEquivalent: "")
        sourceItem.target = self
        menu.addItem(sourceItem)

        let updateItem = NSMenuItem(title: "检查更新", action: #selector(checkUpdates), keyEquivalent: "")
        updateItem.target = self
        menu.addItem(updateItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    @objc private func replaceSelected() {
        onReplace()
    }

    @objc private func openSettings() {
        onSettings()
    }

    @objc private func openAccessibilitySettings() {
        PermissionManager.requestAccessibilityPrompt()
        PermissionManager.openAccessibilitySettings()
    }

    @objc private func openSourcePage() {
        if let url = URL(string: "https://ebible.org/Scriptures/details.php?id=cmn-cu89s") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func checkUpdates() {
        onCheckUpdates()
    }

    @objc private func quit() {
        onQuit()
    }
}
