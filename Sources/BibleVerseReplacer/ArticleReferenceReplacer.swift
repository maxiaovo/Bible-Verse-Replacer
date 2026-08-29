import Foundation

struct ArticleReplacementResult {
    let text: String
    let replacements: Int
    let skippedExisting: Int

    var changed: Bool {
        replacements > 0
    }
}

final class ArticleReferenceReplacer {
    private let parser: ReferenceParser
    private let formatter: VerseFormatter
    private let bibleStore: BibleStore

    init(
        parser: ReferenceParser = ReferenceParser(),
        formatter: VerseFormatter = VerseFormatter(),
        bibleStore: BibleStore = .shared
    ) {
        self.parser = parser
        self.formatter = formatter
        self.bibleStore = bibleStore
    }

    func replaceReferences(
        in article: String,
        format: OutputFormat,
        labelMode: ReferenceLabelMode,
        combinedPassageMode: CombinedPassageMode,
        quotationStyle: QuotationStyle
    ) -> ArticleReplacementResult {
        var result = ""
        var cursor = article.startIndex
        var replacements = 0
        var skipped = 0

        while cursor < article.endIndex {
            guard let candidate = nextCandidate(in: article, from: cursor) else {
                result.append(contentsOf: article[cursor...])
                break
            }

            result.append(contentsOf: article[cursor..<candidate.range.lowerBound])

            do {
                let reference = try parser.parseSelection(candidate.raw)
                let verseGroups = try bibleStore.verseGroups(for: reference)
                let verses = try bibleStore.verses(for: reference)
                if scriptureAlreadyPresent(after: candidate.range.upperBound, in: article, verses: verses, quotationStyle: quotationStyle) {
                    result.append(contentsOf: article[candidate.range])
                    skipped += 1
                } else {
                    result.append(formatter.format(
                        parsedReference: reference,
                        verses: verses,
                        verseGroups: verseGroups,
                        format: format,
                        labelMode: labelMode,
                        originalReference: candidate.raw,
                        combinedPassageMode: combinedPassageMode,
                        quotationStyle: quotationStyle
                    ))
                    replacements += 1
                }
                cursor = candidate.range.upperBound
            } catch {
                result.append(article[candidate.range.lowerBound])
                cursor = article.index(after: candidate.range.lowerBound)
            }
        }

        return ArticleReplacementResult(text: result, replacements: replacements, skippedExisting: skipped)
    }

    private func nextCandidate(in text: String, from start: String.Index) -> (range: Range<String.Index>, raw: String)? {
        var index = start
        while index < text.endIndex {
            if isReferenceStart(in: text, at: index),
               let end = candidateEnd(in: text, from: index) {
                let trimmedEnd = trimCandidateEnd(in: text, start: index, end: end)
                if trimmedEnd > index {
                    return (index..<trimmedEnd, String(text[index..<trimmedEnd]))
                }
            }
            index = text.index(after: index)
        }
        return nil
    }

    private func isReferenceStart(in text: String, at index: String.Index) -> Bool {
        if text[index].isWhitespace {
            return false
        }

        if index > text.startIndex {
            let previous = text[text.index(before: index)]
            if previous.isNumber || previous.isASCIILetter {
                return false
            }
        }

        guard let match = BibleBookCatalog.bookAtStart(of: String(text[index...])) else {
            return false
        }

        var lookahead = text.index(index, offsetBy: rawPrefixLength(for: match.book, in: text[index...]), limitedBy: text.endIndex) ?? index
        while lookahead < text.endIndex, text[lookahead].isWhitespace {
            lookahead = text.index(after: lookahead)
        }
        guard lookahead < text.endIndex else {
            return false
        }
        return text[lookahead].isNumber || text[lookahead] == "第"
    }

    private func rawPrefixLength(for book: BibleBook, in text: Substring) -> Int {
        let aliases = ([book.chineseName, book.code] + book.aliases).sorted { $0.count > $1.count }
        let lower = text.lowercased()
        for alias in aliases where lower.hasPrefix(alias.lowercased()) {
            return alias.count
        }
        return book.chineseName.count
    }

    private func candidateEnd(in text: String, from start: String.Index) -> String.Index? {
        guard let match = BibleBookCatalog.bookAtStart(of: String(text[start...])) else {
            return nil
        }

        var index = text.index(
            start,
            offsetBy: rawPrefixLength(for: match.book, in: text[start...]),
            limitedBy: text.endIndex
        ) ?? start
        while index < text.endIndex {
            let character = text[index]
            if !isCandidateCharacter(character) {
                break
            }
            index = text.index(after: index)
        }
        return index > start ? index : nil
    }

    private func isCandidateCharacter(_ character: Character) -> Bool {
        if character.isNumber || character.isWhitespace {
            return true
        }
        if "toTO".contains(character) {
            return true
        }
        return ":：﹕,，、;；|｜\\-－–—―﹣～~^.…第章节到至".contains(character)
    }

    private func trimCandidateEnd(in text: String, start: String.Index, end: String.Index) -> String.Index {
        var trimmed = end
        while trimmed > start {
            let previous = text[text.index(before: trimmed)]
            if previous.isWhitespace || ",，、;；|｜\\".contains(previous) {
                trimmed = text.index(before: trimmed)
            } else {
                break
            }
        }
        return trimmed
    }

    private func scriptureAlreadyPresent(
        after index: String.Index,
        in text: String,
        verses: [BibleVerse],
        quotationStyle: QuotationStyle
    ) -> Bool {
        guard let firstVerse = verses.first else {
            return false
        }

        var cursor = index
        while cursor < text.endIndex, text[cursor].isWhitespace || ":：".contains(text[cursor]) {
            cursor = text.index(after: cursor)
        }

        let remaining = String(text[cursor...])
        let expected = formatter.displayText(for: firstVerse, quotationStyle: quotationStyle)
        return normalizedScripturePrefix(remaining).hasPrefix(normalizedScripturePrefix(String(expected.prefix(12))))
    }

    private func normalizedScripturePrefix(_ text: String) -> String {
        text
            .prefix(30)
            .map { character -> Character in
                switch character {
                case "「", "“":
                    return "\""
                case "」", "”":
                    return "\""
                default:
                    return character
                }
            }
            .filter { !$0.isWhitespace }
            .map(String.init)
            .joined()
    }
}

private extension Character {
    var isASCIILetter: Bool {
        unicodeScalars.count == 1 && unicodeScalars.allSatisfy { scalar in
            (65...90).contains(scalar.value) || (97...122).contains(scalar.value)
        }
    }
}
