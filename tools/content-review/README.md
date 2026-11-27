# Content review checks

Run from `docs/content/`. The Uthmani text comes from the npm package `quran-json` 3.1.2
(`npm pack quran-json@3.1.2 && tar xzf quran-json-3.1.2.tgz` gives `package/dist/quran.json`).

- `python3 ../../tools/content-review/verse_check.py <quran.json>`: every `verseRef` + excerpt must exist, word by word,
  in the cited verse(s). Known false positives come from Uthmani spelling (الصلوة، الزكوة، أنبـٔوني).
- `python3 ../../tools/content-review/ending_check.py <quran.json>`: compares the final vowel of each cited word.
  It aligns on the first matching word, so a word repeated earlier in the verse can give a false positive.
- `python3 ../../tools/content-review/struct_check.py`: answer keys inside the options, duplicate ids.
