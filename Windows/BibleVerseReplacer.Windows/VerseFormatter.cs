using System.Collections.Generic;
using System.Text;

namespace BibleVerseReplacer.Windows
{
    internal sealed class VerseFormatter
    {
        public string Format(
            ParsedReference parsedReference,
            IList<BibleVerse> verses,
            OutputFormat format,
            ReferenceLabelMode labelMode,
            string originalReference)
        {
            return Format(
                parsedReference,
                verses,
                null,
                format,
                labelMode,
                originalReference,
                CombinedPassageMode.CompactEllipsis,
                QuotationStyle.FullWidth);
        }

        public string Format(
            ParsedReference parsedReference,
            IList<BibleVerse> verses,
            IList<PassageVerseGroup> verseGroups,
            OutputFormat format,
            ReferenceLabelMode labelMode,
            string originalReference,
            CombinedPassageMode combinedPassageMode)
        {
            return Format(
                parsedReference,
                verses,
                verseGroups,
                format,
                labelMode,
                originalReference,
                combinedPassageMode,
                QuotationStyle.FullWidth);
        }

        public string Format(
            ParsedReference parsedReference,
            IList<BibleVerse> verses,
            IList<PassageVerseGroup> verseGroups,
            OutputFormat format,
            ReferenceLabelMode labelMode,
            string originalReference,
            CombinedPassageMode combinedPassageMode,
            QuotationStyle quotationStyle)
        {
            switch (format)
            {
                case OutputFormat.ContinuousText:
                    return FormatContinuous(parsedReference, verses, verseGroups, labelMode, originalReference, combinedPassageMode, quotationStyle);
                case OutputFormat.ReferenceHeader:
                    return parsedReference.DisplayText + "\r\n" + JoinLines(verses, false, null, quotationStyle);
                case OutputFormat.NumberedVerses:
                    return ApplyLabelIfNeeded(parsedReference, JoinNumbered(verses, quotationStyle), labelMode, originalReference, "\r\n");
                default:
                    return JoinLines(verses, true, null, quotationStyle);
            }
        }

        public string Format(
            VerseReference reference,
            IList<BibleVerse> verses,
            OutputFormat format,
            ReferenceLabelMode labelMode,
            string originalReference)
        {
            return Format(
                new ParsedReference(new List<PassageReference> { new PassageReference(reference) }),
                verses,
                format,
                labelMode,
                originalReference);
        }

        private static string FormatContinuous(
            ParsedReference parsedReference,
            IList<BibleVerse> verses,
            IList<PassageVerseGroup> verseGroups,
            ReferenceLabelMode labelMode,
            string originalReference,
            CombinedPassageMode combinedPassageMode,
            QuotationStyle quotationStyle)
        {
            if (verseGroups == null || verseGroups.Count == 0)
            {
                return ApplyLabelIfNeeded(parsedReference, JoinContinuous(verses, quotationStyle), labelMode, originalReference, " ");
            }

            if (combinedPassageMode == CombinedPassageMode.GroupedLines)
            {
                return JoinGroupedContinuous(verseGroups, labelMode, originalReference, quotationStyle);
            }

            return ApplyLabelTextIfNeeded(
                LabelText(parsedReference, labelMode, originalReference, parsedReference.CompactDisplayText),
                JoinGroupBodies(verseGroups, "……", quotationStyle),
                " ");
        }

        private static string JoinLines(IList<BibleVerse> verses, bool includeBook, VerseReference reference, QuotationStyle quotationStyle)
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
                    builder.Append(reference == null ? BibleBookCatalog.Find(verse.Book).ChineseName : reference.Book.ChineseName);
                    builder.Append(' ');
                    builder.Append(verse.ReferenceVerseText);
                    builder.Append(' ');
                }
                builder.Append(CleanText(verse.Text, quotationStyle));
            }
            return builder.ToString();
        }

        private static string JoinNumbered(IList<BibleVerse> verses, QuotationStyle quotationStyle)
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
                builder.Append(CleanText(verse.Text, quotationStyle));
            }
            return builder.ToString();
        }

        private static string JoinContinuous(IList<BibleVerse> verses, QuotationStyle quotationStyle)
        {
            StringBuilder builder = new StringBuilder();
            foreach (BibleVerse verse in verses)
            {
                builder.Append(CleanText(verse.Text, quotationStyle));
            }
            return builder.ToString();
        }

        private static string JoinGroupBodies(IList<PassageVerseGroup> verseGroups, string separator, QuotationStyle quotationStyle)
        {
            StringBuilder builder = new StringBuilder();
            for (int index = 0; index < verseGroups.Count; index++)
            {
                if (index > 0)
                {
                    builder.Append(separator);
                }
                builder.Append(JoinContinuous(verseGroups[index].Verses, quotationStyle));
            }
            return builder.ToString();
        }

        private static string JoinGroupedContinuous(
            IList<PassageVerseGroup> verseGroups,
            ReferenceLabelMode labelMode,
            string originalReference,
            QuotationStyle quotationStyle)
        {
            StringBuilder builder = new StringBuilder();
            for (int index = 0; index < verseGroups.Count; index++)
            {
                if (index > 0)
                {
                    builder.Append("\r\n");
                }

                PassageVerseGroup group = verseGroups[index];
                builder.Append(ApplyLabelTextIfNeeded(
                    GroupLabelText(group, verseGroups.Count, labelMode, originalReference),
                    JoinContinuous(group.Verses, quotationStyle),
                    " "));
            }
            return builder.ToString();
        }

        public static string CleanText(string text, QuotationStyle quotationStyle)
        {
            return ApplyQuotationStyle(text ?? string.Empty, quotationStyle).Replace("\u3000", string.Empty).Trim();
        }

        private static string ApplyQuotationStyle(string text, QuotationStyle quotationStyle)
        {
            switch (quotationStyle)
            {
                case QuotationStyle.HalfWidth:
                    return text.Replace("「", "\"").Replace("」", "\"");
                case QuotationStyle.Square:
                    return text;
                default:
                    return text.Replace("「", "“").Replace("」", "”");
            }
        }

        private static string ApplyLabelIfNeeded(
            ParsedReference parsedReference,
            string body,
            ReferenceLabelMode labelMode,
            string originalReference,
            string separator)
        {
            string label = LabelText(parsedReference, labelMode, originalReference);
            return ApplyLabelTextIfNeeded(label, body, separator);
        }

        private static string ApplyLabelTextIfNeeded(string label, string body, string separator)
        {
            if (string.IsNullOrEmpty(label))
            {
                return body;
            }
            return label + separator + body;
        }

        private static string LabelText(ParsedReference parsedReference, ReferenceLabelMode labelMode, string originalReference)
        {
            return LabelText(parsedReference, labelMode, originalReference, parsedReference.DisplayText);
        }

        private static string LabelText(ParsedReference parsedReference, ReferenceLabelMode labelMode, string originalReference, string normalizedLabel)
        {
            switch (labelMode)
            {
                case ReferenceLabelMode.PreserveInput:
                    return CleanOriginalReference(originalReference);
                case ReferenceLabelMode.Omit:
                    return null;
                default:
                    return normalizedLabel;
            }
        }

        private static string GroupLabelText(
            PassageVerseGroup group,
            int groupCount,
            ReferenceLabelMode labelMode,
            string originalReference)
        {
            switch (labelMode)
            {
                case ReferenceLabelMode.PreserveInput:
                    return groupCount == 1 ? CleanOriginalReference(originalReference) : group.Passage.DisplayText;
                case ReferenceLabelMode.Omit:
                    return null;
                default:
                    return group.Passage.DisplayText;
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
