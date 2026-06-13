import Foundation

final class ReferenceParser {
    func parseSelection(_ rawSelection: String) throws -> ParsedReference {
        let normalized = normalizeSelection(rawSelection)
        guard !normalized.isEmpty else {
            throw ReferenceParseError.emptySelection
        }

        let chunks = normalized
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !chunks.isEmpty else {
            throw ReferenceParseError.unrecognizedReference
        }

        var passages: [PassageReference] = []
        var currentBook: BibleBook?
        var currentChapter: Int?

        for chunk in chunks {
            let parsed = try parseChunk(chunk, currentBook: currentBook, currentChapter: currentChapter)
            passages.append(parsed.passage)
            currentBook = parsed.passage.book
            currentChapter = parsed.contextChapter
        }

        return ParsedReference(passages: passages)
    }

    func parse(_ rawSelection: String) throws -> VerseReference {
        let parsed = try parseSelection(rawSelection)
        guard parsed.passages.count == 1, let passage = parsed.passages.first,
              passage.startChapter == passage.endChapter,
              let startVerse = passage.startVerse,
              let endVerse = passage.endVerse else {
            throw ReferenceParseError.unrecognizedReference
        }

        return VerseReference(book: passage.book, chapter: passage.startChapter, startVerse: startVerse, endVerse: endVerse)
    }

