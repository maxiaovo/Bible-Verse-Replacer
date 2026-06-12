import AppKit
import Foundation
import UserNotifications

final class UserNotifier {
    func notify(_ message: String, title: String = "经文替换") {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                self.deliver(message, title: title)
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
                    if granted {
                        self.deliver(message, title: title)
                    } else {
                        NSSound.beep()
                    }
                }
            case .denied:
                NSSound.beep()
            @unknown default:
                NSSound.beep()
            }
        }
    }

    func alert(title: String, message: String, primaryButton: String = "好", secondaryButton: String? = nil) -> Bool {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: primaryButton)
        if let secondaryButton {
            alert.addButton(withTitle: secondaryButton)
        }

        return alert.runModal() == .alertFirstButtonReturn
    }

    private func deliver(_ message: String, title: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
