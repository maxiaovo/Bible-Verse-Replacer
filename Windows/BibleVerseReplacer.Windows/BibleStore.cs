using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization.Json;

namespace BibleVerseReplacer.Windows
{
    internal sealed class BibleStore
    {
        public static readonly BibleStore Instance = new BibleStore();

        private readonly Dictionary<VerseKey, BibleVerse> verseMap = new Dictionary<VerseKey, BibleVerse>();
        private readonly Dictionary<string, List<BibleVerse>> chapterMap = new Dictionary<string, List<BibleVerse>>();
        private readonly HashSet<string> chapterKeys = new HashSet<string>();
        private BiblePayload payload;

        private BibleStore()
        {
        }

        public string SourceSummary
        {
            get
            {
                return payload == null ? "未加载" : payload.DisplayName + " · " + payload.Id;
            }
        }

        public void Load()
        {
            string path = LocateBibleData();
            DataContractJsonSerializer serializer = new DataContractJsonSerializer(typeof(BiblePayload));
            using (FileStream stream = File.OpenRead(path))
            {
                payload = (BiblePayload)serializer.ReadObject(stream);
            }

            verseMap.Clear();
            chapterMap.Clear();
            chapterKeys.Clear();
            foreach (BibleVerse verse in payload.Verses)
            {
                for (int verseNumber = verse.Verse; verseNumber <= verse.EndVerse; verseNumber++)
                {
                    verseMap[new VerseKey(verse.Book, verse.Chapter, verseNumber)] = verse;
                }
                string key = ChapterKey(verse.Book, verse.Chapter);
                if (!chapterMap.ContainsKey(key))
                {
                    chapterMap[key] = new List<BibleVerse>();
                }
                chapterMap[key].Add(verse);
                chapterKeys.Add(ChapterKey(verse.Book, verse.Chapter));
            }

            foreach (List<BibleVerse> verses in chapterMap.Values)
            {
                verses.Sort(CompareVerses);
            }
        }

        public List<BibleVerse> VersesFor(ParsedReference parsedReference)
        {
            List<BibleVerse> result = new List<BibleVerse>();
            HashSet<string> seen = new HashSet<string>();

            foreach (PassageReference passage in parsedReference.Passages)
            {
                foreach (BibleVerse verse in VersesFor(passage))
                {
                    if (!seen.Contains(verse.CanonicalKey))
                    {
                        result.Add(verse);
                        seen.Add(verse.CanonicalKey);
                    }
                }
            }

            result.Sort(CompareVerses);
            return result;
        }

        public List<PassageVerseGroup> VerseGroupsFor(ParsedReference parsedReference)
        {
            List<PassageVerseGroup> result = new List<PassageVerseGroup>();
            HashSet<string> seen = new HashSet<string>();

            foreach (PassageReference passage in parsedReference.Passages)
            {
                List<BibleVerse> verses = new List<BibleVerse>();
                foreach (BibleVerse verse in VersesFor(passage))
                {
                    if (!seen.Contains(verse.CanonicalKey))
                    {
                        verses.Add(verse);
                        seen.Add(verse.CanonicalKey);
                    }
                }

                if (verses.Count > 0)
                {
                    result.Add(new PassageVerseGroup(passage, verses));
                }
            }

            return result;
        }

        public List<BibleVerse> VersesFor(PassageReference passage)
        {
            if (passage.IsWholeChapter)
            {
                return VersesForWholeChapter(passage.Book, passage.StartChapter);
            }

            if (!passage.StartVerse.HasValue || !passage.EndVerse.HasValue)
            {
                return VersesForWholeChapter(passage.Book, passage.StartChapter);
            }

            if (passage.StartChapter > passage.EndChapter)
            {
                throw new FormatException("范围顺序不正确");
            }

            List<BibleVerse> result = new List<BibleVerse>();
            HashSet<string> seen = new HashSet<string>();

            for (int chapter = passage.StartChapter; chapter <= passage.EndChapter; chapter++)
            {
                int start = chapter == passage.StartChapter ? passage.StartVerse.Value : 1;
                int end = chapter == passage.EndChapter ? passage.EndVerse.Value : LastVerseNumber(passage.Book, chapter);
                if (start > end)
                {
                    throw new FormatException("范围顺序不正确");
                }

                for (int verseNumber = start; verseNumber <= end; verseNumber++)
                {
                    BibleVerse verse;
                    if (!verseMap.TryGetValue(new VerseKey(passage.Book.Code, chapter, verseNumber), out verse))
                    {
                        if (!chapterKeys.Contains(ChapterKey(passage.Book.Code, chapter)))
                        {
                            throw new InvalidOperationException(passage.Book.ChineseName + " 第 " + chapter + " 章不存在");
                        }
                        throw new InvalidOperationException(passage.Book.ChineseName + " " + chapter + ":" + verseNumber + " 不存在");
                    }

                    if (!seen.Contains(verse.CanonicalKey))
                    {
                        result.Add(verse);
                        seen.Add(verse.CanonicalKey);
                    }
                }
            }

            return result;
        }

        public List<BibleVerse> VersesFor(VerseReference reference)
        {
            return VersesFor(new PassageReference(reference));
        }

        private static string LocateBibleData()
        {
            string baseDirectory = AppDomain.CurrentDomain.BaseDirectory;
            string bundled = Path.Combine(baseDirectory, "Resources", "Bible", "cmn-cu89s.json");
            if (File.Exists(bundled))
            {
                return bundled;
            }

            string local = Path.GetFullPath(Path.Combine(baseDirectory, "..", "..", "..", "..", "Resources", "Bible", "cmn-cu89s.json"));
            if (File.Exists(local))
            {
                return local;
            }

            throw new FileNotFoundException("找不到 Resources\\Bible\\cmn-cu89s.json");
        }

        private static string ChapterKey(string book, int chapter)
        {
            return book + "#" + chapter;
        }

        private List<BibleVerse> VersesForWholeChapter(BibleBook book, int chapter)
        {
            List<BibleVerse> verses;
            if (!chapterMap.TryGetValue(ChapterKey(book.Code, chapter), out verses))
            {
                throw new InvalidOperationException(book.ChineseName + " 第 " + chapter + " 章不存在");
            }
            return new List<BibleVerse>(verses);
        }

        private int LastVerseNumber(BibleBook book, int chapter)
        {
            List<BibleVerse> verses;
            if (!chapterMap.TryGetValue(ChapterKey(book.Code, chapter), out verses) || verses.Count == 0)
            {
                throw new InvalidOperationException(book.ChineseName + " 第 " + chapter + " 章不存在");
            }
            return verses[verses.Count - 1].EndVerse;
        }

        private static int CompareVerses(BibleVerse left, BibleVerse right)
        {
            int order = left.Order.CompareTo(right.Order);
            if (order != 0)
            {
                return order;
            }

            int chapter = left.Chapter.CompareTo(right.Chapter);
            return chapter != 0 ? chapter : left.Verse.CompareTo(right.Verse);
        }
    }
}
