import Foundation

final class UserPreferences {
    static let shared = UserPreferences()
    static let didChangeNotification = Notification.Name("BibleVerseReplacer.UserPreferences.didChange")

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let outputFormat = "outputFormat"
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

