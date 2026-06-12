import AppKit
import Foundation

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let preferences = UserPreferences.shared
    private let bibleStore = BibleStore.shared
    private let notifier = UserNotifier()
    private let hotKeyManager = HotKeyManager()

    private lazy var replacementCoordinator = ReplacementCoordinator(
        bibleStore: bibleStore,
        preferences: preferences,
        notifier: notifier
    )

    private var statusBarController: StatusBarController?
    private var settingsWindowController: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        do {
            try bibleStore.load()
        } catch {
            let shouldQuit = notifier.alert(
                title: "经文库加载失败",
                message: error.localizedDescription,
                primaryButton: "退出"
            )
            if shouldQuit {
                NSApp.terminate(nil)
            }
            return
        }

        statusBarController = StatusBarController(
            onReplace: { [weak self] in self?.replaceSelectedText() },
            onSettings: { [weak self] in self?.showSettings() },
            onQuit: { NSApp.terminate(nil) }
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(preferencesDidChange),
            name: UserPreferences.didChangeNotification,
            object: nil
        )

        registerCurrentHotKey()
        guideAccessibilityPermissionIfNeeded()
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotKeyManager.unregister()
    }

    private func replaceSelectedText() {
        replacementCoordinator.replaceSelection()
    }

    private func showSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController(notifier: notifier)
        }
        settingsWindowController?.show()
    }

    private func registerCurrentHotKey() {
        do {
            try hotKeyManager.register(shortcut: preferences.shortcut) { [weak self] in
                DispatchQueue.main.async {
                    self?.replaceSelectedText()
                }
            }
        } catch {
            notifier.notify(error.localizedDescription)
        }
        statusBarController?.refresh()
    }

    private func guideAccessibilityPermissionIfNeeded() {
        guard !PermissionManager.isAccessibilityTrusted else {
            return
        }

        PermissionManager.requestAccessibilityPrompt()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self, !PermissionManager.isAccessibilityTrusted else {
                return
            }

            let openSettings = self.notifier.alert(
                title: "需要辅助功能权限",
                message: "经文替换需要模拟复制和粘贴。请在系统设置的“隐私与安全性 > 辅助功能”中允许 BibleVerseReplacer。",
                primaryButton: "打开系统设置",
                secondaryButton: "稍后"
            )
            if openSettings {
                PermissionManager.openAccessibilitySettings()
            }
        }
    }

    @objc private func preferencesDidChange() {
        registerCurrentHotKey()
        settingsWindowController?.refresh()
        statusBarController?.refresh()
    }
}

