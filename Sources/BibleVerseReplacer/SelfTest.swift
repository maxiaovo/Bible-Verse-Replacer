import Foundation

enum SelfTest {
    static func run() -> Int32 {
        do {
            try BibleStore.shared.load()

            let parser = ReferenceParser()
            let formatter = VerseFormatter()
            let preferencesFormat = OutputFormat.referenceVerseLines

            try assertFormatted(
                raw: "创世记 1:1",
                expected: "创世记 1:1 起初，神创造天地。",
                parser: parser,
                formatter: formatter,
                format: preferencesFormat
            )

            try assertFormatted(
                raw: "创 1:1",
                expected: "创世记 1:1 起初，神创造天地。",
                parser: parser,
                formatter: formatter,
                format: .continuousText,
                labelMode: .normalizedFull
            )

            try assertFormatted(
                raw: "创 1:1",
                expected: "创 1:1 起初，神创造天地。",
                parser: parser,
                formatter: formatter,
                format: .continuousText,
                labelMode: .preserveInput
            )

            try assertFormatted(
                raw: "创 1:1",
                expected: "起初，神创造天地。",
                parser: parser,
                formatter: formatter,
                format: .continuousText,
                labelMode: .omit
            )

            try assertFormatted(
                raw: "创3：2－5",
                expectedPrefix: "创世记 3:2 女人对蛇说",
                parser: parser,
                formatter: formatter,
                format: preferencesFormat
            )

            try assertFormatted(
                raw: "\"Genesis 4:1\"",
                expectedPrefix: "创世记 4:1 有一日，那人和他妻子夏娃同房",
                parser: parser,
                formatter: formatter,
                format: preferencesFormat
            )

            try assertFormatted(
                raw: "创世记 24:29-30",
                expectedPrefix: "创世记 24:29-30 利百加有一个哥哥",
                parser: parser,
                formatter: formatter,
                format: preferencesFormat
            )

            do {
                _ = try parser.parse("创世记 3:5-2")
                throw TestFailure("Expected invalid range to throw")
            } catch ReferenceParseError.invalidRange {
                // Expected.
            }

            print("Self-test passed")
            return 0
        } catch {
            fputs("Self-test failed: \(error.localizedDescription)\n", stderr)
            return 1
        }
    }

    private static func assertFormatted(
        raw: String,
        expected: String,
        parser: ReferenceParser,
        formatter: VerseFormatter,
        format: OutputFormat
    ) throws {
        try assertFormatted(raw: raw, expected: expected, parser: parser, formatter: formatter, format: format, labelMode: .normalizedFull)
    }

    private static func assertFormatted(
        raw: String,
        expected: String,
        parser: ReferenceParser,
        formatter: VerseFormatter,
        format: OutputFormat,
        labelMode: ReferenceLabelMode
    ) throws {
        let actual = try formatted(raw: raw, parser: parser, formatter: formatter, format: format, labelMode: labelMode)
        if actual != expected {
            throw TestFailure("For \(raw), expected \(expected), got \(actual)")
        }
    }

    private static func assertFormatted(
        raw: String,
        expectedPrefix: String,
        parser: ReferenceParser,
        formatter: VerseFormatter,
        format: OutputFormat
    ) throws {
        let actual = try formatted(raw: raw, parser: parser, formatter: formatter, format: format, labelMode: .normalizedFull)
        if !actual.hasPrefix(expectedPrefix) {
            throw TestFailure("For \(raw), expected prefix \(expectedPrefix), got \(actual)")
        }
    }

    private static func formatted(
        raw: String,
        parser: ReferenceParser,
        formatter: VerseFormatter,
        format: OutputFormat,
        labelMode: ReferenceLabelMode
    ) throws -> String {
        let reference = try parser.parse(raw)
        let verses = try BibleStore.shared.verses(for: reference)
        return formatter.format(reference: reference, verses: verses, format: format, labelMode: labelMode, originalReference: raw)
    }
}

struct TestFailure: LocalizedError {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    var errorDescription: String? {
        message
    }
}
