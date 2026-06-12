import Carbon
import Foundation

final class HotKeyManager {
    static var activeManager: HotKeyManager?

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private var action: (() -> Void)?

    init() {
        Self.activeManager = self
        installHandlerIfNeeded()
    }

    deinit {
        unregister()
        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
        }
    }

    func register(shortcut: KeyboardShortcut, action: @escaping () -> Void) throws {
        unregister()
        self.action = action

        let hotKeyID = EventHotKeyID(signature: fourCharCode("BVR1"), id: 1)
        var nextRef: EventHotKeyRef?
        let status = RegisterEventHotKey(
            UInt32(shortcut.keyCode),
            UInt32(shortcut.carbonModifiers),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &nextRef
        )

        guard status == noErr, let nextRef else {
            throw NSError(
                domain: "BibleVerseReplacer.HotKeyManager",
                code: Int(status),
                userInfo: [NSLocalizedDescriptionKey: "快捷键注册失败，可能与其他应用冲突"]
            )
        }

        hotKeyRef = nextRef
    }

    func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
    }

    fileprivate func handleHotKeyEvent() {
        action?()
    }

    private func installHandlerIfNeeded() {
        guard eventHandlerRef == nil else {
            return
        }

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let callback: EventHandlerUPP = { _, event, _ in
            guard event != nil else {
                return noErr
            }
            HotKeyManager.activeManager?.handleHotKeyEvent()
            return noErr
        }

        InstallEventHandler(
            GetApplicationEventTarget(),
            callback,
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )
    }

    private func fourCharCode(_ string: String) -> OSType {
        var result: OSType = 0
        for scalar in string.unicodeScalars.prefix(4) {
            result = (result << 8) + OSType(scalar.value)
        }
        return result
    }
}
