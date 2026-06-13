using System.Collections.Generic;
using System.Text;

namespace BibleVerseReplacer.Windows
{
    internal sealed class VerseFormatter
    {
        public string Format(
            VerseReference reference,
            IList<BibleVerse> verses,
            OutputFormat format,
            ReferenceLabelMode labelMode,
            string originalReference)
        {
            switch (format)
            {
                case OutputFormat.ContinuousText:
                    return ApplyLabelIfNeeded(reference, JoinContinuous(verses), labelMode, originalReference, " ");
                case OutputFormat.ReferenceHeader:
                    return reference.DisplayText + "\r\n" + JoinLines(verses, false, reference);
                case OutputFormat.NumberedVerses:
                    return ApplyLabelIfNeeded(reference, JoinNumbered(verses), labelMode, originalReference, "\r\n");
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

        private static string ApplyLabelIfNeeded(
            VerseReference reference,
            string body,
            ReferenceLabelMode labelMode,
            string originalReference,
            string separator)
        {
            string label = LabelText(reference, labelMode, originalReference);
            if (string.IsNullOrEmpty(label))
            {
                return body;
            }
            return label + separator + body;
        }

        private static string LabelText(VerseReference reference, ReferenceLabelMode labelMode, string originalReference)
        {
            switch (labelMode)
            {
                case ReferenceLabelMode.PreserveInput:
                    return CleanOriginalReference(originalReference);
                case ReferenceLabelMode.Omit:
                    return null;
                default:
                    return reference.DisplayText;
            }
        }

        private static string CleanOriginalReference(string raw)
        {
            string text = (raw ?? string.Empty)
                .Trim()
                .Replace('\n', ' ')
                .Replace('\t', ' ')
                .Trim('"', '\'', '“', '”', ' ', '\r', '\n', '\t');

            while (text.Contains("  "))
            {
                text = text.Replace("  ", " ");
            }
            return text;
        }
    }
}
