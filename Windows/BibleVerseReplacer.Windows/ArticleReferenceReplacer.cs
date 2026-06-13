using System;
using System.Collections.Generic;
using System.Text;

namespace BibleVerseReplacer.Windows
{
    internal sealed class ArticleReplacementResult
    {
        public ArticleReplacementResult(string text, int replacements, int skippedExisting)
        {
            Text = text;
            Replacements = replacements;
            SkippedExisting = skippedExisting;
        }

        public string Text { get; private set; }
        public int Replacements { get; private set; }
        public int SkippedExisting { get; private set; }

        public bool Changed
        {
            get { return Replacements > 0; }
        }
    }

    internal sealed class ArticleReferenceReplacer
    {
        private readonly ReferenceParser parser;
        private readonly VerseFormatter formatter;

        public ArticleReferenceReplacer(ReferenceParser parser, VerseFormatter formatter)
        {
            this.parser = parser;
            this.formatter = formatter;
        }

        public ArticleReplacementResult ReplaceReferences(
            string article,
            OutputFormat format,
            ReferenceLabelMode labelMode,
            CombinedPassageMode combinedPassageMode,
            QuotationStyle quotationStyle)
        {
            StringBuilder builder = new StringBuilder();
            int cursor = 0;
            int replacements = 0;
            int skipped = 0;

            while (cursor < article.Length)
            {
                Candidate candidate;
                if (!NextCandidate(article, cursor, out candidate))
                {
                    builder.Append(article.Substring(cursor));
                    break;
                }

                builder.Append(article.Substring(cursor, candidate.Start - cursor));

                try
                {
                    ParsedReference reference = parser.ParseSelection(candidate.Raw);
                    List<PassageVerseGroup> verseGroups = BibleStore.Instance.VerseGroupsFor(reference);
                    List<BibleVerse> verses = BibleStore.Instance.VersesFor(reference);
                    if (ScriptureAlreadyPresent(article, candidate.End, verses, quotationStyle))
                    {
                        builder.Append(article.Substring(candidate.Start, candidate.End - candidate.Start));
                        skipped++;
                    }
                    else
                    {
                        builder.Append(formatter.Format(
                            reference,
                            verses,
                            verseGroups,
                            format,
                            labelMode,
                            candidate.Raw,
                            combinedPassageMode,
                            quotationStyle));
                        replacements++;
                    }
                    cursor = candidate.End;
                }
                catch
                {
                    builder.Append(article[candidate.Start]);
                    cursor = candidate.Start + 1;
                }
            }

            return new ArticleReplacementResult(builder.ToString(), replacements, skipped);
        }

        private static bool NextCandidate(string text, int start, out Candidate candidate)
        {
            for (int index = start; index < text.Length; index++)
            {
                if (IsReferenceStart(text, index))
                {
                    int end = CandidateEnd(text, index);
                    int trimmedEnd = TrimCandidateEnd(text, index, end);
                    if (trimmedEnd > index)
                    {
                        candidate = new Candidate(index, trimmedEnd, text.Substring(index, trimmedEnd - index));
                        return true;
                    }
                }
            }

            candidate = null;
            return false;
        }

        private static bool IsReferenceStart(string text, int index)
        {
            if (index > 0 && (char.IsLetterOrDigit(text[index - 1])))
            {
                return false;
            }

            BibleBook book;
            string remaining;
            if (!BibleBookCatalog.FindAtStart(text.Substring(index), out book, out remaining))
            {
                return false;
            }

            int lookahead = index + RawPrefixLength(book, text.Substring(index));
            while (lookahead < text.Length && char.IsWhiteSpace(text[lookahead]))
            {
                lookahead++;
            }
            return lookahead < text.Length && (char.IsDigit(text[lookahead]) || text[lookahead] == '第');
        }

        private static int RawPrefixLength(BibleBook book, string text)
        {
            List<string> aliases = new List<string>();
            aliases.Add(book.ChineseName);
            aliases.Add(book.Code);
            aliases.AddRange(book.Aliases);
            aliases.Sort((left, right) => right.Length.CompareTo(left.Length));
            foreach (string alias in aliases)
            {
                if (text.StartsWith(alias, StringComparison.OrdinalIgnoreCase))
                {
                    return alias.Length;
                }
            }
            return book.ChineseName.Length;
        }

        private static int CandidateEnd(string text, int start)
        {
            BibleBook book;
            string remaining;
            if (!BibleBookCatalog.FindAtStart(text.Substring(start), out book, out remaining))
            {
                return start;
            }

            int index = start + RawPrefixLength(book, text.Substring(start));
            while (index < text.Length && IsCandidateCharacter(text[index]))
            {
                index++;
            }
            return index;
        }

        private static bool IsCandidateCharacter(char ch)
        {
            if (char.IsDigit(ch) || char.IsWhiteSpace(ch))
            {
                return true;
            }
            if ("toTO".IndexOf(ch) >= 0)
            {
                return true;
            }
            return ":：﹕,，、;；|｜\\-－–—―﹣～~^.…第章节到至".IndexOf(ch) >= 0;
        }

        private static int TrimCandidateEnd(string text, int start, int end)
        {
            int trimmed = end;
            while (trimmed > start)
            {
                char previous = text[trimmed - 1];
                if (char.IsWhiteSpace(previous) || ",，、;；|｜\\".IndexOf(previous) >= 0)
                {
                    trimmed--;
                }
                else
                {
                    break;
                }
            }
            return trimmed;
        }

        private static bool ScriptureAlreadyPresent(
            string article,
            int index,
            IList<BibleVerse> verses,
            QuotationStyle quotationStyle)
        {
            if (verses.Count == 0)
            {
                return false;
            }

            int cursor = index;
            while (cursor < article.Length && (char.IsWhiteSpace(article[cursor]) || ":：".IndexOf(article[cursor]) >= 0))
            {
                cursor++;
            }

            string remaining = article.Substring(cursor);
            string expected = VerseFormatter.CleanText(verses[0].Text, quotationStyle);
            return NormalizedScripturePrefix(remaining).StartsWith(
                NormalizedScripturePrefix(expected.Length > 12 ? expected.Substring(0, 12) : expected),
                StringComparison.Ordinal);
        }

        private static string NormalizedScripturePrefix(string text)
        {
            StringBuilder builder = new StringBuilder();
            int limit = Math.Min(30, text.Length);
            for (int index = 0; index < limit; index++)
            {
                char ch = text[index];
                if (char.IsWhiteSpace(ch))
                {
                    continue;
                }
                if (ch == '「' || ch == '」' || ch == '“' || ch == '”')
                {
                    builder.Append('"');
                }
                else
                {
                    builder.Append(ch);
                }
            }
            return builder.ToString();
        }

        private sealed class Candidate
        {
            public Candidate(int start, int end, string raw)
            {
                Start = start;
                End = end;
                Raw = raw;
            }

            public int Start { get; private set; }
            public int End { get; private set; }
            public string Raw { get; private set; }
        }
    }
}
