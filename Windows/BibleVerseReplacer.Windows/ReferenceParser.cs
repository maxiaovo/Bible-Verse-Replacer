using System;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

namespace BibleVerseReplacer.Windows
{
    internal sealed class ReferenceParser
    {
        private static readonly Regex CrossChapterRegex = new Regex(@"^(\d+):(\d+)-(\d+):(\d+)$", RegexOptions.Compiled);
        private static readonly Regex SameChapterRangeRegex = new Regex(@"^(\d+):(\d+)-(\d+)$", RegexOptions.Compiled);
        private static readonly Regex SingleVerseRegex = new Regex(@"^(\d+):(\d+)$", RegexOptions.Compiled);
        private static readonly Regex WholeChapterRegex = new Regex(@"^第?(\d+)章(?:第?(\d+)(?:-(\d+))?节?)?$", RegexOptions.Compiled);
        private static readonly Regex InheritedVerseWithJieRegex = new Regex(@"^第?(\d+)(?:-(\d+))?节$", RegexOptions.Compiled);
        private static readonly Regex InheritedVerseRangeRegex = new Regex(@"^(\d+)-(\d+)$", RegexOptions.Compiled);
        private static readonly Regex NumberOnlyRegex = new Regex(@"^(\d+)$", RegexOptions.Compiled);

        public ParsedReference ParseSelection(string rawSelection)
        {
            string normalized = NormalizeSelection(rawSelection);
            if (normalized.Length == 0)
            {
                throw new FormatException("没有选中文字");
            }

            string[] rawChunks = normalized.Split(',');
            List<PassageReference> passages = new List<PassageReference>();
            BibleBook currentBook = null;
            int? currentChapter = null;

            foreach (string rawChunk in rawChunks)
            {
                string chunk = rawChunk.Trim();
                if (chunk.Length == 0)
                {
                    continue;
                }

                ParsedChunk parsed = ParseChunk(chunk, currentBook, currentChapter);
                passages.Add(parsed.Passage);
                currentBook = parsed.Passage.Book;
                currentChapter = parsed.ContextChapter;
            }

            if (passages.Count == 0)
            {
                throw new FormatException("未识别到经文引用");
            }

            return new ParsedReference(passages);
        }

        public VerseReference Parse(string rawSelection)
        {
            ParsedReference parsed = ParseSelection(rawSelection);
            if (parsed.Passages.Count != 1)
            {
                throw new FormatException("未识别到经文引用");
            }

            PassageReference passage = parsed.Passages[0];
            if (passage.StartChapter != passage.EndChapter || !passage.StartVerse.HasValue || !passage.EndVerse.HasValue)
            {
                throw new FormatException("未识别到经文引用");
            }

            return new VerseReference(passage.Book, passage.StartChapter, passage.StartVerse.Value, passage.EndVerse.Value);
        }

        private static string NormalizeSelection(string raw)
        {
            string text = (raw ?? string.Empty).Trim()
                .Replace('\n', ' ')
                .Replace('\t', ' ')
                .Replace('\u3000', ' ')
                .Replace("：", ":")
                .Replace("﹕", ":")
                .Replace("“", string.Empty)
                .Replace("”", string.Empty)
                .Replace("\"", string.Empty)
                .Replace("'", string.Empty);

            text = ConvertFullWidthDigits(text);
            text = NormalizeRanges(text);
            text = NormalizeSeparators(text);
            while (text.Contains("  "))
            {
                text = text.Replace("  ", " ");
            }
            return text.Trim();
        }

        private static string NormalizeRanges(string text)
        {
            string[] tokens = { "……", "...", "——", "--", "－", "–", "—", "―", "﹣", "～", "~", "^", "到", "至" };
            foreach (string token in tokens)
            {
                text = text.Replace(token, "-");
            }

            return Regex.Replace(text, @"(?i)(\d)\s*to\s*(\d)", "$1-$2");
        }

