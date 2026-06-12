import AppKit

if CommandLine.arguments.contains("--self-test") {
    exit(SelfTest.run())
}

private let appDelegate = AppDelegate()

let app = NSApplication.shared
app.delegate = appDelegate
app.run()
