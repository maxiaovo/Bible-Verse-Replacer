import Foundation
import ServiceManagement

enum LoginItemManager {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static var statusText: String {
        switch SMAppService.mainApp.status {
        case .enabled:
            return "已开启"
        case .notRegistered:
            return "未开启"
        case .requiresApproval:
            return "需要在系统设置中批准"
        case .notFound:
            return "当前 App 包不支持"
        @unknown default:
            return "未知"
        }
    }

    static func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    }
}