        private static string NormalizeSeparators(string text)
        {
            string[] tokens = { "，", "、", "；", ";", "｜", "|", "\\" };
            foreach (string token in tokens)
            {
                text = text.Replace(token, ",");
            }
            return text;
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

        private static ParsedChunk ParseChunk(string rawChunk, BibleBook currentBook, int? currentChapter)
        {
            string compact = rawChunk.Trim().ToLowerInvariant().Replace(" ", string.Empty);
            if (compact.Length == 0)
            {
                throw new FormatException("未识别到经文引用");
            }

            BibleBook book = currentBook;
            string body = compact;
            BibleBook matchedBook;
            string remaining;
            if (BibleBookCatalog.FindAtStart(compact, out matchedBook, out remaining))
            {
                book = matchedBook;
                body = remaining;
            }

            if (book == null)
            {
                throw new FormatException("未识别书卷：" + rawChunk);
            }

            PassageReference passage = ParseChapterStyle(body, book, currentChapter)
                ?? ParseColonStyle(body, book)
                ?? ParseInheritedVerseStyle(body, book, currentChapter);

            if (passage == null)
            {
                throw new FormatException("未识别到经文引用");
            }

            return new ParsedChunk(passage, passage.EndChapter);
        }

        private static PassageReference ParseChapterStyle(string body, BibleBook book, int? currentChapter)
        {
            if (!body.Contains("章") && !body.Contains("节"))
            {
                return null;
            }

            Match match = WholeChapterRegex.Match(body);
            if (match.Success)
            {
                int chapter = int.Parse(match.Groups[1].Value);
                int? startVerse = match.Groups[2].Success ? (int?)int.Parse(match.Groups[2].Value) : null;
                int? endVerse = match.Groups[3].Success ? (int?)int.Parse(match.Groups[3].Value) : startVerse;
                if (startVerse.HasValue && endVerse.HasValue && startVerse.Value > endVerse.Value)
                {
                    throw new FormatException("范围顺序不正确");
                }
                return new PassageReference(book, chapter, startVerse, chapter, endVerse);
            }

            match = InheritedVerseWithJieRegex.Match(body);
            if (match.Success && currentChapter.HasValue)
            {
                int startVerse = int.Parse(match.Groups[1].Value);
                int endVerse = match.Groups[2].Success ? int.Parse(match.Groups[2].Value) : startVerse;
                if (startVerse > endVerse)
                {
                    throw new FormatException("范围顺序不正确");
                }
                return new PassageReference(book, currentChapter.Value, startVerse, currentChapter.Value, endVerse);
            }

            return null;
        }

        private static PassageReference ParseColonStyle(string body, BibleBook book)
        {
            Match match = CrossChapterRegex.Match(body);
            if (match.Success)
            {
                int startChapter = int.Parse(match.Groups[1].Value);
                int startVerse = int.Parse(match.Groups[2].Value);
                int endChapter = int.Parse(match.Groups[3].Value);
                int endVerse = int.Parse(match.Groups[4].Value);
                if (startChapter > endChapter || (startChapter == endChapter && startVerse > endVerse))
                {
                    throw new FormatException("范围顺序不正确");
                }
                return new PassageReference(book, startChapter, startVerse, endChapter, endVerse);
            }

            match = SameChapterRangeRegex.Match(body);
            if (match.Success)
            {
                int chapter = int.Parse(match.Groups[1].Value);
                int startVerse = int.Parse(match.Groups[2].Value);
                int endVerse = int.Parse(match.Groups[3].Value);
                if (startVerse > endVerse)
                {
                    throw new FormatException("范围顺序不正确");
                }
                return new PassageReference(book, chapter, startVerse, chapter, endVerse);
            }

            match = SingleVerseRegex.Match(body);
            if (match.Success)
            {
                int chapter = int.Parse(match.Groups[1].Value);
                int verse = int.Parse(match.Groups[2].Value);
                return new PassageReference(book, chapter, verse, chapter, verse);
            }

            return null;
        }

        private static PassageReference ParseInheritedVerseStyle(string body, BibleBook book, int? currentChapter)
        {
            Match match = InheritedVerseRangeRegex.Match(body);
            if (match.Success && currentChapter.HasValue)
            {
                int startVerse = int.Parse(match.Groups[1].Value);
                int endVerse = int.Parse(match.Groups[2].Value);
                if (startVerse > endVerse)
                {
                    throw new FormatException("范围顺序不正确");
                }
                return new PassageReference(book, currentChapter.Value, startVerse, currentChapter.Value, endVerse);
            }

            match = NumberOnlyRegex.Match(body);
            if (match.Success)
            {
                int number = int.Parse(match.Groups[1].Value);
                if (currentChapter.HasValue)
                {
                    return new PassageReference(book, currentChapter.Value, number, currentChapter.Value, number);
                }
                return new PassageReference(book, number, null, number, null);
            }

            return null;
        }

        private sealed class ParsedChunk
        {
            public ParsedChunk(PassageReference passage, int contextChapter)
            {
                Passage = passage;
                ContextChapter = contextChapter;
            }

            public PassageReference Passage { get; private set; }
            public int ContextChapter { get; private set; }
        }
    }
}
