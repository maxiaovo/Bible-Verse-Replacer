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
