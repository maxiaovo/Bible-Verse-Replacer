import AppKit
import Foundation

final class ClipboardService {
    private let pasteboard = NSPasteboard.general

    func copySelectedText() -> String? {
        let originalChangeCount = pasteboard.changeCount
        sendKey(keyCode: 8, flags: .maskCommand)
        return waitForStringChange(after: originalChangeCount)
    }

    func paste(_ text: String) {
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        sendKey(keyCode: 9, flags: .maskCommand)
    }

    func snapshot() -> [NSPasteboardItem] {
        guard let items = pasteboard.pasteboardItems else {
            return []
        }

        return items.map { item in
            let copy = NSPasteboardItem()
            for type in item.types {
                if let data = item.data(forType: type) {
                    copy.setData(data, forType: type)
                } else if let string = item.string(forType: type) {
                    copy.setString(string, forType: type)
                }
            }
            return copy
        }
    }

    func restore(_ items: [NSPasteboardItem]) {
        pasteboard.clearContents()
        if !items.isEmpty {
            pasteboard.writeObjects(items)
        }
    }

    private func waitForStringChange(after changeCount: Int) -> String? {
        let deadline = Date().addingTimeInterval(0.6)
        while Date() < deadline {
            if pasteboard.changeCount != changeCount, let copied = pasteboard.string(forType: .string) {
                return copied
            }
            Thread.sleep(forTimeInterval: 0.02)
        }

        return pasteboard.string(forType: .string)
    }

    private func sendKey(keyCode: CGKeyCode, flags: CGEventFlags) {
        let source = CGEventSource(stateID: .combinedSessionState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)
        keyDown?.flags = flags
        keyUp?.flags = flags
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
}

