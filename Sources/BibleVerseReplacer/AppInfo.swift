import Foundation

enum AppInfo {
    static let repositoryURLString = "https://github.com/maxiaovo/Bible-Verse-Replacer"
    static let repositoryURL = URL(string: repositoryURLString)!

    static var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
    }

    static var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
    }

    static var versionDisplay: String {
        "v\(version) (\(build))"
    }
}
