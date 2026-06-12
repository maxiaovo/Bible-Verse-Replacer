import Foundation

final class BibleStore {
    static let shared = BibleStore()

    private(set) var payload: BiblePayload?
    private var verseMap: [VerseKey: BibleVerse] = [:]
    private var chapterKeys: Set<String> = []

    var displayName: String {
        payload?.displayName ?? "经文库未加载"
    }

    var sourceSummary: String {
        guard let payload else {
            return "未加载"
        }
        return "\(payload.displayName) · \(payload.id)"
    }

    func load() throws {
        let dataURL = try locateBibleData()
        let data = try Data(contentsOf: dataURL)
        let decoded = try JSONDecoder().decode(BiblePayload.self, from: data)

        var nextVerseMap: [VerseKey: BibleVerse] = [:]
        var nextChapterKeys: Set<String> = []
        for verse in decoded.verses {
            for verseNumber in verse.verse...verse.endVerse {
                nextVerseMap[VerseKey(book: verse.book, chapter: verse.chapter, verse: verseNumber)] = verse
            }
            nextChapterKeys.insert(chapterKey(book: verse.book, chapter: verse.chapter))
        }

        payload = decoded
        verseMap = nextVerseMap
        chapterKeys = nextChapterKeys
    }

    func verses(for reference: VerseReference) throws -> [BibleVerse] {
        if !chapterKeys.contains(chapterKey(book: reference.book.code, chapter: reference.chapter)) {
            throw VerseLookupError.chapterNotFound(book: reference.book.chineseName, chapter: reference.chapter)
        }

        var result: [BibleVerse] = []
        var seen: Set<String> = []
        for verseNumber in reference.startVerse...reference.endVerse {
            let key = VerseKey(book: reference.book.code, chapter: reference.chapter, verse: verseNumber)
            guard let verse = verseMap[key] else {
                throw VerseLookupError.verseNotFound(book: reference.book.chineseName, chapter: reference.chapter, verse: verseNumber)
            }
            if !seen.contains(verse.canonicalKey) {
                result.append(verse)
                seen.insert(verse.canonicalKey)
            }
        }
        return result
    }

    private func locateBibleData() throws -> URL {
        if let bundled = Bundle.main.url(forResource: "cmn-cu89s", withExtension: "json", subdirectory: "Bible") {
            return bundled
        }

        let workingDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let local = workingDirectory.appendingPathComponent("Resources/Bible/cmn-cu89s.json")
        if FileManager.default.fileExists(atPath: local.path) {
            return local
        }

        throw NSError(
            domain: "BibleVerseReplacer.BibleStore",
            code: 1,
            userInfo: [NSLocalizedDescriptionKey: "找不到 Resources/Bible/cmn-cu89s.json"]
        )
    }

    private func chapterKey(book: String, chapter: Int) -> String {
        "\(book)#\(chapter)"
    }
}
