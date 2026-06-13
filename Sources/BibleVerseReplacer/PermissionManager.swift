import AppKit
import ApplicationServices
import Foundation

enum PermissionManager {
    static var isAccessibilityTrusted: Bool {
        AXIsProcessTrusted()
    }

    @discardableResult
    static func requestAccessibilityPrompt() -> Bool {
        let promptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [promptKey: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    static func repairAccessibilityPermission() {
        if !isAccessibilityTrusted {
            resetAccessibilityPermission()
        }
        _ = requestAccessibilityPrompt()
        openAccessibilitySettings()
    }

    private static func resetAccessibilityPermission() {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return
        }

        // Ad-hoc signed builds get a new cdhash after updates, leaving stale TCC rows behind.
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/tccutil")
        process.arguments = ["reset", "Accessibility", bundleIdentifier]
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return
        }
    }

    static func openAccessibilitySettings() {
        let modernURL = URL(string: "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_Accessibility")
        let legacyURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")

        if let modernURL, NSWorkspace.shared.open(modernURL) {
            return
        }
        if let legacyURL {
            NSWorkspace.shared.open(legacyURL)
        }
    }
}
