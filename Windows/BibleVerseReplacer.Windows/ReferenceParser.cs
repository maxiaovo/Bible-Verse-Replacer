using System;
using System.Text;
using System.Text.RegularExpressions;

namespace BibleVerseReplacer.Windows
{
    internal sealed class ReferenceParser
    {
        private static readonly Regex ReferenceRegex = new Regex(
            @"^(.+?)\s*([0-9]{1,3})\s*:\s*([0-9]{1,3})(?:\s*-\s*([0-9]{1,3}))?\s*$",
            RegexOptions.Compiled);

        public VerseReference Parse(string rawSelection)
        {
            string normalized = NormalizeSelection(rawSelection);
            if (normalized.Length == 0)
            {
                throw new FormatException("没有选中文字");
            }

            Match match = ReferenceRegex.Match(normalized);
            if (!match.Success)
            {
                throw new FormatException("未识别到经文引用");
            }

            string bookText = match.Groups[1].Value.Trim();
            BibleBook book = BibleBookCatalog.Find(bookText);
            if (book == null)
            {
                throw new FormatException("未识别书卷：" + bookText);
            }

            int chapter = int.Parse(match.Groups[2].Value);
            int startVerse = int.Parse(match.Groups[3].Value);
            int endVerse = match.Groups[4].Success ? int.Parse(match.Groups[4].Value) : startVerse;
            if (startVerse > endVerse)
            {
                throw new FormatException("范围顺序不正确");
            }

            return new VerseReference(book, chapter, startVerse, endVerse);
        }

        private static string NormalizeSelection(string raw)
        {
            string text = (raw ?? string.Empty).Trim()
                .Replace('\n', ' ')
                .Replace('\t', ' ')
                .Replace("：", ":")
                .Replace("﹕", ":")
                .Replace("－", "-")
                .Replace("–", "-")
                .Replace("—", "-")
                .Replace("﹣", "-")
                .Replace("至", "-")
                .Replace("“", string.Empty)
                .Replace("”", string.Empty)
                .Replace("\"", string.Empty)
                .Replace("'", string.Empty);

            text = ConvertFullWidthDigits(text);
            while (text.Contains("  "))
            {
                text = text.Replace("  ", " ");
            }
            return text.Trim();
        }

        private static string ConvertFullWidthDigits(string text)
        {
            StringBuilder builder = new StringBuilder(text.Length);
            foreach (char ch in text)
            {
                if (ch >= '０' && ch <= '９')
                {
                    builder.Append((char)('0' + (ch - '０')));
                }
                else
                {
                    builder.Append(ch);
                }
            }
            return builder.ToString();
        }
    }
}

