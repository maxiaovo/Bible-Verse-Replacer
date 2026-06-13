import Foundation

struct UpdateCheckResult {
    let currentVersion: String
    let latestVersion: String
    let releaseURL: URL
    let installerAssetURL: URL?
    let isUpdateAvailable: Bool
}

final class UpdateChecker {
    private struct GitHubAsset: Decodable {
        let name: String
        let downloadURL: URL

        enum CodingKeys: String, CodingKey {
            case name
            case downloadURL = "browser_download_url"
        }
    }

    private struct GitHubRelease: Decodable {
        let tagName: String
        let htmlURL: URL
        let assets: [GitHubAsset]

        enum CodingKeys: String, CodingKey {
            case tagName = "tag_name"
            case htmlURL = "html_url"
            case assets
        }
    }

    private let latestReleaseURL = URL(string: "https://api.github.com/repos/maxiaovo/Bible-Verse-Replacer/releases/latest")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func check(completion: @escaping (Result<UpdateCheckResult, Error>) -> Void) {
        var request = URLRequest(url: latestReleaseURL)
        request.setValue("BibleVerseReplacer", forHTTPHeaderField: "User-Agent")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        session.dataTask(with: request) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }

            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                completion(.failure(UpdateCheckError.badStatus(http.statusCode)))
                return
            }

            guard let data else {
                completion(.failure(UpdateCheckError.emptyResponse))
                return
            }

            do {
                let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
                let current = Self.currentVersion
                let latest = Self.normalizedVersion(release.tagName)
                let installerAssetURL = release.assets.first { asset in
                    asset.name == "BibleVerseReplacer-v\(latest).zip"
                }?.downloadURL
                completion(.success(UpdateCheckResult(
                    currentVersion: current,
                    latestVersion: latest,
                    releaseURL: release.htmlURL,
                    installerAssetURL: installerAssetURL,
                    isUpdateAvailable: Self.compareVersions(latest, current) == .orderedDescending
                )))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    static var currentVersion: String {
        AppInfo.version
    }

    private static func normalizedVersion(_ raw: String) -> String {
        raw.trimmingCharacters(in: CharacterSet(charactersIn: "vV").union(.whitespacesAndNewlines))
    }

    private static func compareVersions(_ lhs: String, _ rhs: String) -> ComparisonResult {
        let leftParts = versionParts(lhs)
        let rightParts = versionParts(rhs)
        let count = max(leftParts.count, rightParts.count)

        for index in 0..<count {
            let left = index < leftParts.count ? leftParts[index] : 0
            let right = index < rightParts.count ? rightParts[index] : 0
            if left < right {
                return .orderedAscending
            }
            if left > right {
                return .orderedDescending
            }
        }

        return .orderedSame
    }

    private static func versionParts(_ version: String) -> [Int] {
        version
            .split { !$0.isNumber }
            .map { Int($0) ?? 0 }
    }
}

enum UpdateCheckError: LocalizedError {
    case badStatus(Int)
    case emptyResponse

    var errorDescription: String? {
        switch self {
        case let .badStatus(status):
            return "更新检查失败，服务器返回 \(status)"
        case .emptyResponse:
            return "更新检查失败，服务器没有返回内容"
        }
    }
}
