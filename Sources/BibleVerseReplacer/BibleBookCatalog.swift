import Foundation

struct BibleBook: Equatable {
    let code: String
    let chineseName: String
    let aliases: [String]
}

enum BibleBookCatalog {
    static let books: [BibleBook] = [
        BibleBook(code: "GEN", chineseName: "创世记", aliases: ["创世记", "创", "Genesis", "Gen", "Ge", "Gn"]),
        BibleBook(code: "EXO", chineseName: "出埃及记", aliases: ["出埃及记", "出", "Exodus", "Exod", "Exo", "Ex"]),
        BibleBook(code: "LEV", chineseName: "利未记", aliases: ["利未记", "利", "Leviticus", "Lev", "Le"]),
        BibleBook(code: "NUM", chineseName: "民数记", aliases: ["民数记", "民", "Numbers", "Num", "Nu", "Nm", "Nb"]),
        BibleBook(code: "DEU", chineseName: "申命记", aliases: ["申命记", "申", "Deuteronomy", "Deut", "Deu", "Dt"]),
        BibleBook(code: "JOS", chineseName: "约书亚记", aliases: ["约书亚记", "书", "Joshua", "Josh", "Jos"]),
        BibleBook(code: "JDG", chineseName: "士师记", aliases: ["士师记", "士", "Judges", "Judg", "Jdg", "Jg"]),
        BibleBook(code: "RUT", chineseName: "路得记", aliases: ["路得记", "得", "Ruth", "Rut", "Ru"]),
        BibleBook(code: "1SA", chineseName: "撒母耳记上", aliases: ["撒母耳记上", "撒母耳上", "撒上", "1 Samuel", "1Samuel", "1 Sam", "1Sam", "I Samuel", "ISamuel", "I Sam", "ISam"]),
        BibleBook(code: "2SA", chineseName: "撒母耳记下", aliases: ["撒母耳记下", "撒母耳下", "撒下", "2 Samuel", "2Samuel", "2 Sam", "2Sam", "II Samuel", "IISamuel", "II Sam", "IISam"]),
        BibleBook(code: "1KI", chineseName: "列王纪上", aliases: ["列王纪上", "王上", "1 Kings", "1Kings", "1 Kgs", "1Kgs", "I Kings", "IKings"]),
        BibleBook(code: "2KI", chineseName: "列王纪下", aliases: ["列王纪下", "王下", "2 Kings", "2Kings", "2 Kgs", "2Kgs", "II Kings", "IIKings"]),
        BibleBook(code: "1CH", chineseName: "历代志上", aliases: ["历代志上", "代上", "1 Chronicles", "1Chronicles", "1 Chron", "1Chron", "I Chronicles", "IChronicles"]),
        BibleBook(code: "2CH", chineseName: "历代志下", aliases: ["历代志下", "代下", "2 Chronicles", "2Chronicles", "2 Chron", "2Chron", "II Chronicles", "IIChronicles"]),
        BibleBook(code: "EZR", chineseName: "以斯拉记", aliases: ["以斯拉记", "拉", "Ezra", "Ezr"]),
        BibleBook(code: "NEH", chineseName: "尼希米记", aliases: ["尼希米记", "尼", "Nehemiah", "Neh"]),
        BibleBook(code: "EST", chineseName: "以斯帖记", aliases: ["以斯帖记", "斯", "Esther", "Est"]),
        BibleBook(code: "JOB", chineseName: "约伯记", aliases: ["约伯记", "伯", "Job", "Jb"]),
        BibleBook(code: "PSA", chineseName: "诗篇", aliases: ["诗篇", "诗", "Psalms", "Psalm", "Ps", "Psa"]),
        BibleBook(code: "PRO", chineseName: "箴言", aliases: ["箴言", "箴", "Proverbs", "Prov", "Pro", "Pr"]),
        BibleBook(code: "ECC", chineseName: "传道书", aliases: ["传道书", "传", "Ecclesiastes", "Eccl", "Ecc", "Qoheleth"]),
        BibleBook(code: "SNG", chineseName: "雅歌", aliases: ["雅歌", "歌", "Song of Songs", "SongofSongs", "Song", "Songs", "Sng", "Song of Solomon", "SongofSolomon"]),
        BibleBook(code: "ISA", chineseName: "以赛亚书", aliases: ["以赛亚书", "赛", "Isaiah", "Isa"]),
        BibleBook(code: "JER", chineseName: "耶利米书", aliases: ["耶利米书", "耶", "Jeremiah", "Jer"]),
        BibleBook(code: "LAM", chineseName: "耶利米哀歌", aliases: ["耶利米哀歌", "哀", "Lamentations", "Lam"]),
        BibleBook(code: "EZK", chineseName: "以西结书", aliases: ["以西结书", "结", "Ezekiel", "Ezek", "Ezk"]),
        BibleBook(code: "DAN", chineseName: "但以理书", aliases: ["但以理书", "但", "Daniel", "Dan", "Da"]),
        BibleBook(code: "HOS", chineseName: "何西阿书", aliases: ["何西阿书", "何", "Hosea", "Hos"]),
        BibleBook(code: "JOL", chineseName: "约珥书", aliases: ["约珥书", "珥", "Joel", "Joe", "Jol"]),
        BibleBook(code: "AMO", chineseName: "阿摩司书", aliases: ["阿摩司书", "摩", "Amos", "Amo", "Am"]),
        BibleBook(code: "OBA", chineseName: "俄巴底亚书", aliases: ["俄巴底亚书", "俄", "Obadiah", "Obad", "Oba"]),
        BibleBook(code: "JON", chineseName: "约拿书", aliases: ["约拿书", "拿", "Jonah", "Jon"]),
        BibleBook(code: "MIC", chineseName: "弥迦书", aliases: ["弥迦书", "弥", "Micah", "Mic"]),
        BibleBook(code: "NAM", chineseName: "那鸿书", aliases: ["那鸿书", "鸿", "Nahum", "Nah", "Nam"]),
        BibleBook(code: "HAB", chineseName: "哈巴谷书", aliases: ["哈巴谷书", "哈", "Habakkuk", "Hab"]),
        BibleBook(code: "ZEP", chineseName: "西番雅书", aliases: ["西番雅书", "番", "Zephaniah", "Zeph", "Zep"]),
        BibleBook(code: "HAG", chineseName: "哈该书", aliases: ["哈该书", "该", "Haggai", "Hag"]),
        BibleBook(code: "ZEC", chineseName: "撒迦利亚书", aliases: ["撒迦利亚书", "亚", "Zechariah", "Zech", "Zec"]),
        BibleBook(code: "MAL", chineseName: "玛拉基书", aliases: ["玛拉基书", "玛", "Malachi", "Mal"]),
        BibleBook(code: "MAT", chineseName: "马太福音", aliases: ["马太福音", "太", "Matthew", "Matt", "Mat", "Mt"]),
        BibleBook(code: "MRK", chineseName: "马可福音", aliases: ["马可福音", "可", "Mark", "Mrk", "Mk"]),
        BibleBook(code: "LUK", chineseName: "路加福音", aliases: ["路加福音", "路", "Luke", "Luk", "Lk"]),
        BibleBook(code: "JHN", chineseName: "约翰福音", aliases: ["约翰福音", "约", "John", "Jhn", "Jn"]),
        BibleBook(code: "ACT", chineseName: "使徒行传", aliases: ["使徒行传", "徒", "Acts", "Act", "Ac"]),
        BibleBook(code: "ROM", chineseName: "罗马书", aliases: ["罗马书", "罗", "Romans", "Rom", "Ro"]),
        BibleBook(code: "1CO", chineseName: "哥林多前书", aliases: ["哥林多前书", "林前", "1 Corinthians", "1Corinthians", "1 Cor", "1Cor", "I Corinthians", "ICorinthians"]),
        BibleBook(code: "2CO", chineseName: "哥林多后书", aliases: ["哥林多后书", "林后", "2 Corinthians", "2Corinthians", "2 Cor", "2Cor", "II Corinthians", "IICorinthians"]),
        BibleBook(code: "GAL", chineseName: "加拉太书", aliases: ["加拉太书", "加", "Galatians", "Gal"]),
        BibleBook(code: "EPH", chineseName: "以弗所书", aliases: ["以弗所书", "弗", "Ephesians", "Eph"]),
        BibleBook(code: "PHP", chineseName: "腓立比书", aliases: ["腓立比书", "腓", "Philippians", "Phil", "Php"]),
        BibleBook(code: "COL", chineseName: "歌罗西书", aliases: ["歌罗西书", "西", "Colossians", "Col"]),
        BibleBook(code: "1TH", chineseName: "帖撒罗尼迦前书", aliases: ["帖撒罗尼迦前书", "帖前", "1 Thessalonians", "1Thessalonians", "1 Thess", "1Thess", "I Thessalonians", "IThessalonians"]),
        BibleBook(code: "2TH", chineseName: "帖撒罗尼迦后书", aliases: ["帖撒罗尼迦后书", "帖后", "2 Thessalonians", "2Thessalonians", "2 Thess", "2Thess", "II Thessalonians", "IIThessalonians"]),
        BibleBook(code: "1TI", chineseName: "提摩太前书", aliases: ["提摩太前书", "提前", "1 Timothy", "1Timothy", "1 Tim", "1Tim", "I Timothy", "ITimothy"]),
        BibleBook(code: "2TI", chineseName: "提摩太后书", aliases: ["提摩太后书", "提后", "2 Timothy", "2Timothy", "2 Tim", "2Tim", "II Timothy", "IITimothy"]),
        BibleBook(code: "TIT", chineseName: "提多书", aliases: ["提多书", "多", "Titus", "Tit"]),
        BibleBook(code: "PHM", chineseName: "腓利门书", aliases: ["腓利门书", "门", "Philemon", "Philem", "Phm"]),
        BibleBook(code: "HEB", chineseName: "希伯来书", aliases: ["希伯来书", "来", "Hebrews", "Heb"]),
        BibleBook(code: "JAS", chineseName: "雅各书", aliases: ["雅各书", "雅", "James", "Jas", "Jam"]),
        BibleBook(code: "1PE", chineseName: "彼得前书", aliases: ["彼得前书", "彼前", "1 Peter", "1Peter", "1 Pet", "1Pet", "I Peter", "IPeter"]),
        BibleBook(code: "2PE", chineseName: "彼得后书", aliases: ["彼得后书", "彼后", "2 Peter", "2Peter", "2 Pet", "2Pet", "II Peter", "IIPeter"]),
        BibleBook(code: "1JN", chineseName: "约翰一书", aliases: ["约翰一书", "约一", "1 John", "1John", "1 Jn", "1Jn", "I John", "IJohn"]),
        BibleBook(code: "2JN", chineseName: "约翰二书", aliases: ["约翰二书", "约二", "2 John", "2John", "2 Jn", "2Jn", "II John", "IIJohn"]),
        BibleBook(code: "3JN", chineseName: "约翰三书", aliases: ["约翰三书", "约三", "3 John", "3John", "3 Jn", "3Jn", "III John", "IIIJohn"]),
        BibleBook(code: "JUD", chineseName: "犹大书", aliases: ["犹大书", "犹", "Jude", "Jud"]),
        BibleBook(code: "REV", chineseName: "启示录", aliases: ["启示录", "启", "Revelation", "Revelations", "Rev", "Re"])
    ]

