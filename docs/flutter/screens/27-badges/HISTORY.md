# Screen 27, badges: history

## 1. Start (2026-11-27)
- Owner skipped 24 (end of lesson) and sent two references: 27 badges and 28 help overlay. 28 postponed as a future
  improvement (`BACKLOG.md`); 27 started on `flutter/27-badges` (from the screen-24 branch, which carries the refreshed
  app screenshots and the references).
- Owner's answers: Claude chooses the badges; one full medal per badge from ChatGPT; small celebration when earned; grid
  scrolls. Plan and badge list: `../27-badges.md`. Prompts M01–M12 + L1: `../../prompts/27-badges/images-v2.txt`
  (v1 B1/B2 superseded). Crops to attach: `attach/`.
- Waiting for the medals and the owner's yes on the visual plan.
- Owner asked to put everything on the branch so that ChatGPT can read the branch and generate the medals by itself:
  `prompts/27-badges/README-CHATGPT.md` (repository, branch, files to download, 13 prompts, file names, output folder
  `docs/design-assets/badges/`); pointer in `27-badges/README.md`.

## 2. Medals arrived and the screen built (2026-11-27)
- Owner's ChatGPT medals are on the branch: `docs/design-assets/badges/` (M01–M12 + L1) and `dark-green/` (second engraving).
- Built on the screen-11 pieces (ribbon with the title as parameter, lattice, gold rim, coins). Opened from the rail item
  «الإنجازات» (section 4). Everything in u, measured on the reference; text sizes matched to the reference widths
  (Readex is wider than the reference font: tiles 2.9u, tabs 3.0u, description 3.0u, name 5.2u).
- Motion as the plan: entry stagger, selection rim glides, detail cross-fade with the bar filling, filters reorder the tiles,
  celebration on `?earn=5` (padlock medal lifts and fades, gold pops, ring + sparks, check pops, then the tile glides to
  the earned group; `Sounds.passed`, `Haptics.success`). One-shot only.
- Checked: `flutter analyze`, `flutter test` (23 pass, 3 new), web build, captures at 1844×853 and 915×412. **No critic yet**
  (asks the owner first). Open points for the owner are in `DECISIONS.md` (3 🟡 rows) and `BACKLOG.md`.

## 3. Owner's review round (2026-11-27)
- Medals mixed brown/green; borders from the confirmed tokens; locked medal L1 redone by the owner (new padlock assets).
- **Progress fill**: brown medal (no green) filled bottom-up by the green one, padlock on top; unlock at 100% with the open
  padlock (`_Unlock`, `_BadgeMedal` in `badges_screen.dart`); owner's corrections are logged in `DECISIONS.md`.
- Screen 13 (achievements) vs 27: question open (`BACKLOG.md`).

