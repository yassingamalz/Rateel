# Screen 23: settings (الإعدادات)

Status: added by the owner (2026-11-25); content and entry point **to confirm**. Reference to generate with
`prompts/23-settings/reference-v1.txt` (app screenshots 14, 11, 08-rules), saved as `screens/23-settings/23-impostazioni.webp`.

## Proposed content
| Row | Control | Why |
|---|---|---|
| المظهر (theme) | dark / light segmented pill | dark first, light/dark toggle always present (CLAUDE.md); today the toggle lives only inside lessons |
| حجم الخط (text size) | − / value / + | promised in `main.dart` (the app ignores the phone's text zoom) |
| المؤثرات الصوتية (sounds) | switch | `core/sounds.dart` |
| الاهتزاز (vibration) | switch | `core/haptics.dart` |
| القارئ (reciter) | picker | listening lessons (22), rule audio examples (08) |
| تذكير يومي (daily reminder) | time + switch | daily challenges (12) |
| عن التطبيق / إعادة ضبط التقدم | buttons | about; reset progress with a confirmation |

## Open questions for the owner
- Entry point: a gear at the bottom of the side rail, an item in the open menu, or both?
- One page, or a profile + settings page together?
- Which rows to keep (reciter and reminder need features not built yet).
