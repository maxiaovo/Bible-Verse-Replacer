#!/usr/bin/env python3
from __future__ import annotations

import csv
import io
import json
import re
import sys
import urllib.request
import zipfile
from datetime import datetime, timezone
from pathlib import Path


SOURCE_URL = "https://ebible.org/Scriptures/cmn-cu89s_vpl.zip"
SQL_NAME = "cmn-cu89s_vpl.sql"
OUTPUT_PATH = Path("Resources/Bible/cmn-cu89s.json")
CACHE_PATH = Path(".build/downloads/cmn-cu89s_vpl.zip")


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

    payload = {
        "id": "cmn-cu89s",
        "name": "Chinese Union Version (Simplified)",
        "displayName": "新标点和合本（简体）",
        "source": {
            "url": SOURCE_URL,
            "format": "eBible VPL SQL",
            "sourceFile": SQL_NAME,
        },
        "generatedAt": source_updated_at,
        "verses": verses,
    }

    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_PATH.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    print(f"Wrote {OUTPUT_PATH} with {len(verses)} verses", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
