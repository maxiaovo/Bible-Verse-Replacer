using System.Collections.Generic;
using System.Runtime.Serialization;

namespace BibleVerseReplacer.Windows
{
    [DataContract]
    internal sealed class BiblePayload
    {
        [DataMember(Name = "id")]
        public string Id { get; set; }

        [DataMember(Name = "name")]
        public string Name { get; set; }

        [DataMember(Name = "displayName")]
        public string DisplayName { get; set; }

        [DataMember(Name = "generatedAt")]
        public string GeneratedAt { get; set; }

        [DataMember(Name = "verses")]
        public List<BibleVerse> Verses { get; set; }
    }

    [DataContract]
    internal sealed class BibleVerse
    {
        [DataMember(Name = "book")]
        public string Book { get; set; }

        [DataMember(Name = "chapter")]
        public int Chapter { get; set; }

        [DataMember(Name = "verse")]
        public int Verse { get; set; }

        [DataMember(Name = "endVerse")]
        public int EndVerse { get; set; }

        [DataMember(Name = "text")]
        public string Text { get; set; }

        [DataMember(Name = "order")]
        public int Order { get; set; }

        [DataMember(Name = "note", EmitDefaultValue = false)]
        public string Note { get; set; }

        public string ReferenceVerseText
        {
            get
            {
                return Verse == EndVerse ? Chapter + ":" + Verse : Chapter + ":" + Verse + "-" + EndVerse;
            }
        }

        public string VerseLabel
        {
            get
            {
                return Verse == EndVerse ? Verse.ToString() : Verse + "-" + EndVerse;
            }
        }

        public string CanonicalKey
        {
            get { return Book + "#" + Chapter + "#" + Verse + "#" + EndVerse; }
        }
    }

    internal sealed class BibleBook
    {
        public BibleBook(string code, string chineseName, params string[] aliases)
        {
            Code = code;
            ChineseName = chineseName;
            Aliases = aliases;
        }

        public string Code { get; private set; }
        public string ChineseName { get; private set; }
        public string[] Aliases { get; private set; }
    }

    internal sealed class VerseReference
    {
        public VerseReference(BibleBook book, int chapter, int startVerse, int endVerse)
        {
            Book = book;
            Chapter = chapter;
            StartVerse = startVerse;
            EndVerse = endVerse;
        }

        public BibleBook Book { get; private set; }
        public int Chapter { get; private set; }
        public int StartVerse { get; private set; }
        public int EndVerse { get; private set; }

        public string DisplayText
        {
            get
            {
                return StartVerse == EndVerse
                    ? Book.ChineseName + " " + Chapter + ":" + StartVerse
                    : Book.ChineseName + " " + Chapter + ":" + StartVerse + "-" + EndVerse;
            }
        }
    }

    internal sealed class PassageReference
    {
        public PassageReference(BibleBook book, int startChapter, int? startVerse, int endChapter, int? endVerse)
        {
            Book = book;
            StartChapter = startChapter;
            StartVerse = startVerse;
            EndChapter = endChapter;
            EndVerse = endVerse;
        }

        public PassageReference(VerseReference reference)
        {
            Book = reference.Book;
            StartChapter = reference.Chapter;
            StartVerse = reference.StartVerse;
            EndChapter = reference.Chapter;
            EndVerse = reference.EndVerse;
        }

        public BibleBook Book { get; private set; }
        public int StartChapter { get; private set; }
        public int? StartVerse { get; private set; }
        public int EndChapter { get; private set; }
        public int? EndVerse { get; private set; }

        public bool IsWholeChapter
        {
            get { return !StartVerse.HasValue && !EndVerse.HasValue && StartChapter == EndChapter; }
        }

