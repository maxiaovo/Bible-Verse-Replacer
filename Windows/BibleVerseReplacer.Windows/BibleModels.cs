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

