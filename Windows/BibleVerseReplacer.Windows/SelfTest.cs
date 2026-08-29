using System;

namespace BibleVerseReplacer.Windows
{
    internal static class SelfTest
    {
        public static int Run()
        {
            try
            {
                BibleStore.Instance.Load();
                ReferenceParser parser = new ReferenceParser();
                VerseFormatter formatter = new VerseFormatter();
                ArticleReferenceReplacer articleReplacer = new ArticleReferenceReplacer(parser, formatter);

                AssertFormatted(parser, formatter, "创世记 1:1", OutputFormat.ReferenceVerseLines, ReferenceLabelMode.NormalizedFull, "创世记 1:1 起初，神创造天地。", false);
                string[,] numberedFootnoteVerses =
                {
                    { "马太福音 18:11", "马太福音 18:11 （有古卷加：人子来，为要拯救失丧的人。）" },
                    { "马太福音 23:14", "马太福音 23:14 （有古卷加：你们这假冒为善的文士和法利赛人有祸了！因为你们侵吞寡妇的家产，假意做很长的祷告，所以要受更重的刑罚。）" },
                    { "马可福音 7:16", "马可福音 7:16 （有古卷加：有耳可听的，就应当听！）" },
                    { "马可福音 15:28", "马可福音 15:28 （有古卷加：这就应了经上的话说：他被列在罪犯之中。）" },
                    { "路加福音 17:36", "路加福音 17:36 （有古卷加：两个人在田里，要取去一个，撇下一个。）" },
                    { "路加福音 23:17", "路加福音 23:17 （有古卷加：每逢这节期，巡抚必须释放一个囚犯给他们。）" },
                    { "约翰福音 5:4", "约翰福音 5:4 （有古卷加：因为有天使按时下池子搅动那水，水动之后，谁先下去，无论害什么病就痊愈了。）" },
                    { "使徒行传 8:37", "使徒行传 8:37 （有古卷加：腓利说：“你若是一心相信，就可以。”他回答说：“我信耶稣基督是神的儿子。”）" },
                    { "使徒行传 15:34", "使徒行传 15:34 （有古卷加：惟有西拉定意仍住在那里。）" },
                    { "使徒行传 24:7", "使徒行传 24:7 （有古卷加：不料，千夫长吕西亚前来，甚是强横，从我们手中把他夺去，吩咐告他的人到你这里来。）" },
                    { "使徒行传 28:29", "使徒行传 28:29 （有古卷加：保罗说了这话，犹太人议论纷纷地就走了。）" }
                };
                for (int index = 0; index < numberedFootnoteVerses.GetLength(0); index++)
                {
                    AssertFormatted(parser, formatter, numberedFootnoteVerses[index, 0], OutputFormat.ReferenceVerseLines, ReferenceLabelMode.NormalizedFull, numberedFootnoteVerses[index, 1], false);
                }

                AssertFormatted(parser, formatter, "马太福音 23:14", OutputFormat.ContinuousText, ReferenceLabelMode.NormalizedFull, "马太福音 23:14 （有古卷加：你们这假冒为善的文士和法利赛人有祸了！因为你们侵吞寡妇的家产，假意做很长的祷告，所以要受更重的刑罚。）", false);
                AssertFormatted(parser, formatter, "马太福音 23:14", OutputFormat.ReferenceHeader, ReferenceLabelMode.NormalizedFull, "马太福音 23:14\r\n（有古卷加：你们这假冒为善的文士和法利赛人有祸了！因为你们侵吞寡妇的家产，假意做很长的祷告，所以要受更重的刑罚。）", false);
                AssertFormatted(parser, formatter, "马太福音 23:14", OutputFormat.NumberedVerses, ReferenceLabelMode.NormalizedFull, "马太福音 23:14\r\n14 （有古卷加：你们这假冒为善的文士和法利赛人有祸了！因为你们侵吞寡妇的家产，假意做很长的祷告，所以要受更重的刑罚。）", false);
                AssertFormatted(
                    parser,
                    formatter,
                    "马太福音 23:13-15",
                    OutputFormat.ReferenceVerseLines,
                    ReferenceLabelMode.NormalizedFull,
                    CombinedPassageMode.CompactEllipsis,
                    QuotationStyle.Square,
                    "马太福音 23:13 「你们这假冒为善的文士和法利赛人有祸了！因为你们正当人前，把天国的门关了，自己不进去，正要进去的人，你们也不容他们进去。\r\n马太福音 23:14 （有古卷加：你们这假冒为善的文士和法利赛人有祸了！因为你们侵吞寡妇的家产，假意做很长的祷告，所以要受更重的刑罚。）\r\n马太福音 23:15 「你们这假冒为善的文士和法利赛人有祸了！因为你们走遍洋海陆地，勾引一个人入教，既入了教，却使他作地狱之子，比你们还加倍。",
                    false);
                AssertFormatted(parser, formatter, "创 1:1", OutputFormat.ContinuousText, ReferenceLabelMode.NormalizedFull, "创世记 1:1 起初，神创造天地。", false);
                AssertFormatted(parser, formatter, "创 1:1", OutputFormat.ContinuousText, ReferenceLabelMode.PreserveInput, "创 1:1 起初，神创造天地。", false);
                AssertFormatted(parser, formatter, "创 1:1", OutputFormat.ContinuousText, ReferenceLabelMode.Omit, "起初，神创造天地。", false);
                AssertFormatted(parser, formatter, "创世纪 1:1", OutputFormat.ContinuousText, ReferenceLabelMode.NormalizedFull, "创世记 1:1 起初，神创造天地。", false);
                AssertFormatted(parser, formatter, "马可 5:8", OutputFormat.ReferenceVerseLines, ReferenceLabelMode.NormalizedFull, "马可福音 5:8 是因耶稣曾吩咐他说", true);
                AssertFormatted(parser, formatter, "陆家 2:10", OutputFormat.ReferenceVerseLines, ReferenceLabelMode.NormalizedFull, "路加福音 2:10 那天使对他们说", true);
                AssertFormatted(parser, formatter, "约翰 3:16", OutputFormat.ReferenceVerseLines, ReferenceLabelMode.NormalizedFull, "约翰福音 3:16 “神爱世人", true);
                AssertFormatted(parser, formatter, "创1:1-3，7", OutputFormat.ContinuousText, ReferenceLabelMode.NormalizedFull, CombinedPassageMode.CompactEllipsis, "创世记 1:1-3,7 起初，神创造天地。地是空虚混沌，渊面黑暗；神的灵运行在水面上。神说：“要有光”，就有了光。……神就造出空气，将空气以下的水、空气以上的水分开了。事就这样成了。", false);
                AssertFormatted(parser, formatter, "创1:1-3，7", OutputFormat.ContinuousText, ReferenceLabelMode.NormalizedFull, CombinedPassageMode.GroupedLines, "创世记 1:1-3 起初，神创造天地。地是空虚混沌，渊面黑暗；神的灵运行在水面上。神说：“要有光”，就有了光。\r\n创世记 1:7 神就造出空气，将空气以下的水、空气以上的水分开了。事就这样成了。", false);
                AssertFormatted(parser, formatter, "创3：2－5", OutputFormat.ReferenceVerseLines, ReferenceLabelMode.NormalizedFull, "创世记 3:2 女人对蛇说", true);
                AssertFormatted(parser, formatter, "\"Genesis 4:1\"", OutputFormat.ReferenceVerseLines, ReferenceLabelMode.NormalizedFull, "创世记 4:1 有一日，那人和他妻子夏娃同房", true);
                AssertFormatted(parser, formatter, "创世记 24:29-30", OutputFormat.ReferenceVerseLines, ReferenceLabelMode.NormalizedFull, "创世记 24:29-30 利百加有一个哥哥", true);
                AssertContains(parser, formatter, "创世记 3:2,5,7-9", "创世记 3:2 女人对蛇说", "创世记 3:5 因为神知道", "创世记 3:9 耶和华神呼唤那人");
                AssertContains(parser, formatter, "创世记 3:2、5，7-9", "创世记 3:2 女人对蛇说", "创世记 3:5 因为神知道", "创世记 3:7 他们二人的眼睛就明亮了");
                AssertContains(parser, formatter, "创世记 3:24 -4:2", "创世记 3:24 于是把他赶出去了", "创世记 4:1 有一日，那人和他妻子夏娃同房", "创世记 4:2 又生了该隐的兄弟亚伯");
                AssertContains(parser, formatter, "创世记第3章", "创世记 3:1 耶和华神所造的", "创世记 3:24 于是把他赶出去了");
                AssertContains(parser, formatter, "约 3:16，罗 8:28", "约翰福音 3:16 “神爱世人", "罗马书 8:28 我们晓得万事都互相效力");
                AssertContains(parser, formatter, "创世记 3:2-5，4:1", "创世记 3:2 女人对蛇说", "创世记 3:5 因为神知道", "创世记 4:1 有一日，那人和他妻子夏娃同房");
                AssertFormatted(parser, formatter, "创1:3", OutputFormat.ContinuousText, ReferenceLabelMode.NormalizedFull, CombinedPassageMode.CompactEllipsis, QuotationStyle.HalfWidth, "创世记 1:3 神说：\"要有光\"，就有了光。", false);
                AssertFormatted(parser, formatter, "创1:3", OutputFormat.ContinuousText, ReferenceLabelMode.NormalizedFull, CombinedPassageMode.CompactEllipsis, QuotationStyle.Square, "创世记 1:3 神说：「要有光」，就有了光。", false);

                string[] rangeForms =
                {
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
                };
                foreach (string raw in rangeForms)
                {
                    AssertContains(parser, formatter, raw, "约翰三书 1:1 作长老的写信给亲爱的该犹", "约翰三书 1:3 有弟兄来证明你心里存的真理");
                }

                AssertContains(parser, formatter, "约三1:1\\1:2|1:3", "约翰三书 1:1 作长老的写信给亲爱的该犹", "约翰三书 1:2 亲爱的兄弟啊", "约翰三书 1:3 有弟兄来证明你心里存的真理");

                try
                {
                    parser.Parse("创世记 3:5-2");
                    throw new InvalidOperationException("Expected invalid range to throw");
                }
                catch (FormatException)
                {
                }

                string article = "今天读：创世记 1:1\r\n还有 马可 5:8\r\n已经替换：创世记 1:1 起初，神创造天地。";
                ArticleReplacementResult articleResult = articleReplacer.ReplaceReferences(
                    article,
                    OutputFormat.ContinuousText,
                    ReferenceLabelMode.NormalizedFull,
                    CombinedPassageMode.CompactEllipsis,
                    QuotationStyle.FullWidth);
                if (articleResult.Replacements != 2 || articleResult.SkippedExisting != 1)
                {
                    throw new InvalidOperationException("Expected 2 article replacements and 1 skip, got " + articleResult.Replacements + " replacements and " + articleResult.SkippedExisting + " skips");
                }
                AssertTextContains(articleResult.Text, "今天读：创世记 1:1 起初，神创造天地。");
                AssertTextContains(articleResult.Text, "还有 马可福音 5:8 是因耶稣曾吩咐他说");
                AssertTextContains(articleResult.Text, "已经替换：创世记 1:1 起初，神创造天地。");

                string annotatedArticle = "已经替换：马太福音 23:14 （有古卷加：你们这假冒为善的文士和法利赛人有祸了！因为你们侵吞寡妇的家产，假意做很长的祷告，所以要受更重的刑罚。）";
                ArticleReplacementResult annotatedArticleResult = articleReplacer.ReplaceReferences(
                    annotatedArticle,
                    OutputFormat.ContinuousText,
                    ReferenceLabelMode.NormalizedFull,
                    CombinedPassageMode.CompactEllipsis,
                    QuotationStyle.FullWidth);
                if (annotatedArticleResult.Replacements != 0 || annotatedArticleResult.SkippedExisting != 1 || annotatedArticleResult.Text != annotatedArticle)
                {
                    throw new InvalidOperationException("Expected annotated footnote verse to remain unchanged, got " + annotatedArticleResult.Text);
                }

                string inlineChineseArticle = "今天我读了创世记1:1";
                ArticleReplacementResult inlineChineseResult = articleReplacer.ReplaceReferences(
                    inlineChineseArticle,
                    OutputFormat.ContinuousText,
                    ReferenceLabelMode.NormalizedFull,
                    CombinedPassageMode.CompactEllipsis,
                    QuotationStyle.FullWidth);
                if (inlineChineseResult.Text != "今天我读了创世记 1:1 起初，神创造天地。")
                {
                    throw new InvalidOperationException("Expected inline Chinese article replacement, got " + inlineChineseResult.Text);
                }

                Console.WriteLine("Self-test passed");
                return 0;
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine("Self-test failed: " + ex.Message);
                return 1;
            }
        }

