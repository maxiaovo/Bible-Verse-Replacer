using System.Collections.Generic;
using System.Text;

namespace BibleVerseReplacer.Windows
{
    internal sealed class VerseFormatter
    {
        public string Format(VerseReference reference, IList<BibleVerse> verses, OutputFormat format)
        {
            switch (format)
            {
                case OutputFormat.ContinuousText:
                    return JoinContinuous(verses);
                case OutputFormat.ReferenceHeader:
                    return reference.DisplayText + "\r\n" + JoinLines(verses, false, reference);
                case OutputFormat.NumberedVerses:
                    return JoinNumbered(verses);
                default:
                    return JoinLines(verses, true, reference);
            }
        }

        private static string JoinLines(IList<BibleVerse> verses, bool includeBook, VerseReference reference)
        {
            StringBuilder builder = new StringBuilder();
            for (int index = 0; index < verses.Count; index++)
            {
                BibleVerse verse = verses[index];
                if (index > 0)
                {
                    builder.Append("\r\n");
                }
                if (includeBook)
                {
                    builder.Append(reference.Book.ChineseName);
                    builder.Append(' ');
                    builder.Append(verse.ReferenceVerseText);
                    builder.Append(' ');
                }
                builder.Append(CleanText(verse.Text));
            }
            return builder.ToString();
        }

        private static string JoinNumbered(IList<BibleVerse> verses)
        {
            StringBuilder builder = new StringBuilder();
            for (int index = 0; index < verses.Count; index++)
            {
                BibleVerse verse = verses[index];
                if (index > 0)
                {
                    builder.Append("\r\n");
                }
                builder.Append(verse.VerseLabel);
                builder.Append(' ');
                builder.Append(CleanText(verse.Text));
            }
            return builder.ToString();
        }

        private static string JoinContinuous(IList<BibleVerse> verses)
        {
            StringBuilder builder = new StringBuilder();
            foreach (BibleVerse verse in verses)
            {
                builder.Append(CleanText(verse.Text));
            }
            return builder.ToString();
        }

        private static string CleanText(string text)
        {
            return (text ?? string.Empty).Replace("\u3000", string.Empty).Trim();
        }
    }
}

