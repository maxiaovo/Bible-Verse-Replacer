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
            chapterKeys.Clear();
            foreach (BibleVerse verse in payload.Verses)
            {
                for (int verseNumber = verse.Verse; verseNumber <= verse.EndVerse; verseNumber++)
                {
                    verseMap[new VerseKey(verse.Book, verse.Chapter, verseNumber)] = verse;
                }
                chapterKeys.Add(ChapterKey(verse.Book, verse.Chapter));
            }
        }

        public List<BibleVerse> VersesFor(VerseReference reference)
        {
            if (!chapterKeys.Contains(ChapterKey(reference.Book.Code, reference.Chapter)))
            {
                throw new InvalidOperationException(reference.Book.ChineseName + " 第 " + reference.Chapter + " 章不存在");
            }

            List<BibleVerse> result = new List<BibleVerse>();
            HashSet<string> seen = new HashSet<string>();
            for (int verseNumber = reference.StartVerse; verseNumber <= reference.EndVerse; verseNumber++)
            {
                BibleVerse verse;
                if (!verseMap.TryGetValue(new VerseKey(reference.Book.Code, reference.Chapter, verseNumber), out verse))
                {
                    throw new InvalidOperationException(reference.Book.ChineseName + " " + reference.Chapter + ":" + verseNumber + " 不存在");
                }

                if (!seen.Contains(verse.CanonicalKey))
                {
                    result.Add(verse);
                    seen.Add(verse.CanonicalKey);
                }
            }
            return result;
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
    }
}

