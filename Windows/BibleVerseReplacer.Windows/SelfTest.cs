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

                AssertFormatted(parser, formatter, "创世记 1:1", OutputFormat.ReferenceVerseLines, ReferenceLabelMode.NormalizedFull, "创世记 1:1 起初，神创造天地。", false);
                AssertFormatted(parser, formatter, "创 1:1", OutputFormat.ContinuousText, ReferenceLabelMode.NormalizedFull, "创世记 1:1 起初，神创造天地。", false);
                AssertFormatted(parser, formatter, "创 1:1", OutputFormat.ContinuousText, ReferenceLabelMode.PreserveInput, "创 1:1 起初，神创造天地。", false);
                AssertFormatted(parser, formatter, "创 1:1", OutputFormat.ContinuousText, ReferenceLabelMode.Omit, "起初，神创造天地。", false);
                AssertFormatted(parser, formatter, "创3：2－5", OutputFormat.ReferenceVerseLines, ReferenceLabelMode.NormalizedFull, "创世记 3:2 女人对蛇说", true);
                AssertFormatted(parser, formatter, "\"Genesis 4:1\"", OutputFormat.ReferenceVerseLines, ReferenceLabelMode.NormalizedFull, "创世记 4:1 有一日，那人和他妻子夏娃同房", true);
                AssertFormatted(parser, formatter, "创世记 24:29-30", OutputFormat.ReferenceVerseLines, ReferenceLabelMode.NormalizedFull, "创世记 24:29-30 利百加有一个哥哥", true);
                AssertContains(parser, formatter, "创世记 3:2,5,7-9", "创世记 3:2 女人对蛇说", "创世记 3:5 因为神知道", "创世记 3:9 耶和华神呼唤那人");
                AssertContains(parser, formatter, "创世记 3:2、5，7-9", "创世记 3:2 女人对蛇说", "创世记 3:5 因为神知道", "创世记 3:7 他们二人的眼睛就明亮了");
                AssertContains(parser, formatter, "创世记 3:24 -4:2", "创世记 3:24 于是把他赶出去了", "创世记 4:1 有一日，那人和他妻子夏娃同房", "创世记 4:2 又生了该隐的兄弟亚伯");
                AssertContains(parser, formatter, "创世记第3章", "创世记 3:1 耶和华神所造的", "创世记 3:24 于是把他赶出去了");
                AssertContains(parser, formatter, "约 3:16，罗 8:28", "约翰福音 3:16 「神爱世人", "罗马书 8:28 我们晓得万事都互相效力");
                AssertContains(parser, formatter, "创世记 3:2-5，4:1", "创世记 3:2 女人对蛇说", "创世记 3:5 因为神知道", "创世记 4:1 有一日，那人和他妻子夏娃同房");

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
            string actual = formatter.Format(reference, BibleStore.Instance.VersesFor(reference), OutputFormat.ReferenceVerseLines, ReferenceLabelMode.NormalizedFull, raw);
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
            ParsedReference reference = parser.ParseSelection(raw);
            string actual = formatter.Format(reference, BibleStore.Instance.VersesFor(reference), outputFormat, labelMode, raw);
            bool ok = prefixOnly ? actual.StartsWith(expected, StringComparison.Ordinal) : actual == expected;
            if (!ok)
            {
                throw new InvalidOperationException("For " + raw + ", expected " + expected + ", got " + actual);
            }
        }
    }
}
