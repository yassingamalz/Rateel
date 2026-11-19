# Structured lesson for pages 231-256

- Link: https://claude.ai/chat/56987cb3-59a5-42aa-8bf7-f59da44422ba
- Creata: 2026-06-27T18:33:04.719854Z
- Aggiornata: 2026-06-27T18:42:17.684929Z

## Yassin (2026-06-27T18:33)

Read well the pdf and last chat to create well structured lesson for page 231 to 256

_file allegato (non incluso nell'export): Þóƒá (1).pdf_

## Claude (2026-06-27T18:42)

<details><summary>tool: recent_chats</summary>

```json
{
  "n": 5,
  "sort_order": "desc"
}
```
</details>

<details><summary>risultato tool</summary>

```
<chat url='https://claude.ai/chat/2582fa56-c9fa-4caf-9ea6-4dad2173b011' updated_at='2026-06-22T21:21:02.470553+00:00'><untrusted_external_data source="past_conversation">Title: Jaweed course lesson structure planning
Summary: **Conversation Overview**

The person is building a Quran learning app called Rateel, focused on tajweed (Quranic recitation rules) education through short micro-learning video lessons (15–45 seconds each). They provided a complete tajweed course PDF — Al-Tajweed Al-Musawwar (Parts 1 &amp; 2, 584 pages) — and asked Claude to extract its structure and reorganize it into a lesson curriculum split into units and individual lessons suitable for generating content with Claude Design and their app.

Claude extracted the PDF's table of contents using pypdf, identified 24 high-level chapters, and expanded these into a structured curriculum of 13 units and approximately 60 micro-lessons, each with a stable ID format (U#.L#) to use as app keys and filenames. The curriculum was saved as a markdown file covering units from foundational concepts through memorization techniques, with Unit 5 (Rules of Noon and Meem) identified as the core of the Rateel app.

The person then requested production briefs for specific lessons — first U3.L1 (Sifāt overview) and then U1.L2 (Organs of Articulation) — to use as instructions for generating animated lesson videos with Claude Design. Each brief followed a consistent five-scene structure: title card, core concept introduction, main educational content, a synthesis moment, and a closing teaser for the next lesson. Each scene includes exact on-screen Arabic text with full diacritical marks, optional voiceover script, detailed animation specifications (morph-don't-pop principle, specific easing curves, stagger timing, overlapping action), and copy-paste illustration prompts for image generation tools. The established visual identity uses a deep emerald gradient (#1F4037→#0B1C17), gold accents (#DAA520/#FFD700), and soft-green text (#95D5B2), with Kurzgesagt-smooth animation style.

For U1.L2 specifically, the person requested photo-based illustrations rather than flat vectors. Claude specified a realistic mid-sagittal anatomical cross-section of the head as the hero image, color-graded to the emerald/gold palette, with a glowing airflow line as the narrative thread across scenes. The person then asked for the illustration prompts extracted and optimized specifically for ChatGPT image generation. Claude delivered three distinct prompts (title background, hero anatomical cross-section reused across three scenes, and a lips close-up), with a shared style suffix and a note to generate all images text-free since AI tools render Arabic text unreliably, with labels to be added in post-production.</untrusted_external_data></chat>

<chat url='https://claude.ai/chat/c4bd4731-0cfa-40c2-bc82-1e0af24b9a69' updated_at='2026-01-16T01:20:57.611330+00:00'><untrusted_external_data source="past_conversation">Title: Kurzgesagt's Minimalist Animation Style
Summary: **Conversation Overview**

The user is developing an Arabic educational tajweed app and sought guidance on creating high-quality animated videos to explain Islamic pronunciation rules, specifically focusing on nun and meem mushaddad concepts. They were inspired by Kurzgesagt's smooth animation style and wanted to create engaging educational content that matches their app's emerald green and gold color scheme. The user expressed a strong preference for modern, fast-paced content without lengthy traditional introductions, emphasizing that today's learners want to absorb information quickly.

Throughout the conversation, the user refined their vision from a single comprehensive video to a micro-learning series of short videos (15-45 seconds each) that would form a complete learning journey. They were particularly interested in creating a "Yugioh-style fusion animation" to demonstrate how Arabic letters combine with shadda marks to form mushaddad l
[... troncato ...]
```
</details>

Let me look at the established brief format more closely and read the PDF.

<details><summary>tool: conversation_search</summary>

```json
{
  "query": "production brief five scene structure lesson title card animation specs",
  "max_results": 3
}
```
</details>

<details><summary>risultato tool</summary>

```
<chat url="https://claude.ai/chat/2582fa56-c9fa-4caf-9ea6-4dad2173b011" updated_at="2026-06-22T21:21:02.470553+00:00" kind="summary"><untrusted_external_data source="past_conversation">Title: Jaweed course lesson structure planning
Jaweed course lesson structure planning
&lt;chat_summary&gt;**Conversation Overview**

The person is building a Quran learning app called Rateel, focused on tajweed (Quranic recitation rules) education through short micro-learning video lessons (15–45 seconds each). They provided a complete tajweed course PDF — Al-Tajweed Al-Musawwar (Parts 1 &amp; 2, 584 pages) — and asked Claude to extract its structure and reorganize it into a lesson curriculum split into units and individual lessons suitable for generating content with Claude Design and their app.

Claude extracted the PDF's table of contents using pypdf, identified 24 high-level chapters, and expanded these into a structured curriculum of 13 units and approximately 60 micro-lessons, each with a stable ID format (U#.L#) to use as app keys and filenames. The curriculum was saved as a markdown file covering units from foundational concepts through memorization techniques, with Unit 5 (Rules of Noon and Meem) identified as the core of the Rateel app.

The person then requested production briefs for specific lessons — first U3.L1 (Sifāt overview) and then U1.L2 (Organs of Articulation) — to use as instructions for generating animated lesson videos with Claude Design. Each brief followed a consistent five-scene structure: title card, core concept introduction, main educational content, a synthesis moment, and a closing teaser for the next lesson. Each scene includes exact on-screen Arabic text with full diacritical marks, optional voiceover script, detailed animation specifications (morph-don't-pop principle, specific easing curves, stagger timing, overlapping action), and copy-paste illustration prompts for image generation tools. The established visual identity uses a deep emerald gradient (#1F4037→#0B1C17), gold accents (#DAA520/#FFD700), and soft-green text (#95D5B2), with Kurzgesagt-smooth animation style.

For U1.L2 specifically, the person requested photo-based illustrations rather than flat vectors. Claude specified a realistic mid-sagittal anatomical cross-section of the head as the hero image, color-graded to the emerald/gold palette, with a glowing airflow line as the narrative thread across scenes. The person then asked for the illustration prompts extracted and optimized specifically for ChatGPT image generation. Claude delivered three distinct prompts (title background, hero anatomical cross-section reused across three scenes, and a lips close-up), with a shared style suffix and a note to generate all images text-free since AI tools render Arabic text unreliably, with labels to be added in post-production.&lt;/chat_summary&gt;</untrusted_external_data></chat>

<chat url="https://claude.ai/chat/2582fa56-c9fa-4caf-9ea6-4dad2173b011" updated_at="2026-06-22T21:21:02.470553+00:00" kind="conversation"><untrusted_external_data source="past_conversation">Title: Jaweed course lesson structure planning
Jaweed course lesson structure planning
&lt;tool name="visualize:read_me"&gt;
&lt;parameter name="modules"&gt;['art', 'interactive']&lt;/parameter&gt;
&lt;parameter name="platform"&gt;desktop&lt;/parameter&gt;
&lt;/tool&gt;


Human: i have the style give me the content and the isntrucoins of this lesson with animtoan speicdef to have illusrtaions

Assistant: You've got the style locked in — so here's the production brief: the full content (Arabic on-screen + narration), scene-by-scene animation specs, and illustration prompts you can drop straight into Claude Design. I built it for **U3.L1 — الصفات ذات الضد (نظرة عامة)**, the unit opener.
&lt;tool name="create_file"&gt;
&lt;parameter name="description"&gt;Lesson production brief for Unit 3 Lesson 1 (Sifat overview) with content, animation specs, and illustration prompts&lt;/parameter&gt;
&lt;parame
[... troncato ...]
```
</details>

I have the format. Now let me read the PDF — specifically pages 231–256. First let me check what's there.

<details><summary>tool: bash_tool</summary>

```json
{
  "command": "cd /mnt/user-data/uploads && ls -la && echo \"---\" && python3 -c \"\nimport pypdf\nr = pypdf.PdfReader('Þóƒá__1_.pdf')\nprint('Total pages:', len(r.pages))\n\"",
  "description": "List uploads and count PDF pages"
}
```
</details>

<details><summary>risultato tool</summary>

```
{"returncode":0,"stdout":"total 32040\ndrwxr-xr-x 1 claude ubuntu        0 Jun 27 18:33 .\ndrwxr-xr-x 5 root   root       4096 Jun 27 18:33 ..\n-rw-r--r-- 1 claude ubuntu 32802464 Jun 27 18:33 Þóƒá__1_.pdf\n---\nTotal pages: 584\n","stderr":""}
```
</details>

<details><summary>tool: bash_tool</summary>

```json
{
  "command": "cd /mnt/user-data/uploads && python3 -c \"\nimport pypdf\nr = pypdf.PdfReader('Þóƒá__1_.pdf')\n# Check both PDF-index pages around 231-256 (1-indexed pages 231..256 -> idx 230..255)\nfor i in range(228, 257):\n    t = r.pages[i].extract_text() or ''\n    t = t.strip().replace('\\n',' ')\n    print(f'=== PDF page {i+1} (idx {i}) | len={len(t)} ===')\n    print(t[:300])\n    print()\n\"",
  "description": "Extract text from pages around 231-256"
}
```
</details>

<details><summary>risultato tool</summary>

```
{"returncode":0,"stdout":"=== PDF page 229 (idx 228) | len=0 ===\n\n\n=== PDF page 230 (idx 229) | len=0 ===\n\n\n=== PDF page 231 (idx 230) | len=0 ===\n\n\n=== PDF page 232 (idx 231) | len=0 ===\n\n\n=== PDF page 233 (idx 232) | len=0 ===\n\n\n=== PDF page 234 (idx 233) | len=0 ===\n\n\n=== PDF page 235 (idx 234) | len=0 ===\n\n\n=== PDF page 236 (idx 235) | len=0 ===\n\n\n=== PDF page 237 (idx 236) | len=0 ===\n\n\n=== PDF page 238 (idx 237) | len=0 ===\n\n\n=== PDF page 239 (idx 238) | len=0 ===\n\n\n=== PDF page 240 (idx 239) | len=0 ===\n\n\n=== PDF page 241 (idx 240) | len=0 ===\n\n\n=== PDF page 242 (idx 241) | len=0 ===\n\n\n=== PDF page 243 (idx 242) | len=0 ===\n\n\n=== PDF page 244 (idx 243) | len=0 ===\n\n\n=== PDF page 245 (idx 244) | len=0 ===\n\n\n=== PDF page 246 (idx 245) | len=0 ===\n\n\n=== PDF page 247 (idx 246) | len=0 ===\n\n\n=== PDF page 248 (idx 247) | len=0 ===\n\n\n=== PDF page 249 (idx 248) | len=0 ===\n\n\n=== PDF page 250 (idx 249) | len=0 ===\n\n\n=== PDF page 251 (idx 250) | len=0 ===\n\n\n=== PDF page 252 (idx 251) | len=0 ===\n\n\n=== PDF page 253 (idx 252) | len=0 ===\n\n\n=== PDF page 254 (idx 253) | len=0 ===\n\n\n=== PDF page 255 (idx 254) | len=0 ===\n\n\n=== PDF page 256 (idx 255) | len=0 ===\n\n\n=== PDF page 257 (idx 256) | len=0 ===\n\n\n","stderr":""}
```
</details>

Text isn't extractable — this is a scanned/image PDF. Let me read the pdf-reading skill, then rasterize the pages so I can read them visually.

<details><summary>tool: view</summary>

```json
{
  "path": "/mnt/skills/public/pdf-reading/SKILL.md"
}
```
</details>

<details><summary>risultato tool</summary>

```
Input validation errors occurred:
description: Field required
```
</details>

<details><summary>tool: view</summary>

```json
{
  "path": "/mnt/skills/public/pdf-reading/SKILL.md",
  "description": "Read pdf-reading skill for rasterizing scanned PDF pages"
}
```
</details>

<details><summary>risultato tool</summary>

````
     1	---
     2	name: pdf-reading
     3	description: "Use this skill when you need to read, inspect, or extract content from PDF files — especially when file content is NOT in your context and you need to read it from disk. Covers content inventory, text extraction, page rasterization for visual inspection, embedded image/attachment/table/form-field extraction, and choosing the right reading strategy for different document types (text-heavy, scanned, slide-decks, forms, data-heavy). Do NOT use this skill for PDF creation, form filling, merging, splitting, watermarking, or encryption — use the pdf skill instead."
     4	license: Proprietary. LICENSE.txt has complete terms
     5	---
     6	
     7	# PDF Processing Guide
     8	
     9	## Overview
    10	
    11	This guide covers essential PDF reading operations using Python libraries and command-line tools. For advanced features (pypdfium2 rendering, pdfplumber table settings, OCR fallback, encrypted/corrupted PDF handling), see REFERENCE.md.
    12	
    13	## Reading & Inspecting PDFs
    14	
    15	Before doing anything with a PDF, understand what you're working with.
    16	
    17	### Content inventory
    18	
    19	Run a quick diagnostic first. For simple tasks ("summarize this
    20	document"), `pdfinfo` + `pdffonts` + a text sample may suffice. For
    21	anything involving figures, attachments, or extraction issues, run the
    22	full set:
    23	
    24	```bash
    25	# Always: page count, file size, PDF version, metadata
    26	pdfinfo document.pdf
    27	
    28	# Always: does a text layer exist? No fonts → scanned/raster → see "Scanned documents"
    29	pdffonts document.pdf
    30	
    31	# If fonts are present: sample the text layer
    32	pdftotext -f 1 -l 1 document.pdf - | head -20
    33	
    34	# If figures/charts may matter:
    35	pdfimages -list document.pdf
    36	
    37	# If the PDF might contain embedded files (reports, portfolios):
    38	pdfdetach -list document.pdf
    39	```
    40	
    41	This tells you:
    42	- **Page count and size** — how big is the job?
    43	- **Font status** — are any fonts present? An empty `pdffonts` table
    44	  means the PDF is scanned or raster-only: `pdftotext` will return
    45	  nothing, so skip straight to "Scanned documents" below. Fonts shown
    46	  as not embedded ("emb: no") with custom encodings may produce wrong
    47	  characters on extraction.
    48	- **Text extractability** — when fonts exist, does `pdftotext` return
    49	  clean text, or is it garbled (broken encoding)?
    50	- **Embedded raster images** — are there photos or raster figures?
    51	  (Note: vector-drawn charts from matplotlib/Excel won't appear — see
    52	  "Extracting embedded images" below)
    53	- **Attachments** — are there embedded spreadsheets, data files, etc.?
    54	
    55	### Text extraction
    56	
    57	**pypdf** for basic text:
    58	```python
    59	from pypdf import PdfReader
    60	
    61	reader = PdfReader("document.pdf")
    62	print(f"Pages: {len(reader.pages)}")
    63	
    64	# Extract text
    65	text = ""
    66	for page in reader.pages:
    67	    text += page.extract_text()
    68	```
    69	
    70	**pdftotext** preserving layout (better for multi-column docs):
    71	```bash
    72	# Layout mode preserves spatial positioning
    73	pdftotext -layout document.pdf output.txt
    74	
    75	# Specific page range
    76	pdftotext -f 1 -l 5 document.pdf output.txt
    77	```
    78	
    79	**pdfplumber** for layout-aware extraction with positioning data:
    80	```python
    81	import pdfplumber
    82	
    83	with pdfplumber.open("document.pdf") as pdf:
    84	    for page in pdf.pages:
    85	        text = page.extract_text()
    86	        print(text)
    87	```
    88	
    89	### Visual inspection (rasterize pages)
    90	
    91	Text extraction is **blind** to charts, diagrams, figures, equations,
    92	multi-column layout, and form structures. When any of these matter,
    93	rasterize
[... troncato ...]
````
</details>

This is a scanned Arabic book. I'll rasterize the pages and read them visually. Let me start.

<details><summary>tool: bash_tool</summary>

```json
{
  "command": "cd /mnt/user-data/uploads && mkdir -p /tmp/pg && pdftoppm -jpeg -r 130 -f 231 -l 256 \"Þóƒá__1_.pdf\" /tmp/pg/page && ls /tmp/pg/ | head",
  "description": "Rasterize PDF pages 231-256 to JPEGs"
}
```
</details>

<details><summary>risultato tool</summary>

```
{"returncode":0,"stdout":"page-231.jpg\npage-232.jpg\npage-233.jpg\npage-234.jpg\npage-235.jpg\npage-236.jpg\npage-237.jpg\npage-238.jpg\npage-239.jpg\npage-240.jpg\n","stderr":""}
```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read PDF page 231 to identify content and printed page number",
  "path": "/tmp/pg/page-231.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

PDF p.231 = printed p.229. This is the chapter opener: **الحرفان الملتقيان** (The Two Meeting Letters) — covering idghām and the four states. Let me read through all the pages.

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 232",
  "path": "/tmp/pg/page-232.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 233",
  "path": "/tmp/pg/page-233.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 234",
  "path": "/tmp/pg/page-234.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 235",
  "path": "/tmp/pg/page-235.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 236",
  "path": "/tmp/pg/page-236.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 237",
  "path": "/tmp/pg/page-237.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 238",
  "path": "/tmp/pg/page-238.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 239",
  "path": "/tmp/pg/page-239.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 240",
  "path": "/tmp/pg/page-240.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 241",
  "path": "/tmp/pg/page-241.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 242",
  "path": "/tmp/pg/page-242.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 243",
  "path": "/tmp/pg/page-243.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 244",
  "path": "/tmp/pg/page-244.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 245",
  "path": "/tmp/pg/page-245.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 246",
  "path": "/tmp/pg/page-246.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 247",
  "path": "/tmp/pg/page-247.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 248",
  "path": "/tmp/pg/page-248.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 249",
  "path": "/tmp/pg/page-249.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 250",
  "path": "/tmp/pg/page-250.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 251",
  "path": "/tmp/pg/page-251.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 252",
  "path": "/tmp/pg/page-252.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 253",
  "path": "/tmp/pg/page-253.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 254",
  "path": "/tmp/pg/page-254.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 255",
  "path": "/tmp/pg/page-255.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

<details><summary>tool: view</summary>

```json
{
  "description": "Read page 256 (last page of range)",
  "path": "/tmp/pg/page-256.jpg"
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

I've read the full range. Pages 231–256 (printed 229–254) cover two complete chapters: **الإدغام / الحرفان الملتقيان** (Idghām & the four states of two meeting letters) and **لام التعريف** (the Lām of Definition — qamari & shamsi). I'll structure this into two units of micro-lessons and write full production briefs in your established 5-scene format.

<details><summary>tool: bash_tool</summary>

```json
{
  "command": "mkdir -p /mnt/user-data/outputs",
  "description": "Ensure outputs dir exists"
}
```
</details>

<details><summary>risultato tool</summary>

```
{"returncode":0,"stdout":"","stderr":""}
```
</details>

**File creato: `/mnt/user-data/outputs/U6-U7_Idgham_LamTareef_briefs.md`**

```
# رَتِّل — سلسلة دروس: الإدغام ولام التعريف
# Rateel Lesson Series — Idghām & Lām al-Taʿrīf

**Source:** *التجويد المصوَّر* — printed pp. **229–254** (PDF pp. 231–256)
**Tilāwah reference:** حفص عن عاصم، طريق الشاطبية (the practical rulings below follow Ḥafṣ; Ṭayyibah variants noted where relevant)

This range is two complete chapters. It is split into **two units / 8 micro-lessons** (15–45s each), each lesson teasing the next so the sequence reads as one journey.

| Unit | Lessons | Topic | Pages |
|------|---------|-------|-------|
| **U6 — الإدغام والحرفان الملتقيان** | U6.L1–L5 | What idghām is + the 4 states of two meeting letters | 229–247 |
| **U7 — لام التعريف** | U7.L1–L3 | The definite-article lām: qamariyyah & shamsiyyah | 248–253 |

> Unit numbers U6/U7 are provisional — slot them after U5 (Noon & Meem) and renumber if needed. The IDs (U#.L#) are the app keys / filenames.

---

## 0) Global style — apply to every scene
> القواعد العامة — لضمان التدفّق المستمر (morph-don't-pop).

- **Morph, never pop.** Any element leaving the frame *transforms* into the next (scale/position/shape). Nothing disappears abruptly.
- **Easing:** entrances `cubic-bezier(0.22, 1, 0.36, 1)` (ease-out-back-soft); between-scene motion `cubic-bezier(0.4, 0, 0.2, 1)`.
- **Stagger:** multiple elements enter `120–150ms` apart.
- **Scene transitions:** cross-fade + slight scale (never a hard cut). The emerald background and faint Islamic 8-point-star pattern stay fixed throughout for continuity.
- **Overlap:** start the next scene's motion ~`0.3s` before the previous ends (overlapping action).
- **Palette tokens (pass to Claude Design):** bg `#1F4037 → #0B1C17` · gold `#DAA520 / #FFD700` · glow `#FFE355` · soft-green text `#95D5B2` · soft-gold text `#DFC298` · white `#FFFFFF`.
- **Arabic = post-production.** Generate all illustrations **text-free**; AI renders Arabic unreliably. On-screen Arabic (with full diacritics, exactly as written here) is added as a text layer in editing.

## 0b) Two unifying visual motifs (the "thread" across each unit)
- **U6 — the Fusion motif (Yugioh-style):** two letter-cards slide toward each other and **fuse** into a single letter wearing a glowing **شدّة**. This *is* idghām, visualized. Reuse the same fusion mechanic in every U6 lesson so learners feel the rule, not just read it.
- **U7 — the Moon ☾ / Sun ☀ motif:** **Qamariyyah** = a calm moon; the لام stays **visible** (clear). **Shamsiyyah** = a bright sun; the لام **dissolves into light** and the next letter lights up with a shadda. The names carry the animation.

---

# UNIT 6 — الإدغام والحرفان الملتقيان

## U6.L1 — ما هو الإدغام؟ | What is Idghām?

| Field | Value |
|-------|-------|
| **ID** | `U6.L1` |
| **Duration** | ~35s |
| **Type** | Unit opener (defines the term + sets the Fusion motif) |
| **Objective** | المتعلّم يعرف أن الإدغام لغةً «الإدخال»، واصطلاحًا: إدخال حرفٍ ساكنٍ في متحرّكٍ بعده فيصيران حرفًا واحدًا مشدَّدًا. |

**المشهد ١ — العنوان (0:00–0:04)**
- **ON-SCREEN:** `الإِدْغَام` (gold, large) → under it: `الحَرْفانِ المُلْتَقِيانِ`
- **VO:** «حين يلتقي حرفانِ… أحيانًا يندمجان فيصيرانِ حرفًا واحدًا. هذا هو الإدغام.»
- **MOTION:** title rises with stagger; a thin gold underline draws L→R; single soft gold pulse.

**المشهد ٢ — المعنى اللغوي (0:04–0:12)**
- **ON-SCREEN:** `لُغَةً: الإِدْخَال`
- **VO:** «الإدغامُ في اللغة: الإدخال — كإدخالِ السيفِ في غِمدِه.»
- **MOTION:** a stylized **sword slides into its sheath** (the book's own image), morphing on exit into two letter-cards for the next scene.
- **ILLUSTRATION (text-free):** *"A single elegant Arabian sabre sliding smoothly into an ornate sheath, side view, deep emerald gradient background (#1F4037→#0B1C17), subtle gold filigree on the scabbard, warm gold rim-light, flat clean Kurzgesagt vector style, generous negative space."*

**المشهد ٣ — التعريف الاصطلاحي + الاندماج (0:12–0:24)**
- **ON-SCREEN:** `اصْطِلاحًا: إِيصالُ حرفٍ ساكنٍ بحرفٍ متحرِّكٍ فيصيرانِ حرفًا واحدًا مُشدَّدًا`
- **VO:** «اصطلاحًا: نُوصِلُ حرفًا ساكنًا بحرفٍ متحرِّك… فيصيرانِ حرفًا واحدًا مشدَّدًا من جنسِ الثاني.»
- **MOTION (the Fusion — core of the unit):** two gold letter-cards slide in from both sides; as they touch, a glow flares, they **merge** into one card whose letter now carries a pulsing **ـّ (شدّة)**.

**المشهد ٤ — مثال من القرآن (0:24–0:31)**
- **ON-SCREEN:** `﴿ وَلْيَكْتُب بَّيْنَكُم ﴾` (highlight the **بْ + ب → بّ** in gold)
- **VO:** «﴿وَلْيَكْتُب بَّيْنَكُم﴾ — الباءُ الساكنةُ دخلَتْ في الباءِ بعدَها.»
- **MOTION:** the highlighted letters lift out of the āyah, run the Fusion mechanic, then settle back glowing.

**المشهد ٥ — تشويق (0:31–0:35)**
- **ON-SCREEN:** `لكن… متى يجبُ الإدغام؟ ابدأ بِـ: الحرفانِ المُتماثلان`
- **VO:** «فمتى يقعُ هذا الاندماج؟ يبدأُ كلُّ شيءٍ من حرفينِ… متماثِلَين.»
- **MOTION:** the fused letter splits into two identical twins → cross-fade to U6.L2.

---

## U6.L2 — الحرفان المُتماثلان | Identical Letters

| Field | Value |
|-------|-------|
| **ID** | `U6.L2` |
| **Duration** | ~35s |
| **Objective** | حرفان اتّفقا في المخرجِ والصفة. إذا سكَنَ الأوّلُ (وليس حرفَ مدّ) وجبَ الإدغام؛ وإن تحرَّك أو كان مدًّا فلا إدغام. |

**المشهد ١ — العنوان (0:00–0:04)**
- **ON-SCREEN:** `الحَرْفانِ المُتَماثِلان`
- **MOTION:** two identical twin-cards drop in side by side, mirrored.

**المشهد ٢ — التعريف (0:04–0:11)**
- **ON-SCREEN:** `هما المُتَّفِقانِ في المَخْرَجِ والصِّفَةِ` → `(الحرف نفسه مرّتين)`
- **VO:** «المتماثلان: حرفانِ اتّفقا في المخرجِ والصفةِ — أي الحرفُ نفسُه مرّتين.»
- **MOTION:** twins overlap to show they're identical; a small "=" glows between them.

**المشهد ٣ — الحكم: وجوب الإدغام (0:11–0:22)**
- **ON-SCREEN:** `إذا سَكَنَ الأوّلُ ← وَجَبَ الإدغام` then examples in gold:
  `﴿ وَقَد دَّخَلُوا ﴾ · ﴿ بَل لَّا ﴾ · ﴿ يُدْرِككُّم ﴾`
- **VO:** «إنْ كان الأوّلُ ساكنًا، وجبَ الإدغام: ﴿وَقَد دَّخَلوا﴾، ﴿بَل لَّا﴾، ﴿يُدْرِككُّم﴾.»
- **MOTION:** each example runs the **Fusion** mechanic → resolves to one shaddah'd letter.

**المشهد ٤ — الاستثناء (0:22–0:31)**
- **ON-SCREEN:** `فإنْ تحرَّكَ الأوّلُ، أو كان حرفَ مَدٍّ ← فلا إدغام` then:
  `﴿ يَعْلَمُ مَا ﴾ · ﴿ فِي يَوْمٍ ﴾ · ﴿ ٱصْبِرُوا وَصَابِرُوا ﴾`
- **VO:** «أمّا إنْ تحرَّكَ الأوّل، أو كان حرفَ مدّ — فلا إدغام، يبقى كلٌّ ظاهرًا.»
- **MOTION:** the two cards approach but a soft gold barrier keeps them apart; they stay separate (the *anti*-fusion — reinforces the rule by contrast).

**المشهد ٥ — تشويق (0:31–0:35)**
- **ON-SCREEN:** `وإذا اتّفقا في المخرجِ فقط؟ ← المُتجانِسان`
- **MOTION:** one twin morphs into a *different* letter sharing the same mouth-position → cross-fade to U6.L3.

---

## U6.L3 — الحرفان المُتجانِسان | Homogeneous Letters

| Field | Value |
|-------|-------|
| **ID** | `U6.L3` |
| **Duration** | ~45s (densest lesson — has the 8 cases) |
| **Objective** | حرفان اتّفقا في المخرجِ واختلفا في بعضِ الصفات. لحفص (الشاطبية) تُدغَم في الحالات الواردة. الحالات الثماني، مع كون (ط→ت) إدغامًا ناقصًا. |

**المشهد ١ — العنوان (0:00–0:04)**
- **ON-SCREEN:** `الحَرْفانِ المُتَجانِسان`

**المشهد ٢ — التعريف (0:04–0:11)**
- **ON-SCREEN:** `مُتَّفِقانِ في المَخْرَجِ · مُختَلِفانِ في بعضِ الصِّفات`
- **VO:** «المتجانسان: من مخرجٍ واحد، لكنّهما يختلفانِ في بعضِ الصفات.» مثال: `﴿ قَد تَّبَيَّنَ ﴾`
- **MOTION:** two cards from the *same* mouth-point; a small mouth/makhraj icon glows beneath both.

**المشهد ٣ — الحالات الثماني (0:11–0:32)**
- **ON-SCREEN (list, each animates in then runs Fusion):**
  1. `د في ظ — ﴿ إِذ ظَّلَمْتُم ﴾ → تُقرأ: إِظَّلَمْتُم`
  2. `د في ت — ﴿ قَد تَّبَيَّنَ ﴾ → قَتَّبَيَّنَ`
  3. `ت في د — ﴿ أَثْقَلَت دَّعَوَا ﴾ → أَثْقَلَدَّعَوَا`
  4. `ت في ط — ﴿ فَآمَنَت طَّائِفَةٌ ﴾ → فَآمَنَطَّائِفَة`
  5. `ل في ر — ﴿ قُل رَّبِّ ﴾ → قُرَّبِّ`
  6. `ث في ذ — ﴿ يَلْهَث ذَّلِكَ ﴾ → يَلْهَذَّالِك`
  7. `ب في م — ﴿ ٱرْكَب مَّعَنَا ﴾ → ٱرْكَمَّعَنَا`
  8. `ط في ت — ﴿ أَحَطتُّ ﴾ (إدغام ناقص)`
- **VO (brisk):** «ثماني حالات: الدالُ في الظاء، الدالُ في التاء، التاءُ في الدال، التاءُ في الطاء، اللامُ في الراء، الثاءُ في الذال، الباءُ في الميم، والطاءُ في التاء.»
- **MOTION:** items enter as a fast gold cascade (stagger 120ms). Cases 1–7 fuse fully; case 8 fuses *partially* — see next scene.

**المشهد ٤ — نقطة الإتقان: الإدغام الناقص (0:32–0:40)**
- **ON-SCREEN:** `الطاءُ في التاء = إدغامٌ ناقص — يبقى الإطباق` examples: `﴿ بَسَطتَ ﴾ · ﴿ فَرَّطتُ ﴾`
- **VO:** «الطاءُ في التاءِ إدغامٌ **ناقص**: يندمجُ الحرفُ لكن تبقى صفةُ الإطباق — لأنّ القويَّ لا يَذوبُ كلُّه في الضعيف.»
- **MOTION:** the ط-card slides into the ت-card but a **gold ring (الإطباق)** stays visible around the seam — fusion that's *almost*, not total.
- **NOTE (post-production caption, small):** `لحفص من الشاطبية: إدغام · ومن الطيّبة: الإظهار والإدغام في (يَلْهَث ذَّلِك) و(ٱرْكَب مَّعَنَا)`

**المشهد ٥ — تشويق (0:40–0:45)**
- **ON-SCREEN:** `وإذا تقاربا فقط دون اتّفاق؟ ← المُتقارِبان`
- **MOTION:** the two same-makhraj cards drift slightly apart into *near* (not same) positions → cross-fade to U6.L4.

---

## U6.L4 — الحرفان المُتقارِبان | Close Letters

| Field | Value |
|-------|-------|
| **ID** | `U6.L4` |
| **Duration** | ~40s |
| **Objective** | حرفان تقاربا في المخرجِ أو الصفة. منه ما اتُّفق على إدغامه (ل في ر، ق في ك، اللام الشمسية، النون/التنوين في «لم يَروِ»)، ومنه المختلَف فيه — **وحفصٌ يُظهره**. |

**المشهد ١ — العنوان (0:00–0:04)**
- **ON-SCREEN:** `الحَرْفانِ المُتَقارِبان`

**المشهد ٢ — التعريف (0:04–0:10)**
- **ON-SCREEN:** `تَقارَبا في المَخْرَجِ والصِّفَةِ — لا اتّفاقَ تامّ`
- **VO:** «المتقاربان: تقاربا في المخرجِ أو الصفة، دون أن يتطابقا.»
- **MOTION:** two cards sit *near* each other; a short gold arc bridges the gap.

**المشهد ٣ — المُتَّفَقُ عليه (0:10–0:24)**
- **ON-SCREEN (cascade, each fuses):**
  - `ل في ر — ﴿ وَقُل رَّبِّ ﴾`
  - `ق في ك — ﴿ أَلَمْ نَخْلُقكُّم ﴾ (إدغام كامل لحفص)`
  - `اللام الشمسية (١٣ حرفًا) ⟵ درس قادم`
  - `النون الساكنة والتنوين في «لَمْ يَرْوِ» ⟵ وحدة النون`
- **VO:** «المُتَّفَقُ على إدغامه: اللامُ في الراء، والقافُ في الكاف، واللامُ الشمسية، والنونُ الساكنةُ والتنوينُ في حروفِ «لَمْ يَرْوِ».»
- **MOTION:** first two run Fusion; the last two appear as **linked door-cards** that glow toward future lessons (visual cross-linking).

**المشهد ٤ — نقطة الإتقان: المختلَفُ فيه ← حفصٌ يُظهِر (0:24–0:35)**
- **ON-SCREEN:** `المختلَفُ فيه: ﴿ فَقَد ضَّلَّ ﴾ · ﴿ كَذَّبَت ثَّمُودُ ﴾`  →  `وحفصٌ عن عاصمٍ يُظهِرُ ذلك كلَّه`
- **VO:** «وبعضُه مختلَفٌ فيه — كالدالِ في الضاد، والتاءِ في الثاء. **وحفصٌ يُظهِرُها جميعًا**، فاقرأها واضحةً بلا إدغام.»
- **MOTION:** the two cards approach, the gold barrier appears (anti-fusion), and a clear `إِظْهار` stamp lands — important practical correction for the reciter.

**المشهد ٥ — تشويق (0:35–0:40)**
- **ON-SCREEN:** `وإذا تباعدَ الحرفانِ تمامًا؟ ← المُتباعِدان`
- **MOTION:** the two cards push fully apart to opposite edges → cross-fade to U6.L5.

---

## U6.L5 — المُتباعِدان وعلاماتُ المصحف | Distant Letters + Mushaf Signs

| Field | Value |
|-------|-------|
| **ID** | `U6.L5` |
| **Duration** | ~40s |
| **Type** | Unit closer (4th state + how to *read the marks*) |
| **Objective** | المتباعدان = الإظهار في كلِّ القراءات. ويعرف المتعلّم علامةَ الإدغام الكامل (تجريد + شدّة) والناقص (تجريد بلا شدّة) في ضبطِ المصحف. |

**المشهد ١ — العنوان (0:00–0:04)**
- **ON-SCREEN:** `الحَرْفانِ المُتَباعِدان`

**المشهد ٢ — التعريف والحكم (0:04–0:14)**
- **ON-SCREEN:** `تَباعَدا في المَخْرَجِ والصِّفَةِ ← حُكمُهما: الإظهارُ مُطلقًا` examples:
  `﴿ مَنْ ءَامَنَ ﴾ · ﴿ أَنْعَمْتَ عَلَيْهِمْ ﴾ · ﴿ تَشْكُرُونَ ﴾`
- **VO:** «المتباعدان: بعيدانِ في المخرجِ والصفة — وحُكمُهما الإظهارُ في كلِّ القراءات.»
- **MOTION:** two cards sit far apart, each fully lit and separate; no fusion — calm and clear.

**المشهد ٣ — الخريطة الكاملة (0:14–0:24)**
- **ON-SCREEN (a 4-step ladder builds):** `مُتماثِلان · مُتجانِسان · مُتقارِبان · مُتباعِدان` with a closeness meter: `كامل الاندماج ⟵⟶ كامل الانفصال`
- **VO:** «فالحرفانِ الملتقيانِ أربعة: متماثلان، فمتجانسان، فمتقاربان، فمتباعدان — من تمامِ الاندماجِ إلى تمامِ الانفصال.»
- **MOTION:** the four states snap onto a single gold gradient bar (fusion→separation), unifying the whole unit in one frame.

**المشهد ٤ — اقرأ العلامة في المصحف (0:24–0:35)**
- **ON-SCREEN:**
  - `إدغام كامل: تجريدُ الأوّلِ من السكون + شدّةٌ على التالي ← ﴿ يُدْرِككُّم ﴾`
  - `إدغام ناقص: تجريدٌ من السكون + بلا شدّة ← ﴿ بَسَطتَ ﴾`
- **VO:** «وتعرفُها من المصحف: الإدغامُ الكاملُ — لا سكونَ على الأوّل، وشدّةٌ على الثاني. والناقصُ — لا سكونَ ولا شدّة.»
- **MOTION:** zoom on a mushaf-style glyph; the **sukoon lifts off** the first letter (morph), then a **shadda fades in** on the second for the complete case; for the incomplete case the shadda is conspicuously *absent*.
- **ILLUSTRATION (text-free):** *"Extreme close-up of a single ornate gold Arabic diacritic mark (a shadda shape) glowing softly on a parchment-toned panel, deep emerald vignette around the edges (#0B1C17), warm #FFE355 glow, flat elegant vector, lots of empty space for text overlay."*

**المشهد ٥ — تشويق (0:35–0:40)**
- **ON-SCREEN:** `أشهرُ إدغامٍ تراه كلَّ يوم… في «الـ» ← وحدة: لام التعريف`
- **VO:** «وأشهرُ مواضعِ الإدغامِ تلقاها في كلِّ آية… في لامِ التعريف.»
- **MOTION:** a glowing `الـ` forms from the gradient bar → cross-fade to U7.L1.

---

# UNIT 7 — لام التعريف

## U7.L1 — لام التعريف: قمرية وشمسية | The Definite Lām: Overview

| Field | Value |
|-------|-------|
| **ID** | `U7.L1` |
| **Duration** | ~30s |
| **Type** | Unit opener (defines + sets the Moon/Sun motif) |
| **Objective** | لام التعريف: لامٌ ساكنة قبل الأسماء يسبقها همزةُ وصل. حالتانِ مع ما بعدها: قمرية (مُظهَرة) وشمسية (مُدغَمة). |

**المشهد ١ — العنوان (0:00–0:04)**
- **ON-SCREEN:** `لامُ التَّعريف` → `الْـ`

**المشهد ٢ — التعريف (0:04–0:12)**
- **ON-SCREEN:** `لامٌ ساكنةٌ قبلَ الأسماءِ لتعريفِها · يسبقُها همزةُ وصلٍ مفتوحة` examples: `﴿ الْجِبَال ﴾ · ﴿ السَّمَاء ﴾`
- **VO:** «لامُ التعريف: لامٌ ساكنةٌ تُجعَلُ قبلَ الاسمِ لتعريفِه، يسبقُها همزةُ وصلٍ مفتوحة.»
- **MOTION:** `الْـ` clicks onto the front of a noun-card; the alif glows as waṣl.

**المشهد ٣ — الانقسام: قمرية / شمسية (0:12–0:22)**
- **ON-SCREEN (split screen):** left `قَمَرِيّة ☾ — مُظهَرة عند ١٤ حرفًا` · right `شَمْسِيّة ☀ — مُدغَمة في ١٤ حرفًا`
- **VO:** «ولها حالتان مع الحرفِ بعدها: قمريّةٌ تُنطَقُ فيها اللام، وشمسيّةٌ تختفي فتُدغَم.»
- **MOTION:** frame splits; a **moon** rises on the left, a **sun** blazes on the right (the unit's motif lands here).

**المشهد ٤ — لمحة سريعة (0:22–0:27)**
- **ON-SCREEN:** `الْقَمَر (تظهر اللام) · الشَّمْس (تختفي اللام)`
- **VO:** «اسمعِ الفرق: الْـقَمَر… والشَّـمْس.»
- **MOTION:** under the moon, لام stays bold; under the sun, لام **dissolves into rays** and the ش lights with a shadda.

**المشهد ٥ — تشويق (0:27–0:30)**
- **ON-SCREEN:** `ابدأ بالأسهل ← اللام القمرية`
- **MOTION:** moon zooms forward → cross-fade to U7.L2.

---

## U7.L2 — اللام القمرية | The Lunar (Clear) Lām

| Field | Value |
|-------|-------|
| **ID** | `U7.L2` |
| **Duration** | ~35s |
| **Objective** | تُظهَر اللام عند ١٤ حرفًا (لبُعدِ مخرجِها)، مجموعةٌ في «اِبْغِ حَجَّكَ وَخَفْ عَقيمَهُ». علامتُها في المصحف: رأسُ خاءٍ صغيرة فوق اللام. |

**المشهد ١ — العنوان (0:00–0:04)**
- **ON-SCREEN:** `اللامُ القَمَريّة ☾`
- **MOTION:** calm moon glows; a clear `الْـ` beneath it.

**المشهد ٢ — القاعدة (0:04–0:12)**
- **ON-SCREEN:** `تَظهَرُ اللامُ عند ١٤ حرفًا — لِبُعدِ مَخرجِها عنها`
- **VO:** «في اللامِ القمرية، تُنطَقُ اللامُ واضحةً — لأنّ مخرجَها بعيدٌ عن الحرفِ بعدَها.»
- **MOTION:** لام and the next letter sit apart with a clear gap; لام stays solid (no fusion).

**المشهد ٣ — المفتاح: ابغِ حجَّك وخَف عقيمَه (0:12–0:24)**
- **ON-SCREEN:** `جمعَها الجَمزوريُّ في: «اِبْغِ حَجَّكَ وَخَفْ عَقيمَهُ»` → highlight letters: `ء ب غ ح ج ك و خ ف ع ق ي م ه`
- **VO:** «وحروفُها أربعةَ عشرَ، جمعَها الجمزوريُّ في: اِبْغِ حَجَّكَ وَخَفْ عَقيمَهُ.»
- **MOTION:** the mnemonic writes itself L-of-each-word; the 14 key letters pop gold in sequence (stagger 130ms).

**المشهد ٤ — أمثلة + علامة المصحف (0:24–0:32)**
- **ON-SCREEN:** `﴿ الْجِبَال ﴾ · ﴿ الْقَمَر ﴾ · ﴿ الْأَرْض ﴾ · ﴿ الْحَجّ ﴾` → `العلامة: رأسُ خاءٍ ( ﺤ ) فوق اللام`
- **VO:** «الْجِبال، الْقَمَر، الْأرض، الْحَجّ. وعلامتُها في المصحفِ: رأسُ خاءٍ صغيرةٌ فوقَ اللام.»
- **MOTION:** examples cascade; zoom on the little **head-of-khā sukoon sign** fading in above the lām.

**المشهد ٥ — تشويق (0:32–0:35)**
- **ON-SCREEN:** `وإذا اختفتِ اللام؟ ← اللام الشمسية`
- **MOTION:** moon sets, a sunrise glow begins → cross-fade to U7.L3.

---

## U7.L3 — اللام الشمسية | The Solar (Merged) Lām

| Field | Value |
|-------|-------|
| **ID** | `U7.L3` |
| **Duration** | ~35s |
| **Type** | Unit closer |
| **Objective** | تُدغَم اللام في ١٤ حرفًا مقاربًا لها (إدغامٌ كامل، شدّةٌ على ما بعدها)، مجموعةٌ في أوائلِ كلماتِ بيتِ الجمزوري. علامتُها: تجريدُ اللام + شدّة. |

**المشهد ١ — العنوان (0:00–0:04)**
- **ON-SCREEN:** `اللامُ الشمسيّة ☀`
- **MOTION:** bright sun; `الـ` beneath, already shimmering.

**المشهد ٢ — القاعدة (0:04–0:12)**
- **ON-SCREEN:** `تُدغَمُ اللامُ في ١٤ حرفًا مُقارِبًا لها (ومع اللامِ هي من المُتماثِلَين)`
- **VO:** «في الشمسية، تختفي اللامُ فتُدغَمُ في الحرفِ بعدَها، ويُشدَّد.»
- **MOTION:** لام **dissolves into rays** and pours into the next letter, which lights up with a shadda — the Fusion motif from U6, now in sun form (ties the two units together).

**المشهد ٣ — المفتاح: بيت الجمزوري (0:12–0:24)**
- **ON-SCREEN:** `أوائلُ كلماتِ:` `طِبْ ثُمَّ صِلْ رِحْمًا تَفُزْ ضِفْ ذَا نِعَمْ` / `دَعْ سُوءَ ظَنٍّ زُرْ شَريفًا لِلْكَرَمْ`
- **VO:** «وحروفُها أربعةَ عشرَ، أوائلُ كلماتِ بيتِ الجمزوري: طِبْ ثُمَّ صِلْ رِحْمًا تَفُزْ ضِفْ ذا نِعَم…»
- **MOTION:** the two miṣrāʿs write in; the first letter of each word ignites (ط ث ص ر ت ض ذ ن د س ظ ز ش ل).

**المشهد ٤ — أمثلة + علامة المصحف (0:24–0:32)**
- **ON-SCREEN:** `﴿ وَالشَّمْس ﴾ · ﴿ السَّمَاء ﴾ · ﴿ الدَّاعِ ﴾ · ﴿ اللَّيْل ﴾` → `العلامة: لا سكونَ على اللام + شدّةٌ على التالي`
- **VO:** «وَالشَّمْس، السَّماء، الدَّاعِ، اللَّيْل. وعلامتُها: تُجرَّدُ اللامُ من السكون، وتُوضَعُ الشدّةُ على الحرفِ بعدَها.»
- **MOTION:** zoom: the **sukoon lifts off the lām**, a **shadda fades onto the next letter** (mirrors U6.L5 — reinforces "read the mark").

**المشهد ٥ — خاتمة / تشويق (0:32–0:35)**
- **ON-SCREEN:** `الْـ قمر ☾ تَظهَر · الشَّمس ☀ تُدغَم — والآن: أحكامُ النون`
- **VO:** «قمريّةٌ تَظهَر، وشمسيّةٌ تُدغَم. وبعدها… أحكامُ النونِ الساكنةِ والتنوين.»
- **MOTION:** moon and sun settle side by side as a clean summary frame → tease next unit.

---

## Appendix — text-free illustration prompts (copy-paste)
Each is sized for reuse across scenes; **never** bake Arabic into these — add it in post.

1. **Unit-6 title / fusion background** — *"Deep emerald gradient background (#1F4037→#0B1C17), faint gold 8-point Islamic star pattern at 6% opacity, two abstract glowing gold rounded cards drifting toward a bright center flare where they merge, warm #FFE355 glow at the seam, flat clean Kurzgesagt vector, generous central negative space for a letter overlay. No text."*
2. **Sword & sheath** — see U6.L1 Scene 2.
3. **Diacritic close-up (shadda)** — see U6.L5 Scene 4.
4. **Closeness meter bar** — *"A single horizontal gold gradient bar going from a tight merged glow on one end to two fully separated glowing dots on the other, deep emerald background, soft #FFE355 highlights, minimal flat infographic style, space above for four labels. No text."*
5. **Unit-7 Moon ☾** — *"A serene crescent moon in soft gold (#DAA520) glowing over a deep emerald night gradient (#1F4037→#0B1C17), faint star pattern, calm and clear, flat elegant vector, large empty foreground for an Arabic word overlay. No text."*
6. **Unit-7 Sun ☀** — *"A radiant stylized sun with smooth gold rays (#FFD700) over a deep emerald gradient, warm #FFE355 bloom, rays beginning to dissolve into light particles on one side, flat Kurzgesagt vector, generous empty space for overlay. No text."*

## Production notes
- **Tilāwah:** all rulings above are stated for **Ḥafṣ**. The key practical corrections to surface in-app: (a) the **مختلَف فيه** mutaqāribayn (فَقَد ضَّلَّ، كَذَّبَت ثَّمُودُ) are read **iẓhār** by Ḥafṣ; (b) ط→ت is **incomplete** idghām (keep الإطباق); (c) يَلْهَث ذَّلِك and ٱرْكَب مَّعَنَا are idghām via Shāṭibiyyah, with iẓhār also allowed via Ṭayyibah.
- **Sequencing:** U6 (5 lessons) → U7 (3 lessons). Each ending teases the next; U7.L1 explicitly references U6's idghām so learners feel لام شمسية as "the idghām you already know."
- **Reused mechanic = retention:** the Fusion animation recurs in U6.L1/L2/L3/L4 and U7.L3 (as the sun-dissolve). Build it once as a component and re-skin it.

```

<details><summary>risultato tool</summary>

```
File created successfully: /mnt/user-data/outputs/U6-U7_Idgham_LamTareef_briefs.md
```
</details>

<details><summary>tool: present_files</summary>

```json
{
  "filepaths": [
    "/mnt/user-data/outputs/U6-U7_Idgham_LamTareef_briefs.md"
  ]
}
```
</details>

<details><summary>risultato tool</summary>

```

```
</details>

Done. The page range (printed 229–254) was two full chapters, so I structured it as **two units / 8 micro-lessons**, each with a complete 5-scene production brief in your established format:

**U6 — الإدغام والحرفان الملتقيان** (5 lessons): what idghām is → المتماثلان → المتجانسان (the 8 cases) → المتقاربان → المتباعدان + how to read the mushaf marks.

**U7 — لام التعريف** (3 lessons): overview → القمرية (ابغ حجك وخف عقيمه) → الشمسية (Jamzūrī's line).

Two things I built in deliberately:
- A reusable **Fusion animation** (your Yugioh-style "two letters → one mushaddad") as the visual thread for all of U6 — and it returns in U7.L3 as the sun-dissolve, so shamsiyyah lands as "the idghām you already learned." For U7 I leaned on the built-in **moon ☾ / sun ☀** motif.
- The Ḥafṣ-specific corrections that matter for a recitation app, flagged in the briefs: the disputed mutaqāribayn (فَقَد ضَّلَّ، كَذَّبَت ثَّمُودُ) are **iẓhār** for Ḥafṣ; ط→ت is **incomplete** idghām; and the Shāṭibiyyah/Ṭayyibah split on يَلْهَث ذَّلِك and ٱرْكَب مَّعَنَا.

Each scene has exact diacritized Arabic, optional VO, motion specs (your easing/stagger/overlap rules), and text-free illustration prompts. One judgment call worth your eye: I provisionally numbered these U6/U7 (after Noon & Meem) — renumber if they sit elsewhere in your curriculum.

Want me to expand any single lesson into a standalone brief file, or adapt the illustration prompts for a specific tool (ChatGPT / Midjourney)?

_file allegato (non incluso nell'export): page-231.jpg_

_file allegato (non incluso nell'export): page-232.jpg_

_file allegato (non incluso nell'export): page-233.jpg_

_file allegato (non incluso nell'export): page-234.jpg_

_file allegato (non incluso nell'export): page-235.jpg_

_file allegato (non incluso nell'export): page-236.jpg_

_file allegato (non incluso nell'export): page-237.jpg_

_file allegato (non incluso nell'export): page-238.jpg_

_file allegato (non incluso nell'export): page-239.jpg_

_file allegato (non incluso nell'export): page-240.jpg_

_file allegato (non incluso nell'export): page-241.jpg_

_file allegato (non incluso nell'export): page-242.jpg_

_file allegato (non incluso nell'export): page-243.jpg_

_file allegato (non incluso nell'export): page-244.jpg_

_file allegato (non incluso nell'export): page-245.jpg_

_file allegato (non incluso nell'export): page-246.jpg_

_file allegato (non incluso nell'export): page-247.jpg_

_file allegato (non incluso nell'export): page-248.jpg_

_file allegato (non incluso nell'export): page-249.jpg_

_file allegato (non incluso nell'export): page-250.jpg_

_file allegato (non incluso nell'export): page-251.jpg_

_file allegato (non incluso nell'export): page-252.jpg_

_file allegato (non incluso nell'export): page-253.jpg_

_file allegato (non incluso nell'export): page-254.jpg_

_file allegato (non incluso nell'export): page-255.jpg_

_file allegato (non incluso nell'export): page-256.jpg_
