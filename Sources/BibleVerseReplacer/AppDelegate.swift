import AppKit
import Foundation

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let preferences = UserPreferences.shared
    private let bibleStore = BibleStore.shared
    private let notifier = UserNotifier()
    private let hotKeyManager = HotKeyManager()
    private let updateChecker = UpdateChecker()
    private var isCheckingUpdates = false

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
            onCheckUpdates: { [weak self] in self?.checkForUpdates(interactive: true) },
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
        scheduleAutomaticUpdateCheckIfNeeded()
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

    private func scheduleAutomaticUpdateCheckIfNeeded() {
        guard preferences.autoCheckUpdates else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.checkForUpdates(interactive: false)
        }
    }

    private func checkForUpdates(interactive: Bool) {
        guard !isCheckingUpdates else {
            if interactive {
                notifier.notify("正在检查更新...")
            }
            return
        }

        isCheckingUpdates = true
        updateChecker.check { [weak self] result in
            DispatchQueue.main.async {
                guard let self else {
                    return
                }

                self.isCheckingUpdates = false
                switch result {
                case let .success(update):
                    self.handleUpdateCheck(update, interactive: interactive)
                case let .failure(error):
                    if interactive {
                        _ = self.notifier.alert(
                            title: "检查更新失败",
                            message: error.localizedDescription
                        )
                    }
                }
            }
        }
    }

    private func handleUpdateCheck(_ result: UpdateCheckResult, interactive: Bool) {
        if result.isUpdateAvailable {
            let openRelease = notifier.alert(
                title: "发现新版本 v\(result.latestVersion)",
                message: "当前版本：v\(result.currentVersion)\n是否打开下载页面？",
                primaryButton: "打开下载",
                secondaryButton: "稍后"
            )
            if openRelease {
                NSWorkspace.shared.open(result.releaseURL)
            }
            return
        }

        if interactive {
            _ = notifier.alert(
                title: "已经是最新版本",
                message: "当前版本：v\(result.currentVersion)"
            )
        }
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
