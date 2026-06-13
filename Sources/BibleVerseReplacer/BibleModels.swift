import Foundation

struct BiblePayload: Decodable {
    let id: String
    let name: String
    let displayName: String
    let source: BibleSource
    let generatedAt: String
    let verses: [BibleVerse]
}

struct BibleSource: Decodable {
    let url: String
    let format: String
    let sourceFile: String
}

struct BibleVerse: Decodable {
    let book: String
    let chapter: Int
    let verse: Int
    let endVerse: Int
    let text: String
    let order: Int

    var referenceVerseText: String {
        if verse == endVerse {
            return "\(chapter):\(verse)"
        }
        return "\(chapter):\(verse)-\(endVerse)"
    }

    var canonicalKey: String {
        "\(book)#\(chapter)#\(verse)#\(endVerse)"
    }
}

struct VerseReference: Equatable {
    let book: BibleBook
    let chapter: Int
    let startVerse: Int
    let endVerse: Int

    var isRange: Bool {
        startVerse != endVerse
    }

    var displayText: String {
        if isRange {
            return "\(book.chineseName) \(chapter):\(startVerse)-\(endVerse)"
        }
        return "\(book.chineseName) \(chapter):\(startVerse)"
    }
}

struct PassageReference: Equatable {
    let book: BibleBook
    let startChapter: Int
    let startVerse: Int?
    let endChapter: Int
    let endVerse: Int?

    init(book: BibleBook, startChapter: Int, startVerse: Int?, endChapter: Int, endVerse: Int?) {
        self.book = book
        self.startChapter = startChapter
        self.startVerse = startVerse
        self.endChapter = endChapter
        self.endVerse = endVerse
    }

    init(reference: VerseReference) {
        self.book = reference.book
        self.startChapter = reference.chapter
        self.startVerse = reference.startVerse
        self.endChapter = reference.chapter
        self.endVerse = reference.endVerse
    }

    var isWholeChapter: Bool {
        startVerse == nil && endVerse == nil && startChapter == endChapter
    }

    var displayText: String {
        if isWholeChapter {
            return "\(book.chineseName) 第\(startChapter)章"
        }

        guard let startVerse, let endVerse else {
            return "\(book.chineseName) 第\(startChapter)章"
        }

        if startChapter == endChapter {
            if startVerse == endVerse {
                return "\(book.chineseName) \(startChapter):\(startVerse)"
            }
            return "\(book.chineseName) \(startChapter):\(startVerse)-\(endVerse)"
        }

        return "\(book.chineseName) \(startChapter):\(startVerse)-\(endChapter):\(endVerse)"
    }
}

struct ParsedReference: Equatable {
    let passages: [PassageReference]

    var displayText: String {
        passages.map(\.displayText).joined(separator: "；")
    }
}

struct VerseKey: Hashable {
    let book: String
    let chapter: Int
    let verse: Int
}

enum VerseLookupError: LocalizedError {
    case chapterNotFound(book: String, chapter: Int)
    case verseNotFound(book: String, chapter: Int, verse: Int)

    var errorDescription: String? {
        switch self {
        case let .chapterNotFound(book, chapter):
            return "\(book) 第 \(chapter) 章不存在"
        case let .verseNotFound(book, chapter, verse):
            return "\(book) \(chapter):\(verse) 不存在"
        }
    }
}

enum ReferenceParseError: LocalizedError {
    case emptySelection
    case unrecognizedReference
    case unknownBook(String)
    case invalidRange

    var errorDescription: String? {
        switch self {
        case .emptySelection:
            return "没有选中文字"
        case .unrecognizedReference:
            return "未识别到经文引用"
        case let .unknownBook(book):
            return "未识别书卷：\(book)"
        case .invalidRange:
            return "范围顺序不正确"
        }
    }
}
