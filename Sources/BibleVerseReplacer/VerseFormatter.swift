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
        reference: VerseReference,
        verses: [BibleVerse],
        format: OutputFormat,
        labelMode: ReferenceLabelMode = .normalizedFull,
        originalReference: String? = nil
    ) -> String {
        switch format {
        case .referenceVerseLines:
            return verses.map { verse in
                "\(reference.book.chineseName) \(verse.referenceVerseText) \(cleanText(verse.text))"
            }.joined(separator: "\n")

        case .continuousText:
            let body = verses.map { cleanText($0.text) }.joined()
            return applyLabelIfNeeded(reference: reference, body: body, labelMode: labelMode, originalReference: originalReference, separator: " ")

        case .referenceHeader:
            let body = verses.map { cleanText($0.text) }.joined(separator: "\n")
            return "\(reference.displayText)\n\(body)"

        case .numberedVerses:
            let body = verses.map { verse in
                "\(verse.verseLabel) \(cleanText(verse.text))"
            }.joined(separator: "\n")
            return applyLabelIfNeeded(reference: reference, body: body, labelMode: labelMode, originalReference: originalReference, separator: "\n")
        }
    }

    private func cleanText(_ raw: String) -> String {
        raw
            .replacingOccurrences(of: "\u{3000}", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func applyLabelIfNeeded(
        reference: VerseReference,
        body: String,
        labelMode: ReferenceLabelMode,
        originalReference: String?,
        separator: String
    ) -> String {
        guard let label = labelText(reference: reference, labelMode: labelMode, originalReference: originalReference), !label.isEmpty else {
            return body
        }
        return "\(label)\(separator)\(body)"
    }

    private func labelText(reference: VerseReference, labelMode: ReferenceLabelMode, originalReference: String?) -> String? {
        switch labelMode {
        case .normalizedFull:
            return reference.displayText
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
