import AppKit
import Foundation

final class UpdateInstaller: NSObject {
    private let downloadURL: URL
    private let latestVersion: String
    private let notifier: UserNotifier
    private let completion: () -> Void

    private var session: URLSession?
    private var downloadTask: URLSessionDownloadTask?
    private var tempDirectory: URL?
    private var window: NSWindow?
    private var progressIndicator: NSProgressIndicator?
    private var statusLabel: NSTextField?

    init(downloadURL: URL, latestVersion: String, notifier: UserNotifier, completion: @escaping () -> Void) {
        self.downloadURL = downloadURL
        self.latestVersion = latestVersion
        self.notifier = notifier
        self.completion = completion
        super.init()
    }

    func start() {
        do {
            let temp = FileManager.default.temporaryDirectory
                .appendingPathComponent("BibleVerseReplacerUpdate-\(UUID().uuidString)", isDirectory: true)
            try FileManager.default.createDirectory(at: temp, withIntermediateDirectories: true)
            tempDirectory = temp
        } catch {
            showError(error)
            return
        }

        showProgressWindow()

        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["User-Agent": "BibleVerseReplacer"]
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
        downloadTask = session?.downloadTask(with: downloadURL)
        downloadTask?.resume()
    }

    private func showProgressWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 150),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        window.title = "正在更新"
        window.center()

        let title = NSTextField(labelWithString: "下载 v\(latestVersion)")
        title.font = .systemFont(ofSize: 16, weight: .semibold)
        title.translatesAutoresizingMaskIntoConstraints = false

        let status = NSTextField(labelWithString: "正在连接 GitHub Releases...")
        status.textColor = .secondaryLabelColor
        status.translatesAutoresizingMaskIntoConstraints = false

        let progress = NSProgressIndicator()
        progress.isIndeterminate = false
        progress.minValue = 0
        progress.maxValue = 100
        progress.doubleValue = 0
        progress.translatesAutoresizingMaskIntoConstraints = false

        let content = NSView()
        content.addSubview(title)
        content.addSubview(status)
        content.addSubview(progress)
        window.contentView = content

        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 24),
            title.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -24),
            title.topAnchor.constraint(equalTo: content.topAnchor, constant: 22),
            status.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            status.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            status.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 14),
            progress.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            progress.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            progress.topAnchor.constraint(equalTo: status.bottomAnchor, constant: 18)
        ])

        self.window = window
        self.statusLabel = status
        self.progressIndicator = progress
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    static func stageDownloadedFile(at location: URL, tempDirectory: URL) throws -> URL {
        let zipURL = tempDirectory.appendingPathComponent("update.zip")
        if FileManager.default.fileExists(atPath: zipURL.path) {
            try FileManager.default.removeItem(at: zipURL)
        }
        try FileManager.default.moveItem(at: location, to: zipURL)
        return zipURL
    }

    private func prepareAndInstall(fromStagedZip zipURL: URL) {
        guard let tempDirectory else {
            showError(UpdateInstallError.missingTempDirectory)
            return
        }

        DispatchQueue.main.async {
            self.statusLabel?.stringValue = "正在解压安装包..."
            self.progressIndicator?.doubleValue = 85
        }

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let extractDirectory = tempDirectory.appendingPathComponent("extracted", isDirectory: true)
                try FileManager.default.createDirectory(at: extractDirectory, withIntermediateDirectories: true)
                try Self.run("/usr/bin/ditto", arguments: ["-x", "-k", zipURL.path, extractDirectory.path])

                guard let newAppURL = Self.findExtractedApp(in: extractDirectory) else {
                    throw UpdateInstallError.appNotFound
                }

                DispatchQueue.main.async {
                    self.statusLabel?.stringValue = "正在准备替换并重启..."
                    self.progressIndicator?.doubleValue = 95
                }

                let currentAppURL = Bundle.main.bundleURL
                try self.launchReplacementScript(newAppURL: newAppURL, currentAppURL: currentAppURL, tempDirectory: tempDirectory)
                DispatchQueue.main.async {
                    self.completion()
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError(error)
                }
            }
        }
    }

    private func launchReplacementScript(newAppURL: URL, currentAppURL: URL, tempDirectory: URL) throws {
        let scriptURL = tempDirectory.appendingPathComponent("install-update.sh")
        let script = """
        #!/bin/sh
        APP_PATH=\(currentAppURL.path.shellQuoted)
        NEW_APP=\(newAppURL.path.shellQuoted)
        TEMP_DIR=\(tempDirectory.path.shellQuoted)

        sleep 1
        while /usr/bin/pgrep -x "BibleVerseReplacer" >/dev/null 2>&1; do
          sleep 0.2
        done

        /bin/rm -rf "$APP_PATH"
        /usr/bin/ditto "$NEW_APP" "$APP_PATH"
        /usr/bin/xattr -dr com.apple.quarantine "$APP_PATH" >/dev/null 2>&1 || true
        /usr/bin/open "$APP_PATH"
        /bin/rm -rf "$TEMP_DIR"
        """

        try script.write(to: scriptURL, atomically: true, encoding: .utf8)
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: scriptURL.path)

        let appParent = currentAppURL.deletingLastPathComponent()
        if FileManager.default.isWritableFile(atPath: appParent.path) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/sh")
            process.arguments = [scriptURL.path]
            try process.run()
        } else {
            let command = "/bin/sh \(scriptURL.path.shellQuoted) >/dev/null 2>&1 &"
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            process.arguments = ["-e", "do shell script \(command.appleScriptQuoted) with administrator privileges"]
            try process.run()
            process.waitUntilExit()
            if process.terminationStatus != 0 {
                throw UpdateInstallError.commandFailed("/usr/bin/osascript", process.terminationStatus)
            }
        }
    }

    private func showError(_ error: Error) {
        window?.close()
        cleanupTempDirectory()
        _ = notifier.alert(
            title: "自动更新失败",
            message: "\(error.localizedDescription)\n\n可以先手动打开 Release 页面下载最新版。",
            primaryButton: "好"
        )
    }

    private func cleanupTempDirectory() {
        if let tempDirectory, FileManager.default.fileExists(atPath: tempDirectory.path) {
            try? FileManager.default.removeItem(at: tempDirectory)
        }
    }

    private static func run(_ executable: String, arguments: [String]) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        try process.run()
        process.waitUntilExit()
        if process.terminationStatus != 0 {
            throw UpdateInstallError.commandFailed(executable, process.terminationStatus)
        }
    }

    private static func findExtractedApp(in directory: URL) -> URL? {
        if let direct = try? FileManager.default.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        ).first(where: { $0.lastPathComponent == "BibleVerseReplacer.app" }) {
            return direct
        }

        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return nil
        }

        for case let url as URL in enumerator where url.lastPathComponent == "BibleVerseReplacer.app" {
            return url
        }
        return nil
    }
}