    private func normalizeSelection(_ raw: String) -> String {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        text = text.replacingOccurrences(of: "\n", with: " ")
        text = text.replacingOccurrences(of: "\t", with: " ")
        text = text.replacingOccurrences(of: "\u{3000}", with: " ")
        text = text.replacingOccurrences(of: "：", with: ":")
        text = text.replacingOccurrences(of: "﹕", with: ":")
        text = text.replacingOccurrences(of: "“", with: "")
        text = text.replacingOccurrences(of: "”", with: "")
        text = text.replacingOccurrences(of: "\"", with: "")
        text = text.replacingOccurrences(of: "'", with: "")
        text = convertFullWidthDigits(text)
        text = normalizeRanges(text)
        text = normalizeSeparators(text)

        while text.contains("  ") {
            text = text.replacingOccurrences(of: "  ", with: " ")
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func normalizeRanges(_ raw: String) -> String {
        var text = raw
        let replacements = [
            "……", "...", "——", "--", "－", "–", "—", "―", "﹣", "～", "~", "^", "到", "至"
        ]
        for token in replacements {
            text = text.replacingOccurrences(of: token, with: "-")
        }

        if let regex = try? NSRegularExpression(pattern: #"(?i)(\d)\s*to\s*(\d)"#) {
            let range = NSRange(text.startIndex..<text.endIndex, in: text)
            text = regex.stringByReplacingMatches(in: text, range: range, withTemplate: "$1-$2")
        }
        return text
    }

    private func normalizeSeparators(_ raw: String) -> String {
        var text = raw
        for token in ["，", "、", "；", ";", "｜", "|", "\\"] {
            text = text.replacingOccurrences(of: token, with: ",")
        }
        return text
    }

    private func convertFullWidthDigits(_ text: String) -> String {
        var result = ""
        for scalar in text.unicodeScalars {
            let value = scalar.value
            if value >= 0xFF10 && value <= 0xFF19 {
                result.unicodeScalars.append(UnicodeScalar(value - 0xFF10 + 0x30)!)
            } else {
                result.unicodeScalars.append(scalar)
            }
        }
        return result
    }

    private func parseChunk(
        _ rawChunk: String,
        currentBook: BibleBook?,
        currentChapter: Int?
    ) throws -> (passage: PassageReference, contextChapter: Int) {
        let compact = rawChunk
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "")

        guard !compact.isEmpty else {
            throw ReferenceParseError.unrecognizedReference
        }

        var book = currentBook
        var body = compact
        if let match = BibleBookCatalog.bookAtStart(of: compact) {
            book = match.book
            body = match.remaining
        }

        guard let resolvedBook = book else {
            throw ReferenceParseError.unknownBook(rawChunk)
        }

        if let passage = try parseChapterStyle(body, book: resolvedBook, currentChapter: currentChapter) {
            return (passage, passage.endChapter)
        }

        if let passage = try parseColonStyle(body, book: resolvedBook) {
            return (passage, passage.endChapter)
        }

        if let passage = try parseInheritedVerseStyle(body, book: resolvedBook, currentChapter: currentChapter) {
            return (passage, passage.endChapter)
        }

        throw ReferenceParseError.unrecognizedReference
    }

    private func parseChapterStyle(_ body: String, book: BibleBook, currentChapter: Int?) throws -> PassageReference? {
        guard body.contains("章") || body.contains("节") else {
            return nil
        }

        if let match = firstMatch(pattern: #"^第?(\d+)章(?:第?(\d+)(?:-(\d+))?节?)?$"#, in: body) {
            let chapter = intGroup(match, 1, in: body)
            let startVerse = optionalIntGroup(match, 2, in: body)
            let endVerse = optionalIntGroup(match, 3, in: body) ?? startVerse
            if let startVerse, let endVerse, startVerse > endVerse {
                throw ReferenceParseError.invalidRange
            }
            return PassageReference(book: book, startChapter: chapter, startVerse: startVerse, endChapter: chapter, endVerse: endVerse)
        }

        if let match = firstMatch(pattern: #"^第?(\d+)(?:-(\d+))?节$"#, in: body), let currentChapter {
            let startVerse = intGroup(match, 1, in: body)
            let endVerse = optionalIntGroup(match, 2, in: body) ?? startVerse
            if startVerse > endVerse {
                throw ReferenceParseError.invalidRange
            }
            return PassageReference(book: book, startChapter: currentChapter, startVerse: startVerse, endChapter: currentChapter, endVerse: endVerse)
        }

        return nil
    }

    private func parseColonStyle(_ body: String, book: BibleBook) throws -> PassageReference? {
        if let match = firstMatch(pattern: #"^(\d+):(\d+)-(\d+):(\d+)$"#, in: body) {
            let startChapter = intGroup(match, 1, in: body)
            let startVerse = intGroup(match, 2, in: body)
            let endChapter = intGroup(match, 3, in: body)
            let endVerse = intGroup(match, 4, in: body)
            if startChapter > endChapter || (startChapter == endChapter && startVerse > endVerse) {
                throw ReferenceParseError.invalidRange
            }
            return PassageReference(book: book, startChapter: startChapter, startVerse: startVerse, endChapter: endChapter, endVerse: endVerse)
        }

        if let match = firstMatch(pattern: #"^(\d+):(\d+)-(\d+)$"#, in: body) {
            let chapter = intGroup(match, 1, in: body)
            let startVerse = intGroup(match, 2, in: body)
            let endVerse = intGroup(match, 3, in: body)
            if startVerse > endVerse {
                throw ReferenceParseError.invalidRange
            }
            return PassageReference(book: book, startChapter: chapter, startVerse: startVerse, endChapter: chapter, endVerse: endVerse)
        }

        if let match = firstMatch(pattern: #"^(\d+):(\d+)$"#, in: body) {
            let chapter = intGroup(match, 1, in: body)
            let verse = intGroup(match, 2, in: body)
            return PassageReference(book: book, startChapter: chapter, startVerse: verse, endChapter: chapter, endVerse: verse)
        }

        return nil
    }

    private func parseInheritedVerseStyle(_ body: String, book: BibleBook, currentChapter: Int?) throws -> PassageReference? {
        if let match = firstMatch(pattern: #"^(\d+)-(\d+)$"#, in: body), let currentChapter {
            let startVerse = intGroup(match, 1, in: body)
            let endVerse = intGroup(match, 2, in: body)
            if startVerse > endVerse {
                throw ReferenceParseError.invalidRange
            }
            return PassageReference(book: book, startChapter: currentChapter, startVerse: startVerse, endChapter: currentChapter, endVerse: endVerse)
        }

        if let match = firstMatch(pattern: #"^(\d+)$"#, in: body) {
            let number = intGroup(match, 1, in: body)
            if let currentChapter {
                return PassageReference(book: book, startChapter: currentChapter, startVerse: number, endChapter: currentChapter, endVerse: number)
            }
            return PassageReference(book: book, startChapter: number, startVerse: nil, endChapter: number, endVerse: nil)
        }

        return nil
    }

    private func firstMatch(pattern: String, in text: String) -> NSTextCheckingResult? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return regex.firstMatch(in: text, range: range)
    }

    private func intGroup(_ match: NSTextCheckingResult, _ index: Int, in text: String) -> Int {
        Int(group(match, index, in: text)) ?? 0
    }

    private func optionalIntGroup(_ match: NSTextCheckingResult, _ index: Int, in text: String) -> Int? {
        let value = group(match, index, in: text)
        return value.isEmpty ? nil : Int(value)
    }

    private func group(_ match: NSTextCheckingResult, _ index: Int, in text: String) -> String {
        guard index < match.numberOfRanges else {
            return ""
        }
        let range = match.range(at: index)
        guard range.location != NSNotFound, let swiftRange = Range(range, in: text) else {
            return ""
        }
        return String(text[swiftRange])
    }
}
