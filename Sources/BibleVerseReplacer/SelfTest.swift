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

            let numberedFootnoteVerses = [
                ("马太福音 18:11", "马太福音 18:11 （有古卷加：人子来，为要拯救失丧的人。）"),
                ("马太福音 23:14", "马太福音 23:14 （有古卷加：你们这假冒为善的文士和法利赛人有祸了！因为你们侵吞寡妇的家产，假意做很长的祷告，所以要受更重的刑罚。）"),
                ("马可福音 7:16", "马可福音 7:16 （有古卷加：有耳可听的，就应当听！）"),
                ("马可福音 15:28", "马可福音 15:28 （有古卷加：这就应了经上的话说：他被列在罪犯之中。）"),
                ("路加福音 17:36", "路加福音 17:36 （有古卷加：两个人在田里，要取去一个，撇下一个。）"),
                ("路加福音 23:17", "路加福音 23:17 （有古卷加：每逢这节期，巡抚必须释放一个囚犯给他们。）"),
                ("约翰福音 5:4", "约翰福音 5:4 （有古卷加：因为有天使按时下池子搅动那水，水动之后，谁先下去，无论害什么病就痊愈了。）"),
                ("使徒行传 8:37", "使徒行传 8:37 （有古卷加：腓利说：“你若是一心相信，就可以。”他回答说：“我信耶稣基督是神的儿子。”）"),
                ("使徒行传 15:34", "使徒行传 15:34 （有古卷加：惟有西拉定意仍住在那里。）"),
                ("使徒行传 24:7", "使徒行传 24:7 （有古卷加：不料，千夫长吕西亚前来，甚是强横，从我们手中把他夺去，吩咐告他的人到你这里来。）"),
                ("使徒行传 28:29", "使徒行传 28:29 （有古卷加：保罗说了这话，犹太人议论纷纷地就走了。）")
            ]
            for (raw, expected) in numberedFootnoteVerses {
                try assertFormatted(
                    raw: raw,
                    expected: expected,
                    parser: parser,
                    formatter: formatter,
                    format: .referenceVerseLines
                )
            }

            try assertFormatted(
                raw: "马太福音 23:14",
                expected: "马太福音 23:14 （有古卷加：你们这假冒为善的文士和法利赛人有祸了！因为你们侵吞寡妇的家产，假意做很长的祷告，所以要受更重的刑罚。）",
                parser: parser,
                formatter: formatter,
                format: .continuousText,
                labelMode: .normalizedFull
            )

            try assertFormatted(
                raw: "马太福音 23:14",
                expected: "马太福音 23:14\n（有古卷加：你们这假冒为善的文士和法利赛人有祸了！因为你们侵吞寡妇的家产，假意做很长的祷告，所以要受更重的刑罚。）",
                parser: parser,
                formatter: formatter,
                format: .referenceHeader,
                labelMode: .normalizedFull
            )

            try assertFormatted(
                raw: "马太福音 23:14",
                expected: "马太福音 23:14\n14 （有古卷加：你们这假冒为善的文士和法利赛人有祸了！因为你们侵吞寡妇的家产，假意做很长的祷告，所以要受更重的刑罚。）",
                parser: parser,
                formatter: formatter,
                format: .numberedVerses,
                labelMode: .normalizedFull
            )

            try assertFormatted(
                raw: "马太福音 23:13-15",
                expected: "马太福音 23:13 「你们这假冒为善的文士和法利赛人有祸了！因为你们正当人前，把天国的门关了，自己不进去，正要进去的人，你们也不容他们进去。\n马太福音 23:14 （有古卷加：你们这假冒为善的文士和法利赛人有祸了！因为你们侵吞寡妇的家产，假意做很长的祷告，所以要受更重的刑罚。）\n马太福音 23:15 「你们这假冒为善的文士和法利赛人有祸了！因为你们走遍洋海陆地，勾引一个人入教，既入了教，却使他作地狱之子，比你们还加倍。",
                parser: parser,
                formatter: formatter,
                format: .referenceVerseLines,
                labelMode: .normalizedFull,
                quotationStyle: .square
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

            let annotatedArticle = "已经替换：马太福音 23:14 （有古卷加：你们这假冒为善的文士和法利赛人有祸了！因为你们侵吞寡妇的家产，假意做很长的祷告，所以要受更重的刑罚。）"
            let annotatedArticleResult = articleReplacer.replaceReferences(
                in: annotatedArticle,
                format: .continuousText,
                labelMode: .normalizedFull,
                combinedPassageMode: .compactEllipsis,
                quotationStyle: .fullWidth
            )
            if annotatedArticleResult.replacements != 0 ||
                annotatedArticleResult.skippedExisting != 1 ||
                annotatedArticleResult.text != annotatedArticle {
                throw TestFailure("Expected annotated footnote verse to remain unchanged, got \(annotatedArticleResult.text)")
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
