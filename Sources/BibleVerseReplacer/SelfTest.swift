import Foundation

enum SelfTest {
    static func run() -> Int32 {
        do {
            try BibleStore.shared.load()

            let parser = ReferenceParser()
            let formatter = VerseFormatter()
            let articleReplacer = ArticleReferenceReplacer(parser: parser, formatter: formatter)
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
                raw: "创世纪 1:1",
                expected: "创世记 1:1 起初，神创造天地。",
                parser: parser,
                formatter: formatter,
                format: .continuousText,
                labelMode: .normalizedFull
            )

            try assertFormatted(
                raw: "马可 5:8",
                expectedPrefix: "马可福音 5:8 是因耶稣曾吩咐他说",
                parser: parser,
                formatter: formatter,
                format: .referenceVerseLines
            )

            try assertFormatted(
                raw: "陆家 2:10",
                expectedPrefix: "路加福音 2:10 那天使对他们说",
                parser: parser,
                formatter: formatter,
                format: .referenceVerseLines
            )

            try assertFormatted(
                raw: "约翰 3:16",
                expectedPrefix: "约翰福音 3:16 “神爱世人",
                parser: parser,
                formatter: formatter,
                format: .referenceVerseLines
            )

            try assertFormatted(
                raw: "创1:1-3，7",
                expected: "创世记 1:1-3,7 起初，神创造天地。地是空虚混沌，渊面黑暗；神的灵运行在水面上。神说：“要有光”，就有了光。……神就造出空气，将空气以下的水、空气以上的水分开了。事就这样成了。",
                parser: parser,
                formatter: formatter,
                format: .continuousText,
                labelMode: .normalizedFull
            )

            try assertFormatted(
                raw: "创1:1-3，7",
                expected: "创世记 1:1-3 起初，神创造天地。地是空虚混沌，渊面黑暗；神的灵运行在水面上。神说：“要有光”，就有了光。\n创世记 1:7 神就造出空气，将空气以下的水、空气以上的水分开了。事就这样成了。",
                parser: parser,
                formatter: formatter,
                format: .continuousText,
                labelMode: .normalizedFull,
                combinedPassageMode: .groupedLines
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

            try assertFormatted(
                raw: "创世记 3:2,5,7-9",
                expected: [
                    "创世记 3:2 女人对蛇说",
                    "创世记 3:5 因为神知道",
                    "创世记 3:7 他们二人的眼睛就明亮了",
                    "创世记 3:8 天起了凉风",
                    "创世记 3:9 耶和华神呼唤那人"
                ],
                parser: parser,
                formatter: formatter
            )

            try assertFormatted(
                raw: "创世记 3:2、5，7-9",
                expected: [
                    "创世记 3:2 女人对蛇说",
                    "创世记 3:5 因为神知道",
                    "创世记 3:7 他们二人的眼睛就明亮了"
                ],
                parser: parser,
                formatter: formatter
            )

            try assertFormatted(
                raw: "创世记 3:24 -4:2",
                expected: [
                    "创世记 3:24 于是把他赶出去了",
                    "创世记 4:1 有一日，那人和他妻子夏娃同房",
                    "创世记 4:2 又生了该隐的兄弟亚伯"
                ],
                parser: parser,
                formatter: formatter
            )

            try assertFormatted(
                raw: "创世记第3章",
                expected: [
                    "创世记 3:1 耶和华神所造的",
                    "创世记 3:24 于是把他赶出去了"
                ],
                parser: parser,
                formatter: formatter
            )

            try assertFormatted(
                raw: "约 3:16，罗 8:28",
                expected: [
                    "约翰福音 3:16 “神爱世人",
                    "罗马书 8:28 我们晓得万事都互相效力"
                ],
                parser: parser,
                formatter: formatter
            )

            try assertFormatted(
                raw: "创1:3",
                expected: "创世记 1:3 神说：\"要有光\"，就有了光。",
                parser: parser,
                formatter: formatter,
                format: .continuousText,
                labelMode: .normalizedFull,
                quotationStyle: .halfWidth
            )

            try assertFormatted(
                raw: "创1:3",
                expected: "创世记 1:3 神说：「要有光」，就有了光。",
                parser: parser,
                formatter: formatter,
                format: .continuousText,
                labelMode: .normalizedFull,
                quotationStyle: .square
            )

            try assertFormatted(
                raw: "创世记 3:2-5，4:1",
                expected: [
                    "创世记 3:2 女人对蛇说",
                    "创世记 3:5 因为神知道",
                    "创世记 4:1 有一日，那人和他妻子夏娃同房"
                ],
                parser: parser,
                formatter: formatter
            )

            for raw in [
                "约三1:1到3",
                "约三1: 1～3",
                "约三1: 1~3",
                "约三1:1-3",
                "约三1:1至3",
                "约三1:1 to 3",
                "约三1:1to3",
                "约三1:1——3",
                "约三1:1--3",
                "约三1:1...3",
                "约三1:1^3",
                "约三1:1……3"
            ] {
                try assertFormatted(
                    raw: raw,
                    expected: [
                        "约翰三书 1:1 作长老的写信给亲爱的该犹",
                        "约翰三书 1:3 有弟兄来证明你心里存的真理"
                    ],
                    parser: parser,
                    formatter: formatter
                )
            }

            try assertFormatted(
                raw: "约三1:1\\1:2|1:3",
                expected: [
                    "约翰三书 1:1 作长老的写信给亲爱的该犹",
                    "约翰三书 1:2 亲爱的兄弟啊",
                    "约翰三书 1:3 有弟兄来证明你心里存的真理"
                ],
                parser: parser,
                formatter: formatter
            )

            do {
                _ = try parser.parse("创世记 3:5-2")
                throw TestFailure("Expected invalid range to throw")
            } catch ReferenceParseError.invalidRange {
                // Expected.
            }

            let article = "今天读：创世记 1:1\n还有 马可 5:8\n已经替换：创世记 1:1 起初，神创造天地。"
            let articleResult = articleReplacer.replaceReferences(
                in: article,
                format: .continuousText,
                labelMode: .normalizedFull,
                combinedPassageMode: .compactEllipsis,
                quotationStyle: .fullWidth
            )
            if articleResult.replacements != 2 || articleResult.skippedExisting != 1 {
                throw TestFailure("Expected 2 article replacements and 1 skip, got \(articleResult.replacements) replacements and \(articleResult.skippedExisting) skips")
            }
            for fragment in [
                "今天读：创世记 1:1 起初，神创造天地。",
                "还有 马可福音 5:8 是因耶稣曾吩咐他说",
                "已经替换：创世记 1:1 起初，神创造天地。"
            ] where !articleResult.text.contains(fragment) {
                throw TestFailure("Expected article output to contain \(fragment), got \(articleResult.text)")
            }

            let inlineChineseArticle = "今天我读了创世记1:1"
            let inlineChineseResult = articleReplacer.replaceReferences(
                in: inlineChineseArticle,
                format: .continuousText,
                labelMode: .normalizedFull,
                combinedPassageMode: .compactEllipsis,
                quotationStyle: .fullWidth
            )
            if inlineChineseResult.text != "今天我读了创世记 1:1 起初，神创造天地。" {
                throw TestFailure("Expected inline Chinese article replacement, got \(inlineChineseResult.text)")
            }

            try assertUpdateDownloadStaging()
            try assertUpdateDownloadStagingCreatesDestinationDirectory()
            try assertUpdateDownloadStagingReportsMissingSource()

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
        labelMode: ReferenceLabelMode,
        combinedPassageMode: CombinedPassageMode = .compactEllipsis,
        quotationStyle: QuotationStyle = .fullWidth
    ) throws {
        let actual = try formatted(raw: raw, parser: parser, formatter: formatter, format: format, labelMode: labelMode, combinedPassageMode: combinedPassageMode, quotationStyle: quotationStyle)
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

    private static func assertFormatted(
        raw: String,
        expected: [String],
        parser: ReferenceParser,
        formatter: VerseFormatter
    ) throws {
        let actual = try formatted(raw: raw, parser: parser, formatter: formatter, format: .referenceVerseLines, labelMode: .normalizedFull)
        for expectedFragment in expected where !actual.contains(expectedFragment) {
            throw TestFailure("For \(raw), expected output to contain \(expectedFragment), got \(actual)")
        }
    }

    private static func formatted(
        raw: String,
        parser: ReferenceParser,
        formatter: VerseFormatter,
        format: OutputFormat,
        labelMode: ReferenceLabelMode,
        combinedPassageMode: CombinedPassageMode = .compactEllipsis,
        quotationStyle: QuotationStyle = .fullWidth
    ) throws -> String {
        let reference = try parser.parseSelection(raw)
        let verseGroups = try BibleStore.shared.verseGroups(for: reference)
        let verses = try BibleStore.shared.verses(for: reference)
        return formatter.format(
            parsedReference: reference,
            verses: verses,
            verseGroups: verseGroups,
            format: format,
            labelMode: labelMode,
            originalReference: raw,
            combinedPassageMode: combinedPassageMode,
            quotationStyle: quotationStyle
        )
    }

    private static func assertUpdateDownloadStaging() throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("BibleVerseReplacerSelfTest-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: tempDirectory)
        }

        let downloadURL = tempDirectory.appendingPathComponent("CFNetworkDownload_test.tmp")
        let payload = Data("zip payload".utf8)
        try payload.write(to: downloadURL)

        let stagedURL = try UpdateInstaller.stageDownloadedFile(at: downloadURL, tempDirectory: tempDirectory)
        guard stagedURL.lastPathComponent == "update.zip",
              FileManager.default.fileExists(atPath: stagedURL.path),
              !FileManager.default.fileExists(atPath: downloadURL.path),
              try Data(contentsOf: stagedURL) == payload else {
            throw TestFailure("Expected updater to synchronously move temporary download to stable update.zip")
        }
    }

    private static func assertUpdateDownloadStagingCreatesDestinationDirectory() throws {
        let rootDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("BibleVerseReplacerSelfTest-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.removeItem(at: rootDirectory)
        }

        let downloadURL = rootDirectory.appendingPathComponent("CFNetworkDownload_test.tmp")
        let payload = Data("zip payload".utf8)
        try payload.write(to: downloadURL)

        let missingTempDirectory = rootDirectory.appendingPathComponent("missing/staging", isDirectory: true)
        let stagedURL = try UpdateInstaller.stageDownloadedFile(at: downloadURL, tempDirectory: missingTempDirectory)
        guard FileManager.default.fileExists(atPath: stagedURL.path),
              try Data(contentsOf: stagedURL) == payload else {
            throw TestFailure("Expected updater to create the staging directory before moving the download")
        }
    }

    private static func assertUpdateDownloadStagingReportsMissingSource() throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("BibleVerseReplacerSelfTest-\(UUID().uuidString)", isDirectory: true)
        defer {
            try? FileManager.default.removeItem(at: tempDirectory)
        }

        let missingDownload = tempDirectory.appendingPathComponent("CFNetworkDownload_missing.tmp")
        do {
            _ = try UpdateInstaller.stageDownloadedFile(at: missingDownload, tempDirectory: tempDirectory)
            throw TestFailure("Expected updater staging to fail when the download has already been removed")
        } catch {
            guard error.localizedDescription.contains("下载临时文件") else {
                throw TestFailure("Expected missing download error, got \(error.localizedDescription)")
            }
        }
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
