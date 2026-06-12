import AppKit
import Foundation

final class ShortcutRecorderButton: NSButton {
    var onShortcutRecorded: ((KeyboardShortcut) -> Void)?

    private var originalShortcut: KeyboardShortcut
    private var eventMonitor: Any?
    private var isRecording = false

    init(shortcut: KeyboardShortcut) {
        originalShortcut = shortcut
        super.init(frame: .zero)
        title = shortcut.displayString
        bezelStyle = .rounded
        setButtonType(.momentaryPushIn)
        toolTip = "点击后按下新的全局快捷键"
    }

    required init?(coder: NSCoder) {
        originalShortcut = .defaultShortcut
        super.init(coder: coder)
    }

    override var acceptsFirstResponder: Bool {
        true
    }

    func update(shortcut: KeyboardShortcut) {
        guard !isRecording else {
            return
        }
        originalShortcut = shortcut
        title = shortcut.displayString
    }

    override func mouseDown(with event: NSEvent) {
        startRecording()
    }

    private func startRecording() {
        isRecording = true
        title = "请按新快捷键..."
        window?.makeFirstResponder(self)

        if eventMonitor != nil {
            NSEvent.removeMonitor(eventMonitor!)
        }

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyDown(event)
            return nil
        }
    }

    private func handleKeyDown(_ event: NSEvent) {
        if event.keyCode == 53 {
            stopRecording(useOriginalTitle: true)
            return
        }

        guard let shortcut = KeyboardShortcut.from(event: event) else {
            title = "请包含 ⌃/⌥/⇧/⌘"
            return
        }

        originalShortcut = shortcut
        onShortcutRecorded?(shortcut)
        stopRecording(useOriginalTitle: false)
    }

    private func stopRecording(useOriginalTitle: Bool) {
        isRecording = false
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }
        title = originalShortcut.displayString
        if useOriginalTitle {
            needsDisplay = true
        }
    }
}