    private static let aliasMap: [String: BibleBook] = {
        var map: [String: BibleBook] = [:]
        for book in books {
            for alias in [book.chineseName, book.code] + book.aliases {
                map[normalize(alias)] = book
            }
        }
        return map
    }()

    private static let startAliases: [(alias: String, book: BibleBook)] = {
        var result: [(String, BibleBook)] = []
        for book in books {
            for alias in [book.chineseName, book.code] + book.aliases {
                let normalizedAlias = normalize(alias)
                if !normalizedAlias.isEmpty {
                    result.append((normalizedAlias, book))
                }
            }
        }
        return result.sorted { lhs, rhs in
            lhs.0.count > rhs.0.count
        }
    }()

    static func book(for rawName: String) -> BibleBook? {
        aliasMap[normalize(rawName)]
    }

    static func bookAtStart(of compactText: String) -> (book: BibleBook, remaining: String)? {
        let text = normalizeForBookStart(compactText)
        for candidate in startAliases where text.hasPrefix(candidate.alias) {
            let remaining = String(text.dropFirst(candidate.alias.count))
            return (candidate.book, remaining)
        }
        return nil
    }

    static func chineseName(for code: String) -> String {
        books.first(where: { $0.code == code })?.chineseName ?? code
    }

    static func normalize(_ raw: String) -> String {
        raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: "前書", with: "前书")
            .replacingOccurrences(of: "後書", with: "后书")
            .replacingOccurrences(of: "記", with: "记")
            .replacingOccurrences(of: "約", with: "约")
            .replacingOccurrences(of: "啟", with: "启")
            .replacingOccurrences(of: "詩", with: "诗")
    }

    private static func normalizeForBookStart(_ raw: String) -> String {
        raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: "前書", with: "前书")
            .replacingOccurrences(of: "後書", with: "后书")
            .replacingOccurrences(of: "記", with: "记")
            .replacingOccurrences(of: "約", with: "约")
            .replacingOccurrences(of: "啟", with: "启")
            .replacingOccurrences(of: "詩", with: "诗")
    }
}
