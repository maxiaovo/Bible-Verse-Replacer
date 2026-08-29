#!/usr/bin/env python3
from __future__ import annotations

import csv
import io
import json
import re
import sys
import urllib.request
import zipfile
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path


SOURCE_URL = "https://ebible.org/Scriptures/cmn-cu89s_vpl.zip"
SQL_NAME = "cmn-cu89s_vpl.sql"
OUTPUT_PATH = Path("Resources/Bible/cmn-cu89s.json")
CACHE_PATH = Path(".build/downloads/cmn-cu89s_vpl.zip")
SUPPLEMENTAL_PATH = Path("Resources/Bible/cmn-cu89s-footnote-verses.json")
EXPECTED_NUMBERED_FOOTNOTE_VERSES = {
    ("MAT", 18, 11),
    ("MAT", 23, 14),
    ("MRK", 7, 16),
    ("MRK", 15, 28),
    ("LUK", 17, 36),
    ("LUK", 23, 17),
    ("JHN", 5, 4),
    ("ACT", 8, 37),
    ("ACT", 15, 34),
    ("ACT", 24, 7),
    ("ACT", 28, 29),
}


def load_zip_bytes(refresh: bool) -> bytes:
    if CACHE_PATH.exists() and not refresh:
        print(f"Using cached {CACHE_PATH}", file=sys.stderr)
        return CACHE_PATH.read_bytes()

    print(f"Downloading {SOURCE_URL}", file=sys.stderr)
    request = urllib.request.Request(
        SOURCE_URL,
        headers={"User-Agent": "BibleVerseReplacer/0.1 (+https://ebible.org/)"},
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        zip_bytes = response.read()

    CACHE_PATH.parent.mkdir(parents=True, exist_ok=True)
    CACHE_PATH.write_bytes(zip_bytes)
    return zip_bytes


def parse_insert_values(line: str) -> list[str] | None:
    marker = "VALUES ("
    start = line.find(marker)
    if start == -1 or not line.rstrip().endswith(");"):
        return None

    payload = line[start + len(marker) : line.rfind(");")]
    reader = csv.reader(
        io.StringIO(payload),
        delimiter=",",
        quotechar='"',
        escapechar="\\",
        doublequote=False,
    )
    return next(reader)


def clean_sql_text(text: str) -> str:
    return text.strip()


def covered_verse_keys(verses: list[dict]) -> set[tuple[str, int, int]]:
    return {
        (verse["book"], verse["chapter"], verse_number)
        for verse in verses
        for verse_number in range(verse["verse"], verse["endVerse"] + 1)
    }


def load_supplemental_verses(base_verses: list[dict]) -> tuple[list[dict], dict]:
    supplemental = json.loads(SUPPLEMENTAL_PATH.read_text(encoding="utf-8"))
    if supplemental.get("id") != "cmn-cu89s":
        raise ValueError(f"Unexpected supplemental source id: {supplemental.get('id')}")

    base_keys = covered_verse_keys(base_verses)
    verses = []
    keys = set()
    for raw in supplemental.get("verses", []):
        key = (raw["book"], int(raw["chapter"]), int(raw["verse"]))
        if key in keys:
            raise ValueError(f"Duplicate supplemental verse: {key}")
        if key in base_keys:
            raise ValueError(f"Supplemental verse conflicts with VPL text: {key}")
        if raw.get("endVerse") != raw.get("verse"):
            raise ValueError(f"Supplemental verse must contain one numbered verse: {key}")
        if raw.get("anchorVerse") != raw.get("verse") - 1:
            raise ValueError(f"Supplemental verse has invalid anchor: {key}")
        anchor_key = (raw["book"], int(raw["chapter"]), int(raw["anchorVerse"]))
        if anchor_key not in base_keys:
            raise ValueError(f"Supplemental anchor is missing from VPL text: {anchor_key}")
        if raw.get("note") != "有古卷加":
            raise ValueError(f"Supplemental verse has unexpected note: {key}")

        keys.add(key)
        verses.append(
            {
                "book": raw["book"],
                "chapter": int(raw["chapter"]),
                "verse": int(raw["verse"]),
                "endVerse": int(raw["endVerse"]),
                "text": raw["text"].strip(),
                "order": int(raw["order"]),
                "note": raw["note"],
            }
        )

    if keys != EXPECTED_NUMBERED_FOOTNOTE_VERSES:
        missing = sorted(EXPECTED_NUMBERED_FOOTNOTE_VERSES - keys)
        unexpected = sorted(keys - EXPECTED_NUMBERED_FOOTNOTE_VERSES)
        raise ValueError(f"Supplemental verse inventory mismatch; missing={missing}, unexpected={unexpected}")

    return verses, supplemental["source"]


def validate_verse_coverage(verses: list[dict]) -> None:
    chapters: dict[tuple[str, int], dict[int, dict]] = defaultdict(dict)
    for verse in verses:
        if verse["verse"] < 1 or verse["endVerse"] < verse["verse"]:
            raise ValueError(f"Invalid verse range: {verse}")
        chapter = chapters[(verse["book"], verse["chapter"])]
        for verse_number in range(verse["verse"], verse["endVerse"] + 1):
            if verse_number in chapter:
                raise ValueError(
                    f"Overlapping verse number: {verse['book']} {verse['chapter']}:{verse_number}"
                )
            chapter[verse_number] = verse

    for (book, chapter_number), verse_map in chapters.items():
        expected = set(range(1, max(verse_map) + 1))
        missing = sorted(expected - set(verse_map))
        if missing:
            raise ValueError(f"Missing verse numbers in {book} {chapter_number}: {missing}")


def main() -> int:
    refresh = "--refresh" in sys.argv
    zip_bytes = load_zip_bytes(refresh)

    with zipfile.ZipFile(io.BytesIO(zip_bytes)) as archive:
        sql_info = archive.getinfo(SQL_NAME)
        source_updated_at = datetime(*sql_info.date_time, tzinfo=timezone.utc).isoformat()
        sql_text = archive.read(SQL_NAME).decode("utf-8-sig")

    verses = []
    insert_prefix = "INSERT INTO cmn_cu89s_vpl VALUES"

    for line in sql_text.splitlines():
        if not line.startswith(insert_prefix):
            continue

        fields = parse_insert_values(line)
        if not fields or len(fields) != 7:
            raise ValueError(f"Unexpected INSERT shape: {line[:120]}")

        _, canon_order, book, chapter, start_verse, end_verse, verse_text = fields
        order_match = re.match(r"^(\d+)_", canon_order)
        order = int(order_match.group(1)) if order_match else 0

        verses.append(
            {
                "book": book,
                "chapter": int(chapter),
                "verse": int(start_verse),
                "endVerse": int(end_verse),
                "text": clean_sql_text(verse_text),
                "order": order,
            }
        )

    if len(verses) < 30_000:
        raise ValueError(f"Parsed too few verses: {len(verses)}")

    supplemental_verses, supplemental_source = load_supplemental_verses(verses)
    verses.extend(supplemental_verses)
    verses.sort(key=lambda verse: (verse["order"], verse["chapter"], verse["verse"], verse["endVerse"]))
    validate_verse_coverage(verses)

    payload = {
        "id": "cmn-cu89s",
        "name": "Chinese Union Version (Simplified)",
        "displayName": "新标点和合本（简体）",
        "source": {
            "url": SOURCE_URL,
            "format": "eBible VPL SQL",
            "sourceFile": SQL_NAME,
        },
        "supplementalSources": [supplemental_source],
        "generatedAt": source_updated_at,
        "verses": verses,
    }

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    print(f"Wrote {OUTPUT_PATH} with {len(verses)} verses", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
