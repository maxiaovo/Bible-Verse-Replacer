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

        private static void AssertFormatted(
            ReferenceParser parser,
            VerseFormatter formatter,
            string raw,
            OutputFormat outputFormat,
            ReferenceLabelMode labelMode,
            string expected,
            bool prefixOnly)
        {
            VerseReference reference = parser.Parse(raw);
            string actual = formatter.Format(reference, BibleStore.Instance.VersesFor(reference), outputFormat, labelMode, raw);
            bool ok = prefixOnly ? actual.StartsWith(expected, StringComparison.Ordinal) : actual == expected;
            if (!ok)
            {
                throw new InvalidOperationException("For " + raw + ", expected " + expected + ", got " + actual);
            }
        }
    }
}