        private static void AssertContains(ReferenceParser parser, VerseFormatter formatter, string raw, params string[] expectedFragments)
        {
            ParsedReference reference = parser.ParseSelection(raw);
            string actual = formatter.Format(reference, BibleStore.Instance.VersesFor(reference), BibleStore.Instance.VerseGroupsFor(reference), OutputFormat.ReferenceVerseLines, ReferenceLabelMode.NormalizedFull, raw, CombinedPassageMode.CompactEllipsis);
            foreach (string expected in expectedFragments)
            {
                if (!actual.Contains(expected))
                {
                    throw new InvalidOperationException("For " + raw + ", expected output to contain " + expected + ", got " + actual);
                }
            }
        }

        private static void AssertFormatted(
            ReferenceParser parser,
            VerseFormatter formatter,
            string raw,
            OutputFormat outputFormat,
            ReferenceLabelMode labelMode,
            string expected,
            bool prefixOnly)
        {
            AssertFormatted(parser, formatter, raw, outputFormat, labelMode, CombinedPassageMode.CompactEllipsis, expected, prefixOnly);
        }

        private static void AssertFormatted(
            ReferenceParser parser,
            VerseFormatter formatter,
            string raw,
            OutputFormat outputFormat,
            ReferenceLabelMode labelMode,
            CombinedPassageMode combinedPassageMode,
            string expected,
            bool prefixOnly)
        {
            AssertFormatted(parser, formatter, raw, outputFormat, labelMode, combinedPassageMode, QuotationStyle.FullWidth, expected, prefixOnly);
        }

        private static void AssertFormatted(
            ReferenceParser parser,
            VerseFormatter formatter,
            string raw,
            OutputFormat outputFormat,
            ReferenceLabelMode labelMode,
            CombinedPassageMode combinedPassageMode,
            QuotationStyle quotationStyle,
            string expected,
            bool prefixOnly)
        {
            ParsedReference reference = parser.ParseSelection(raw);
            string actual = formatter.Format(reference, BibleStore.Instance.VersesFor(reference), BibleStore.Instance.VerseGroupsFor(reference), outputFormat, labelMode, raw, combinedPassageMode, quotationStyle);
            bool ok = prefixOnly ? actual.StartsWith(expected, StringComparison.Ordinal) : actual == expected;
            if (!ok)
            {
                throw new InvalidOperationException("For " + raw + ", expected " + expected + ", got " + actual);
            }
        }

        private static void AssertTextContains(string actual, string expected)
        {
            if (!actual.Contains(expected))
            {
                throw new InvalidOperationException("Expected output to contain " + expected + ", got " + actual);
            }
        }
    }
}
