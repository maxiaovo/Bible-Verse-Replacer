import Foundation

final class ReplacementCoordinator {
    private let clipboard = ClipboardService()
    private let parser = ReferenceParser()
    private let formatter = VerseFormatter()
    private let bibleStore: BibleStore
    private let preferences: UserPreferences
    private let notifier: UserNotifier

    init(
        bibleStore: BibleStore = .shared,
        preferences: UserPreferences = .shared,
        notifier: UserNotifier
    ) {
        self.bibleStore = bibleStore
        self.preferences = preferences
        self.notifier = notifier
    }

    func replaceSelection() {
        guard PermissionManager.isAccessibilityTrusted else {
            PermissionManager.requestAccessibilityPrompt()
            notifier.notify("需要在系统设置中允许辅助功能权限")
            return
        }

        let originalClipboard = clipboard.snapshot()

        guard let selectedText = clipboard.copySelectedText(), !selectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            clipboard.restore(originalClipboard)
            notifier.notify("没有选中文字")
            return
        }

        do {
            let reference = try parser.parseSelection(selectedText)
            let verses = try bibleStore.verses(for: reference)
            let replacement = formatter.format(
                parsedReference: reference,
                verses: verses,
                format: preferences.outputFormat,
                labelMode: preferences.referenceLabelMode,
                originalReference: selectedText
            )
            clipboard.paste(replacement)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.clipboard.restore(originalClipboard)
            }
        } catch {
            clipboard.restore(originalClipboard)
            notifier.notify(error.localizedDescription)
        }
    }
}
