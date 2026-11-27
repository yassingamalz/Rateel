# Rateel — Content production plan
Status: proposed, 2026-11-26. No runtime changes in this branch.
## Sources and decisions
- Editorial inventory: curriculum-draft.json, extracted from scheme A of docs/knowledge-base/06-curriculum.md (13 units, 66 topics).
- Book: Ayman Rushdi Suwayd, التجويد المصور. Chapter PDF links and page references are in lesson-production:docs/production/LESSONS-TRACKER.md; the original PDFs are not in the knowledge-base migration. Verify each topic against the actual book before approval.
- Keep editorial topic IDs distinct from app course/unit/activity IDs. Existing 12 course cards remain unchanged until owner approves crosswalk; check scheme B (meeting letters and solar/lunar lam) and scheme C (29-unit proposal). Verify complete coverage, including iqlab, lam al-tarif, recitation ranks and other items not explicitly listed in A.
- Scope proposed: Hafs 'an Asim, specify transmission path where relevant; verify with qualified reviewer.
## Batches
0. Audit inventory, source coverage, legacy JSON, guided prototypes and Flutter adapters.
1. Pilot U5.L1 (chapter 10.1): reuse v3 guided content, build read/listen/practice/test activities, verify all verse refs and media. Then owner reviews.
2. U0–U2 foundations, speech apparatus, articulation.
3. U3–U4 attributes and pronunciation errors.
4. Remaining U5 nun/meem, meeting letters; reconcile lam al-tarif.
5. U6–U7 madd, vowels and meeting sukoons.
6. U8–U10 special topics, stop/start, hamza and alif.
7. U11–U12 script and memorization.
Work in batches of 3–5 topics; review before runtime publication.
## Per-topic package
- stable topic ID, objectives, prerequisites, source chapter/page and source verification status
- original Arabic explanation (fully vocalized narration), concise captions, glossary
- examples: exact Uthmani text, surah/ayah, target grapheme span, rule ID, context (wasl/waqf), approved recitation reference
- activities: video/guided introduction, read, listen, practice as appropriate; no pretend audio recognition
- question bank: 6–10 original questions where appropriate, single/multiple choice, true/false, text input with accepted variants; distractors and explanations; listening questions require verified audio
- media manifest: narrator, reciter (Husary muallim where licensed), actual clip/timing validation, illustration/animation references, rights
- review status: draft → source_checked → pedagogical_review → integrated → QA_passed → owner_approved. Separate media readiness. Do not publish unfinished activities.
## Flutter integration
Current generated unit and lesson Dart maps originate in Angular JSON via tools/flutter-review/gen_unit_data.py and gen_lesson_data.py. Do not manually edit generated maps. Current TestContent supports singleChoice/multipleChoice/trueFalse/textInput and passingScore defaults to 70. ReadingContent uses text matching due to 38/45 invalid legacy offsets reported in reading_data.dart; validate Unicode grapheme boundaries and repeated occurrences. Existing unit IDs repeat across courses (e.g. pronunciation-practice); lesson IDs may also repeat. Adopt unique scoped IDs and an explicit legacy mapping before regenerating, preserving migration of progress. Guided v3 is Angular; do not assume Flutter can render it. Listening/practice capabilities and persistence must be audited before enabling. Keep canonical content independent of presentation and export adapters rather than duplicating manually. Verify asset packaging and parser behavior with automated tests.
## Definition of done
Source citation and qualified tajwid review, Qur'an text and recitation checked, answer keys and feedback checked, no unsupported media paths, no duplicate IDs, no broken references, RTL and app navigation tested, owner approval. Do not claim certification/ijazah from app completion.