        public string DisplayText
        {
            get
            {
                if (IsWholeChapter || !StartVerse.HasValue || !EndVerse.HasValue)
                {
                    return Book.ChineseName + " 第" + StartChapter + "章";
                }

                if (StartChapter == EndChapter)
                {
                    if (StartVerse.Value == EndVerse.Value)
                    {
                        return Book.ChineseName + " " + StartChapter + ":" + StartVerse.Value;
                    }
                    return Book.ChineseName + " " + StartChapter + ":" + StartVerse.Value + "-" + EndVerse.Value;
                }

                return Book.ChineseName + " " + StartChapter + ":" + StartVerse.Value + "-" + EndChapter + ":" + EndVerse.Value;
            }
        }

        public string SameChapterVerseFragment
        {
            get
            {
                if (StartChapter != EndChapter || !StartVerse.HasValue || !EndVerse.HasValue)
                {
                    return null;
                }
                return StartVerse.Value == EndVerse.Value
                    ? StartVerse.Value.ToString()
                    : StartVerse.Value + "-" + EndVerse.Value;
            }
        }

        public string ChapterVerseFragment
        {
            get
            {
                if (!StartVerse.HasValue || !EndVerse.HasValue)
                {
                    return null;
                }

                if (StartChapter == EndChapter)
                {
                    return StartVerse.Value == EndVerse.Value
                        ? StartChapter + ":" + StartVerse.Value
                        : StartChapter + ":" + StartVerse.Value + "-" + EndVerse.Value;
                }

                return StartChapter + ":" + StartVerse.Value + "-" + EndChapter + ":" + EndVerse.Value;
            }
        }
    }

    internal sealed class ParsedReference
    {
        public ParsedReference(List<PassageReference> passages)
        {
            Passages = passages;
        }

        public List<PassageReference> Passages { get; private set; }

        public string DisplayText
        {
            get
            {
                List<string> labels = new List<string>();
                foreach (PassageReference passage in Passages)
                {
                    labels.Add(passage.DisplayText);
                }
                return string.Join("；", labels.ToArray());
            }
        }

        public string CompactDisplayText
        {
            get
            {
                if (Passages.Count == 0)
                {
                    return string.Empty;
                }

                PassageReference first = Passages[0];
                foreach (PassageReference passage in Passages)
                {
                    if (passage.Book.Code != first.Book.Code || !passage.StartVerse.HasValue || !passage.EndVerse.HasValue)
                    {
                        return DisplayText;
                    }
                }

                bool sameChapter = true;
                foreach (PassageReference passage in Passages)
                {
                    if (passage.StartChapter != first.StartChapter || passage.EndChapter != first.StartChapter || passage.SameChapterVerseFragment == null)
                    {
                        sameChapter = false;
                        break;
                    }
                }

                List<string> fragments = new List<string>();
                if (sameChapter)
                {
                    foreach (PassageReference passage in Passages)
                    {
                        fragments.Add(passage.SameChapterVerseFragment);
                    }
                    return first.Book.ChineseName + " " + first.StartChapter + ":" + string.Join(",", fragments.ToArray());
                }

                foreach (PassageReference passage in Passages)
                {
                    string fragment = passage.ChapterVerseFragment;
                    if (fragment == null)
                    {
                        return DisplayText;
                    }
                    fragments.Add(fragment);
                }
                return first.Book.ChineseName + " " + string.Join(",", fragments.ToArray());
            }
        }
    }

    internal sealed class PassageVerseGroup
    {
        public PassageVerseGroup(PassageReference passage, List<BibleVerse> verses)
        {
            Passage = passage;
            Verses = verses;
        }

        public PassageReference Passage { get; private set; }
        public List<BibleVerse> Verses { get; private set; }
    }

    internal sealed class VerseKey
    {
        private readonly string value;

        public VerseKey(string book, int chapter, int verse)
        {
            value = book + "#" + chapter + "#" + verse;
        }

        public override int GetHashCode()
        {
            return value.GetHashCode();
        }

        public override bool Equals(object obj)
        {
            VerseKey other = obj as VerseKey;
            return other != null && value == other.value;
        }
    }
}
