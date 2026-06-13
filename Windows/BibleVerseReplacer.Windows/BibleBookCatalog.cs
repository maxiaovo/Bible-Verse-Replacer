using System;
using System.Collections.Generic;

namespace BibleVerseReplacer.Windows
{
    internal static class BibleBookCatalog
    {
        public static readonly BibleBook[] Books =
        {
            new BibleBook("GEN", "创世记", "创", "Genesis", "Gen", "Ge", "Gn"),
            new BibleBook("EXO", "出埃及记", "出", "Exodus", "Exod", "Exo", "Ex"),
            new BibleBook("LEV", "利未记", "利", "Leviticus", "Lev", "Le"),
            new BibleBook("NUM", "民数记", "民", "Numbers", "Num", "Nu", "Nm", "Nb"),
            new BibleBook("DEU", "申命记", "申", "Deuteronomy", "Deut", "Deu", "Dt"),
            new BibleBook("JOS", "约书亚记", "书", "Joshua", "Josh", "Jos"),
            new BibleBook("JDG", "士师记", "士", "Judges", "Judg", "Jdg", "Jg"),
            new BibleBook("RUT", "路得记", "得", "Ruth", "Rut", "Ru"),
            new BibleBook("1SA", "撒母耳记上", "撒母耳上", "撒上", "1 Samuel", "1Samuel", "1 Sam", "1Sam", "I Samuel", "ISamuel", "I Sam", "ISam"),
            new BibleBook("2SA", "撒母耳记下", "撒母耳下", "撒下", "2 Samuel", "2Samuel", "2 Sam", "2Sam", "II Samuel", "IISamuel", "II Sam", "IISam"),
            new BibleBook("1KI", "列王纪上", "王上", "1 Kings", "1Kings", "1 Kgs", "1Kgs", "I Kings", "IKings"),
            new BibleBook("2KI", "列王纪下", "王下", "2 Kings", "2Kings", "2 Kgs", "2Kgs", "II Kings", "IIKings"),
            new BibleBook("1CH", "历代志上", "代上", "1 Chronicles", "1Chronicles", "1 Chron", "1Chron", "I Chronicles", "IChronicles"),
            new BibleBook("2CH", "历代志下", "代下", "2 Chronicles", "2Chronicles", "2 Chron", "2Chron", "II Chronicles", "IIChronicles"),
            new BibleBook("EZR", "以斯拉记", "拉", "Ezra", "Ezr"),
            new BibleBook("NEH", "尼希米记", "尼", "Nehemiah", "Neh"),
            new BibleBook("EST", "以斯帖记", "斯", "Esther", "Est"),
            new BibleBook("JOB", "约伯记", "伯", "Job", "Jb"),
            new BibleBook("PSA", "诗篇", "诗", "Psalms", "Psalm", "Ps", "Psa"),
            new BibleBook("PRO", "箴言", "箴", "Proverbs", "Prov", "Pro", "Pr"),
            new BibleBook("ECC", "传道书", "传", "Ecclesiastes", "Eccl", "Ecc", "Qoheleth"),
            new BibleBook("SNG", "雅歌", "歌", "Song of Songs", "SongofSongs", "Song", "Songs", "Sng", "Song of Solomon", "SongofSolomon"),
            new BibleBook("ISA", "以赛亚书", "赛", "Isaiah", "Isa"),
            new BibleBook("JER", "耶利米书", "耶", "Jeremiah", "Jer"),
            new BibleBook("LAM", "耶利米哀歌", "哀", "Lamentations", "Lam"),
            new BibleBook("EZK", "以西结书", "结", "Ezekiel", "Ezek", "Ezk"),
            new BibleBook("DAN", "但以理书", "但", "Daniel", "Dan", "Da"),
            new BibleBook("HOS", "何西阿书", "何", "Hosea", "Hos"),
            new BibleBook("JOL", "约珥书", "珥", "Joel", "Joe", "Jol"),
            new BibleBook("AMO", "阿摩司书", "摩", "Amos", "Amo", "Am"),
            new BibleBook("OBA", "俄巴底亚书", "俄", "Obadiah", "Obad", "Oba"),
            new BibleBook("JON", "约拿书", "拿", "Jonah", "Jon"),
            new BibleBook("MIC", "弥迦书", "弥", "Micah", "Mic"),
            new BibleBook("NAM", "那鸿书", "鸿", "Nahum", "Nah", "Nam"),
            new BibleBook("HAB", "哈巴谷书", "哈", "Habakkuk", "Hab"),
            new BibleBook("ZEP", "西番雅书", "番", "Zephaniah", "Zeph", "Zep"),
            new BibleBook("HAG", "哈该书", "该", "Haggai", "Hag"),
            new BibleBook("ZEC", "撒迦利亚书", "亚", "Zechariah", "Zech", "Zec"),
            new BibleBook("MAL", "玛拉基书", "玛", "Malachi", "Mal"),
            new BibleBook("MAT", "马太福音", "太", "Matthew", "Matt", "Mat", "Mt"),
            new BibleBook("MRK", "马可福音", "可", "Mark", "Mrk", "Mk"),
            new BibleBook("LUK", "路加福音", "路", "Luke", "Luk", "Lk"),
            new BibleBook("JHN", "约翰福音", "约", "John", "Jhn", "Jn"),
            new BibleBook("ACT", "使徒行传", "徒", "Acts", "Act", "Ac"),
            new BibleBook("ROM", "罗马书", "罗", "Romans", "Rom", "Ro"),
            new BibleBook("1CO", "哥林多前书", "林前", "1 Corinthians", "1Corinthians", "1 Cor", "1Cor", "I Corinthians", "ICorinthians"),
            new BibleBook("2CO", "哥林多后书", "林后", "2 Corinthians", "2Corinthians", "2 Cor", "2Cor", "II Corinthians", "IICorinthians"),
            new BibleBook("GAL", "加拉太书", "加", "Galatians", "Gal"),
            new BibleBook("EPH", "以弗所书", "弗", "Ephesians", "Eph"),
            new BibleBook("PHP", "腓立比书", "腓", "Philippians", "Phil", "Php"),
            new BibleBook("COL", "歌罗西书", "西", "Colossians", "Col"),
            new BibleBook("1TH", "帖撒罗尼迦前书", "帖前", "1 Thessalonians", "1Thessalonians", "1 Thess", "1Thess", "I Thessalonians", "IThessalonians"),
            new BibleBook("2TH", "帖撒罗尼迦后书", "帖后", "2 Thessalonians", "2Thessalonians", "2 Thess", "2Thess", "II Thessalonians", "IIThessalonians"),
            new BibleBook("1TI", "提摩太前书", "提前", "1 Timothy", "1Timothy", "1 Tim", "1Tim", "I Timothy", "ITimothy"),
            new BibleBook("2TI", "提摩太后书", "提后", "2 Timothy", "2Timothy", "2 Tim", "2Tim", "II Timothy", "IITimothy"),
            new BibleBook("TIT", "提多书", "多", "Titus", "Tit"),
            new BibleBook("PHM", "腓利门书", "门", "Philemon", "Philem", "Phm"),
            new BibleBook("HEB", "希伯来书", "来", "Hebrews", "Heb"),
            new BibleBook("JAS", "雅各书", "雅", "James", "Jas", "Jam"),
            new BibleBook("1PE", "彼得前书", "彼前", "1 Peter", "1Peter", "1 Pet", "1Pet", "I Peter", "IPeter"),
            new BibleBook("2PE", "彼得后书", "彼后", "2 Peter", "2Peter", "2 Pet", "2Pet", "II Peter", "IIPeter"),
            new BibleBook("1JN", "约翰一书", "约一", "1 John", "1John", "1 Jn", "1Jn", "I John", "IJohn"),
            new BibleBook("2JN", "约翰二书", "约二", "2 John", "2John", "2 Jn", "2Jn", "II John", "IIJohn"),
            new BibleBook("3JN", "约翰三书", "约三", "3 John", "3John", "3 Jn", "3Jn", "III John", "IIIJohn"),
            new BibleBook("JUD", "犹大书", "犹", "Jude", "Jud"),
            new BibleBook("REV", "启示录", "启", "Revelation", "Revelations", "Rev", "Re")
        };

