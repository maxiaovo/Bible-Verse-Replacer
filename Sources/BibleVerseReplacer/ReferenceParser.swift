import Foundation

final class ReferenceParser {
    func parse(_ rawSelection: String) throws -> VerseReference {
        let normalized = normalizeSelection(rawSelection)
        guard !normalized.isEmpty else {
            throw ReferenceParseError.emptySelection
        }

        let pattern = #"^(.+?)\s*([0-9]{1,3})\s*:\s*([0-9]{1,3})(?:\s*-\s*([0-9]{1,3}))?\s*$"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            throw ReferenceParseError.unrecognizedReference
        }

        let range = NSRange(normalized.startIndex..<normalized.endIndex, in: normalized)
        guard let match = regex.firstMatch(in: normalized, range: range), match.numberOfRanges >= 4 else {
            throw ReferenceParseError.unrecognizedReference
        }

        let bookText = string(in: normalized, at: 1, match: match)
        let chapterText = string(in: normalized, at: 2, match: match)
        let startText = string(in: normalized, at: 3, match: match)
        let endText = string(in: normalized, at: 4, match: match)

        guard let book = BibleBookCatalog.book(for: bookText) else {
            throw ReferenceParseError.unknownBook(bookText)
        }
        guard let chapter = Int(chapterText), let startVerse = Int(startText) else {
            throw ReferenceParseError.unrecognizedReference
        }

        let endVerse = Int(endText) ?? startVerse
        guard startVerse <= endVerse else {
            throw ReferenceParseError.invalidRange
        }

        return VerseReference(book: book, chapter: chapter, startVerse: startVerse, endVerse: endVerse)
    }

    private func normalizeSelection(_ raw: String) -> String {
        var text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        text = text.replacingOccurrences(of: "\n", with: " ")
        text = text.replacingOccurrences(of: "\t", with: " ")
        text = text.replacingOccurrences(of: "：", with: ":")
        text = text.replacingOccurrences(of: "－", with: "-")
        text = text.replacingOccurrences(of: "–", with: "-")
        text = text.replacingOccurrences(of: "—", with: "-")
        text = text.replacingOccurrences(of: "至", with: "-")
        text = text.replacingOccurrences(of: "﹕", with: ":")
        text = text.replacingOccurrences(of: "﹣", with: "-")
        text = text.replacingOccurrences(of: "“", with: "")
        text = text.replacingOccurrences(of: "”", with: "")
        text = text.replacingOccurrences(of: "\"", with: "")
        text = text.replacingOccurrences(of: "'", with: "")
        text = convertFullWidthDigits(text)

        while text.contains("  ") {
            text = text.replacingOccurrences(of: "  ", with: " ")
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
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

    private func string(in text: String, at index: Int, match: NSTextCheckingResult) -> String {
        guard index < match.numberOfRanges else {
            return ""
        }
        let nsRange = match.range(at: index)
        guard nsRange.location != NSNotFound, let range = Range(nsRange, in: text) else {
            return ""
        }
        return String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