extension UpdateInstaller: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            guard let tempDirectory else {
                throw UpdateInstallError.missingTempDirectory
            }
            let zipURL = try Self.stageDownloadedFile(at: location, tempDirectory: tempDirectory)
            prepareAndInstall(fromStagedZip: zipURL)
        } catch {
            DispatchQueue.main.async {
                self.showError(error)
            }
        }
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard totalBytesExpectedToWrite > 0 else {
            return
        }

        let percent = min(80, Double(totalBytesWritten) / Double(totalBytesExpectedToWrite) * 80)
        DispatchQueue.main.async {
            self.progressIndicator?.doubleValue = percent
            self.statusLabel?.stringValue = "正在下载... \(Int(percent / 80 * 100))%"
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error {
            DispatchQueue.main.async {
                self.showError(error)
            }
        }
    }
}

private enum UpdateInstallError: LocalizedError {
    case missingTempDirectory
    case appNotFound
    case commandFailed(String, Int32)

    var errorDescription: String? {
        switch self {
        case .missingTempDirectory:
            return "没有可用的临时目录。"
        case .appNotFound:
            return "安装包中没有找到 BibleVerseReplacer.app。"
        case let .commandFailed(command, status):
            return "\(command) 执行失败，退出码 \(status)。"
        }
    }
}

private extension String {
    var shellQuoted: String {
        "'\(replacingOccurrences(of: "'", with: "'\\''"))'"
    }

    var appleScriptQuoted: String {
        "\"\(replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\""))\""
    }
}
