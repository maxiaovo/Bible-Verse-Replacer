import Foundation

final class BibleStore {
    static let shared = BibleStore()

    private(set) var payload: BiblePayload?
    private var verseMap: [VerseKey: BibleVerse] = [:]
    private var chapterMap: [String: [BibleVerse]] = [:]
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
        var nextChapterMap: [String: [BibleVerse]] = [:]
        var nextChapterKeys: Set<String> = []
        for verse in decoded.verses {
            for verseNumber in verse.verse...verse.endVerse {
                nextVerseMap[VerseKey(book: verse.book, chapter: verse.chapter, verse: verseNumber)] = verse
            }
            nextChapterMap[chapterKey(book: verse.book, chapter: verse.chapter), default: []].append(verse)
            nextChapterKeys.insert(chapterKey(book: verse.book, chapter: verse.chapter))
        }

        payload = decoded
        verseMap = nextVerseMap
        chapterMap = nextChapterMap.mapValues { verses in
            verses.sorted { lhs, rhs in
                if lhs.order == rhs.order {
                    return lhs.verse < rhs.verse
                }
                return lhs.order < rhs.order
            }
        }
        chapterKeys = nextChapterKeys
    }

    func verses(for parsedReference: ParsedReference) throws -> [BibleVerse] {
        var result: [BibleVerse] = []
        var seen: Set<String> = []

        for passage in parsedReference.passages {
            for verse in try verses(for: passage) where !seen.contains(verse.canonicalKey) {
                result.append(verse)
                seen.insert(verse.canonicalKey)
            }
        }

        return result.sorted { lhs, rhs in
            if lhs.order == rhs.order {
                if lhs.chapter == rhs.chapter {
                    return lhs.verse < rhs.verse
                }
                return lhs.chapter < rhs.chapter
            }
            return lhs.order < rhs.order
        }
    }

    func verses(for passage: PassageReference) throws -> [BibleVerse] {
        if passage.isWholeChapter {
            return try versesForWholeChapter(book: passage.book, chapter: passage.startChapter)
        }

        guard let startVerse = passage.startVerse, let endVerse = passage.endVerse else {
            return try versesForWholeChapter(book: passage.book, chapter: passage.startChapter)
        }

        guard passage.startChapter <= passage.endChapter else {
            throw ReferenceParseError.invalidRange
        }

        var result: [BibleVerse] = []
        var seen: Set<String> = []

        for chapter in passage.startChapter...passage.endChapter {
            let start = chapter == passage.startChapter ? startVerse : 1
            let end = chapter == passage.endChapter ? endVerse : try lastVerseNumber(book: passage.book, chapter: chapter)
            guard start <= end else {
                throw ReferenceParseError.invalidRange
            }
            for verseNumber in start...end {
                let key = VerseKey(book: passage.book.code, chapter: chapter, verse: verseNumber)
                guard let verse = verseMap[key] else {
                    if !chapterKeys.contains(chapterKey(book: passage.book.code, chapter: chapter)) {
                        throw VerseLookupError.chapterNotFound(book: passage.book.chineseName, chapter: chapter)
                    }
                    throw VerseLookupError.verseNotFound(book: passage.book.chineseName, chapter: chapter, verse: verseNumber)
                }
                if !seen.contains(verse.canonicalKey) {
                    result.append(verse)
                    seen.insert(verse.canonicalKey)
                }
            }
        }

        return result
    }

    func verses(for reference: VerseReference) throws -> [BibleVerse] {
        try verses(for: PassageReference(reference: reference))
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

    private func versesForWholeChapter(book: BibleBook, chapter: Int) throws -> [BibleVerse] {
        guard let verses = chapterMap[chapterKey(book: book.code, chapter: chapter)] else {
            throw VerseLookupError.chapterNotFound(book: book.chineseName, chapter: chapter)
        }
        return verses
    }

    private func lastVerseNumber(book: BibleBook, chapter: Int) throws -> Int {
        guard let verses = chapterMap[chapterKey(book: book.code, chapter: chapter)], let last = verses.last else {
            throw VerseLookupError.chapterNotFound(book: book.chineseName, chapter: chapter)
        }
        return last.endVerse
    }
}