        private static readonly Dictionary<string, BibleBook> AliasMap = BuildAliasMap();
        private static readonly List<KeyValuePair<string, BibleBook>> StartAliases = BuildStartAliases();

        public static BibleBook Find(string rawName)
        {
            BibleBook book;
            return AliasMap.TryGetValue(Normalize(rawName), out book) ? book : null;
        }

        public static bool FindAtStart(string compactText, out BibleBook book, out string remaining)
        {
            string text = NormalizeForBookStart(compactText);
            foreach (KeyValuePair<string, BibleBook> candidate in StartAliases)
            {
                if (text.StartsWith(candidate.Key, StringComparison.Ordinal))
                {
                    book = candidate.Value;
                    remaining = text.Substring(candidate.Key.Length);
                    return true;
                }
            }

            book = null;
            remaining = compactText;
            return false;
        }

        private static Dictionary<string, BibleBook> BuildAliasMap()
        {
            Dictionary<string, BibleBook> map = new Dictionary<string, BibleBook>();
            foreach (BibleBook book in Books)
            {
                map[Normalize(book.Code)] = book;
                map[Normalize(book.ChineseName)] = book;
                foreach (string alias in book.Aliases)
                {
                    map[Normalize(alias)] = book;
                }
            }
            return map;
        }

        private static List<KeyValuePair<string, BibleBook>> BuildStartAliases()
        {
            List<KeyValuePair<string, BibleBook>> aliases = new List<KeyValuePair<string, BibleBook>>();
            foreach (BibleBook book in Books)
            {
                aliases.Add(new KeyValuePair<string, BibleBook>(Normalize(book.Code), book));
                aliases.Add(new KeyValuePair<string, BibleBook>(Normalize(book.ChineseName), book));
                foreach (string alias in book.Aliases)
                {
                    aliases.Add(new KeyValuePair<string, BibleBook>(Normalize(alias), book));
                }
            }
            aliases.Sort((left, right) => right.Key.Length.CompareTo(left.Key.Length));
            return aliases;
        }

        private static string Normalize(string raw)
        {
            return (raw ?? string.Empty)
                .Trim()
                .ToLowerInvariant()
                .Replace(" ", string.Empty)
                .Replace(".", string.Empty)
                .Replace("-", string.Empty)
                .Replace("_", string.Empty)
                .Replace("前書", "前书")
                .Replace("後書", "后书")
                .Replace("記", "记")
                .Replace("約", "约")
                .Replace("啟", "启")
                .Replace("詩", "诗");
        }

        private static string NormalizeForBookStart(string raw)
        {
            return (raw ?? string.Empty)
                .Trim()
                .ToLowerInvariant()
                .Replace(" ", string.Empty)
                .Replace(".", string.Empty)
                .Replace("_", string.Empty)
                .Replace("前書", "前书")
                .Replace("後書", "后书")
                .Replace("記", "记")
                .Replace("約", "约")
                .Replace("啟", "启")
                .Replace("詩", "诗");
        }
    }
}
