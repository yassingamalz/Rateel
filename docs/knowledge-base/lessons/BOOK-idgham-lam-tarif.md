<!-- Fonte: https://claude.ai/chat/56987cb3-59a5-42aa-8bf7-f59da44422ba turno 1 (giugno 2026), file U6-U7_Idgham_LamTareef_briefs.md generato in chat. Testo originale.
Attenzione: le sigle U6/U7 qui sotto sono provvisorie e collidono con il curriculum a 13 unità (vedi 05-open-points.md, OP-04). Nel curriculum a 13 unità questi contenuti corrispondono a U5.L12 "الحرفان الملتقيان" (da espandere) e a un'unità nuova per lām al-taʿrīf. -->

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
