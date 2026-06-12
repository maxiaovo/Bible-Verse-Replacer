import AppKit
import Carbon
import Foundation

struct KeyboardShortcut: Codable, Equatable {
    let keyCode: UInt32
    let carbonModifiers: UInt32
    let displayKey: String

    static let defaultShortcut = KeyboardShortcut(
        keyCode: 11,
        carbonModifiers: UInt32(controlKey) | UInt32(optionKey) | UInt32(cmdKey),
        displayKey: "B"
    )

    var displayString: String {
        "\(modifierSymbols)\(displayKey)"
    }

    var modifierSymbols: String {
        var result = ""
        if carbonModifiers & UInt32(controlKey) != 0 {
            result += "⌃"
        }
        if carbonModifiers & UInt32(optionKey) != 0 {
            result += "⌥"
        }
        if carbonModifiers & UInt32(shiftKey) != 0 {
            result += "⇧"
        }
        if carbonModifiers & UInt32(cmdKey) != 0 {
            result += "⌘"
        }
        return result
    }

    static func from(event: NSEvent) -> KeyboardShortcut? {
        let modifiers = carbonModifiers(from: event.modifierFlags)
        guard modifiers != 0 else {
            return nil
        }

        let keyCode = UInt32(event.keyCode)
        let display = keyDisplayName(for: keyCode, event: event)
        guard !display.isEmpty else {
            return nil
        }

        return KeyboardShortcut(keyCode: keyCode, carbonModifiers: modifiers, displayKey: display)
    }

    static func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var result: UInt32 = 0
        if flags.contains(.command) {
            result |= UInt32(cmdKey)
        }
        if flags.contains(.option) {
            result |= UInt32(optionKey)
        }
        if flags.contains(.control) {
            result |= UInt32(controlKey)
        }
        if flags.contains(.shift) {
            result |= UInt32(shiftKey)
        }
        return result
    }

    private static func keyDisplayName(for keyCode: UInt32, event: NSEvent) -> String {
        if let mapped = keyCodeNames[keyCode] {
            return mapped
        }

        if let characters = event.charactersIgnoringModifiers?.uppercased(), let first = characters.first {
            return String(first)
        }

        return ""
    }

    private static let keyCodeNames: [UInt32: String] = [
        0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
        8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
        16: "Y", 17: "T", 31: "O", 32: "U", 34: "I", 35: "P", 37: "L",
        38: "J", 40: "K", 45: "N", 46: "M",
        18: "1", 19: "2", 20: "3", 21: "4", 23: "5", 22: "6", 26: "7",
        28: "8", 25: "9", 29: "0",
        36: "Return", 48: "Tab", 49: "Space", 51: "Delete", 53: "Esc",
        122: "F1", 120: "F2", 99: "F3", 118: "F4", 96: "F5", 97: "F6",
        98: "F7", 100: "F8", 101: "F9", 109: "F10", 103: "F11", 111: "F12"
    ]
}

