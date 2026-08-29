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

enum CombinedPassageMode: String, CaseIterable {
    case compactEllipsis
    case groupedLines

    var title: String {
        switch self {
        case .compactEllipsis:
            return "合并为一段（省略号连接）"
        case .groupedLines:
            return "按片段分行"
        }
    }
}

enum QuotationStyle: String, CaseIterable {
    case fullWidth
    case halfWidth
    case square

    var title: String {
        switch self {
        case .fullWidth:
            return "全角引号 “ ”"
        case .halfWidth:
            return "半角引号 \" \""
        case .square:
            return "保留方引号 「 」"
        }
    }
}

final class VerseFormatter {
    func format(
        parsedReference: ParsedReference,
        verses: [BibleVerse],
        verseGroups: [PassageVerseGroup]? = nil,
        format: OutputFormat,
        labelMode: ReferenceLabelMode = .normalizedFull,
        originalReference: String? = nil,
        combinedPassageMode: CombinedPassageMode = .compactEllipsis,
        quotationStyle: QuotationStyle = .fullWidth
    ) -> String {
        switch format {
        case .referenceVerseLines:
            return verses.map { verse in
                "\(BibleBookCatalog.chineseName(for: verse.book)) \(verse.referenceVerseText) \(displayText(for: verse, quotationStyle: quotationStyle))"
            }.joined(separator: "\n")

        case .continuousText:
            return continuousText(
                parsedReference: parsedReference,
                verses: verses,
                verseGroups: verseGroups,
                labelMode: labelMode,
                originalReference: originalReference,
                combinedPassageMode: combinedPassageMode,
                quotationStyle: quotationStyle
            )

        case .referenceHeader:
            let body = verses.map { displayText(for: $0, quotationStyle: quotationStyle) }.joined(separator: "\n")
            return "\(parsedReference.displayText)\n\(body)"

        case .numberedVerses:
            let body = verses.map { verse in
                "\(verse.verseLabel) \(displayText(for: verse, quotationStyle: quotationStyle))"
            }.joined(separator: "\n")
            return applyLabelIfNeeded(label: labelText(parsedReference: parsedReference, labelMode: labelMode, originalReference: originalReference), body: body, separator: "\n")
        }
    }

    func format(
        reference: VerseReference,
        verses: [BibleVerse],
        format: OutputFormat,
        labelMode: ReferenceLabelMode = .normalizedFull,
        originalReference: String? = nil,
        quotationStyle: QuotationStyle = .fullWidth
    ) -> String {
        self.format(
            parsedReference: ParsedReference(passages: [PassageReference(reference: reference)]),
            verses: verses,
            format: format,
            labelMode: labelMode,
            originalReference: originalReference,
            quotationStyle: quotationStyle
        )
    }

    private func continuousText(
        parsedReference: ParsedReference,
        verses: [BibleVerse],
        verseGroups: [PassageVerseGroup]?,
        labelMode: ReferenceLabelMode,
        originalReference: String?,
        combinedPassageMode: CombinedPassageMode,
        quotationStyle: QuotationStyle
    ) -> String {
        guard let verseGroups, !verseGroups.isEmpty else {
            let body = verses.map { displayText(for: $0, quotationStyle: quotationStyle) }.joined()
            return applyLabelIfNeeded(
                label: labelText(parsedReference: parsedReference, labelMode: labelMode, originalReference: originalReference),
                body: body,
                separator: " "
            )
        }

        switch combinedPassageMode {
        case .compactEllipsis:
            let body = verseGroups
                .map { group in group.verses.map { displayText(for: $0, quotationStyle: quotationStyle) }.joined() }
                .joined(separator: "……")
            return applyLabelIfNeeded(
                label: labelText(
                    parsedReference: parsedReference,
                    labelMode: labelMode,
                    originalReference: originalReference,
                    normalizedLabel: parsedReference.compactDisplayText
                ),
                body: body,
                separator: " "
            )

        case .groupedLines:
            return verseGroups.map { group in
                let body = group.verses.map { displayText(for: $0, quotationStyle: quotationStyle) }.joined()
                return applyLabelIfNeeded(
                    label: groupLabelText(
                        group: group,
                        groupCount: verseGroups.count,
                        labelMode: labelMode,
                        originalReference: originalReference
                    ),
                    body: body,
                    separator: " "
                )
            }.joined(separator: "\n")
        }
    }

    func cleanText(_ raw: String, quotationStyle: QuotationStyle = .fullWidth) -> String {
        applyQuotationStyle(raw, quotationStyle: quotationStyle)
            .replacingOccurrences(of: "\u{3000}", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func displayText(for verse: BibleVerse, quotationStyle: QuotationStyle = .fullWidth) -> String {
        let text = cleanText(verse.text, quotationStyle: quotationStyle)
        guard let note = verse.note?.trimmingCharacters(in: .whitespacesAndNewlines), !note.isEmpty else {
            return text
        }
        return "（\(note)：\(text)）"
    }

    private func applyQuotationStyle(_ raw: String, quotationStyle: QuotationStyle) -> String {
        switch quotationStyle {
        case .fullWidth:
            return raw
                .replacingOccurrences(of: "「", with: "“")
                .replacingOccurrences(of: "」", with: "”")
        case .halfWidth:
            return raw
                .replacingOccurrences(of: "「", with: "\"")
                .replacingOccurrences(of: "」", with: "\"")
        case .square:
            return raw
        }
    }

    private func applyLabelIfNeeded(label: String?, body: String, separator: String) -> String {
        guard let label, !label.isEmpty else {
            return body
        }
        return "\(label)\(separator)\(body)"
    }

    private func labelText(
        parsedReference: ParsedReference,
        labelMode: ReferenceLabelMode,
        originalReference: String?,
        normalizedLabel: String? = nil
    ) -> String? {
        switch labelMode {
        case .normalizedFull:
            return normalizedLabel ?? parsedReference.displayText
        case .preserveInput:
            return cleanOriginalReference(originalReference)
        case .omit:
            return nil
        }
    }

    private func groupLabelText(
        group: PassageVerseGroup,
        groupCount: Int,
        labelMode: ReferenceLabelMode,
        originalReference: String?
    ) -> String? {
        switch labelMode {
        case .normalizedFull:
            return group.passage.displayText
        case .preserveInput:
            if groupCount == 1 {
                return cleanOriginalReference(originalReference)
            }
            return group.passage.displayText
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
