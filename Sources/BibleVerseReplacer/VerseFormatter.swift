import Foundation

enum OutputFormat: String, CaseIterable {
    case referenceVerseLines
    case continuousText
    case referenceHeader
    case numberedVerses

    var title: String {
        switch self {
        case .referenceVerseLines:
            return "书卷 章:节 经文"
        case .continuousText:
            return "连续正文"
        case .referenceHeader:
            return "首行引用 + 分节经文"
        case .numberedVerses:
            return "每节带节号"
        }
    }
}

final class VerseFormatter {
    func format(reference: VerseReference, verses: [BibleVerse], format: OutputFormat) -> String {
        switch format {
        case .referenceVerseLines:
            return verses.map { verse in
                "\(reference.book.chineseName) \(verse.referenceVerseText) \(cleanText(verse.text))"
            }.joined(separator: "\n")

        case .continuousText:
            return verses.map { cleanText($0.text) }.joined()

        case .referenceHeader:
            let body = verses.map { cleanText($0.text) }.joined(separator: "\n")
            return "\(reference.displayText)\n\(body)"

        case .numberedVerses:
            return verses.map { verse in
                "\(verse.verseLabel) \(cleanText(verse.text))"
            }.joined(separator: "\n")
        }
    }

    private func cleanText(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "\u{3000}", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private extension BibleVerse {
    var verseLabel: String {
        if verse == endVerse {
            return "\(verse)"
        }
        return "\(verse)-\(endVerse)"
    }
}
