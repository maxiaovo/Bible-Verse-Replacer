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

enum ReferenceLabelMode: String, CaseIterable {
    case normalizedFull
    case preserveInput
    case omit

    var title: String {
        switch self {
        case .normalizedFull:
            return "改写为完整标签"
        case .preserveInput:
            return "保留输入标签"
        case .omit:
            return "不保留标签"
        }
    }
}

final class VerseFormatter {
    func format(
        parsedReference: ParsedReference,
        verses: [BibleVerse],
        format: OutputFormat,
        labelMode: ReferenceLabelMode = .normalizedFull,
        originalReference: String? = nil
    ) -> String {
        switch format {
        case .referenceVerseLines:
            return verses.map { verse in
                "\(BibleBookCatalog.chineseName(for: verse.book)) \(verse.referenceVerseText) \(cleanText(verse.text))"
            }.joined(separator: "\n")

        case .continuousText:
            let body = verses.map { cleanText($0.text) }.joined()
            return applyLabelIfNeeded(label: labelText(parsedReference: parsedReference, labelMode: labelMode, originalReference: originalReference), body: body, separator: " ")

        case .referenceHeader:
            let body = verses.map { cleanText($0.text) }.joined(separator: "\n")
            return "\(parsedReference.displayText)\n\(body)"

        case .numberedVerses:
            let body = verses.map { verse in
                "\(verse.verseLabel) \(cleanText(verse.text))"
            }.joined(separator: "\n")
            return applyLabelIfNeeded(label: labelText(parsedReference: parsedReference, labelMode: labelMode, originalReference: originalReference), body: body, separator: "\n")
        }
    }

    func format(
        reference: VerseReference,
        verses: [BibleVerse],
        format: OutputFormat,
        labelMode: ReferenceLabelMode = .normalizedFull,
        originalReference: String? = nil
    ) -> String {
        self.format(
            parsedReference: ParsedReference(passages: [PassageReference(reference: reference)]),
            verses: verses,
            format: format,
            labelMode: labelMode,
            originalReference: originalReference
        )
    }

    private func cleanText(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "\u{3000}", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func applyLabelIfNeeded(label: String?, body: String, separator: String) -> String {
        guard let label, !label.isEmpty else {
            return body
        }
        return "\(label)\(separator)\(body)"
    }

    private func labelText(parsedReference: ParsedReference, labelMode: ReferenceLabelMode, originalReference: String?) -> String? {
        switch labelMode {
        case .normalizedFull:
            return parsedReference.displayText
        case .preserveInput:
            return cleanOriginalReference(originalReference)
        case .omit:
            return nil
        }
    }

    private func cleanOriginalReference(_ raw: String?) -> String? {
        guard var text = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            return nil
        }
        text = text.replacingOccurrences(of: "\n", with: " ")
        text = text.replacingOccurrences(of: "\t", with: " ")
        text = text.trimmingCharacters(in: CharacterSet(charactersIn: "\"'“”").union(.whitespacesAndNewlines))
        while text.contains("  ") {
            text = text.replacingOccurrences(of: "  ", with: " ")
        }
        return text
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
