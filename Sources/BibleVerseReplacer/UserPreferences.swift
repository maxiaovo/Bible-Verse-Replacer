import Foundation

final class UserPreferences {
    static let shared = UserPreferences()
    static let didChangeNotification = Notification.Name("BibleVerseReplacer.UserPreferences.didChange")

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let outputFormat = "outputFormat"
        static let referenceLabelMode = "referenceLabelMode"
        static let combinedPassageMode = "combinedPassageMode"
        static let shortcut = "shortcut"
    }

    var outputFormat: OutputFormat {
        get {
            guard let raw = defaults.string(forKey: Keys.outputFormat),
                  let value = OutputFormat(rawValue: raw) else {
                return .referenceVerseLines
            }
            return value
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.outputFormat)
            notifyChanged()
        }
    }

    var referenceLabelMode: ReferenceLabelMode {
        get {
            guard let raw = defaults.string(forKey: Keys.referenceLabelMode),
                  let value = ReferenceLabelMode(rawValue: raw) else {
                return .normalizedFull
            }
            return value
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.referenceLabelMode)
            notifyChanged()
        }
    }

    var combinedPassageMode: CombinedPassageMode {
        get {
            guard let raw = defaults.string(forKey: Keys.combinedPassageMode),
                  let value = CombinedPassageMode(rawValue: raw) else {
                return .compactEllipsis
            }
            return value
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.combinedPassageMode)
            notifyChanged()
        }
    }

    var shortcut: KeyboardShortcut {
        get {
            guard let data = defaults.data(forKey: Keys.shortcut),
                  let shortcut = try? JSONDecoder().decode(KeyboardShortcut.self, from: data) else {
                return .defaultShortcut
            }
            return shortcut
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Keys.shortcut)
            }
            notifyChanged()
        }
    }

    private func notifyChanged() {
        NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
    }
}
