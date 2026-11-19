#!/usr/bin/env python3
"""Converte le chat di Claude Design dell'export (design_chats/*.json) in Markdown
e ricostruisce i file scritti durante la chat riapplicando le operazioni in ordine.

Uso:
    python3 tools/design_export_to_md.py <cartella design_chats> <out_chats> <out_files> \
        --project "Animation for non-Mushdada taskeel"

I file ricostruiti sono quelli scritti dalla chat. Mancano i componenti starter
copiati dal sistema (animations.jsx, image-slot.js) e le immagini caricate.
"""
import argparse
import json
from pathlib import Path


def fence(text, lang=""):
    ticks = "```"
    while ticks in (text or ""):
        ticks += "`"
    return f"{ticks}{lang}\n{text or ''}\n{ticks}"


def ok(tc):
    out = str(tc.get("output") or "")
    return not out.lstrip().startswith("Error") and "--- Error ---" not in out


def apply_edit(text, old, new):
    return text.replace(old, new, 1) if old in text else text


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("indir", type=Path)
    ap.add_argument("out_chats", type=Path)
    ap.add_argument("out_files", type=Path)
    ap.add_argument("--project", required=True)
    a = ap.parse_args()

    chats = []
    for f in a.indir.glob("*.json"):
        d = json.loads(f.read_text(encoding="utf-8"))
        if (d.get("project") or {}).get("name") == a.project:
            chats.append(d)
    chats.sort(key=lambda d: d["created_at"])

    files, dc = {}, {}
    a.out_chats.mkdir(parents=True, exist_ok=True)
    a.out_files.mkdir(parents=True, exist_ok=True)

    for d in chats:
        lines = [f"# Claude Design: {d['project']['name']} ({d['created_at'][:10]})", "",
                 f"- Progetto Claude Design: `{d['project']['uuid']}`", f"- Chat: `{d['uuid']}`",
                 f"- Creata: {d['created_at']}", f"- Aggiornata: {d['updated_at']}", ""]
        for m in d["messages"]:
            c = m.get("content") or {}
            who = "Yassin" if m.get("role") == "user" else "Claude"
            lines += [f"## {who} ({str(c.get('timestamp', ''))[:16]})", ""]
            if c.get("content"):
                lines += [c["content"], ""]
            for att in c.get("attachments") or []:
                if att.get("type") in ("file", "image"):
                    lines.append(f"_allegato: {att.get('name')}_")
                elif att.get("type") == "text":
                    lines += [f"<details><summary>testo incollato: {att.get('name')}</summary>", "",
                              fence(att.get("content", "")), "</details>", ""]
            for b in c.get("contentBlocks") or []:
                if b.get("type") != "tool_call":
                    continue
                tc = b["toolCall"]
                name, inp = tc.get("name"), tc.get("input") or {}
                good = ok(tc)
                target = inp.get("path") or inp.get("a_filename") or ""
                if name == "questions_v2":
                    lines += ["<details><summary>domande di Claude</summary>", "",
                              fence(json.dumps(inp, ensure_ascii=False, indent=2), "json"), "</details>", ""]
                elif name in ("write_file", "dc_write", "str_replace_edit", "dc_html_str_replace",
                              "dc_js_str_replace", "dc_set_props", "copy_files", "copy_starter_component"):
                    lines.append(f"- `{name}` {target} {'' if good else '(errore)'}".rstrip())
                if not good:
                    continue
                if name == "write_file" and inp.get("path"):
                    files[inp["path"]] = inp.get("content", "")
                elif name == "str_replace_edit" and inp.get("path") in files:
                    edits = inp.get("edits") or [{"old_string": inp.get("old_string", ""), "new_string": inp.get("new_string", "")}]
                    for e in edits:
                        files[inp["path"]] = apply_edit(files[inp["path"]], e["old_string"], e["new_string"])
                elif name == "dc_write":
                    dc[inp["a_filename"]] = {"html": inp.get("b_dc_html", ""), "js": inp.get("c_dc_js", ""),
                                             "props": inp.get("d_props_json", "")}
                elif name == "dc_set_props" and inp.get("a_filename") in dc:
                    dc[inp["a_filename"]]["props"] = inp.get("b_props_json", "")
                elif name == "dc_html_str_replace" and inp.get("a_filename") in dc:
                    p = dc[inp["a_filename"]]
                    p["html"] = apply_edit(p["html"], inp.get("c_find", ""), inp.get("d_replace", ""))
                elif name == "dc_js_str_replace" and inp.get("a_filename") in dc:
                    p = dc[inp["a_filename"]]
                    if inp.get("c_find"):
                        p["js"] = apply_edit(p["js"], inp["c_find"], inp.get("d_replace", ""))
                    else:
                        p["js"] = inp.get("d_replace", "")
            lines.append("")
        (a.out_chats / f"{d['created_at'][:10]}-{d['uuid'][:8]}.md").write_text("\n".join(lines), encoding="utf-8")

    for path, content in files.items():
        (a.out_files / Path(path).name).write_text(content, encoding="utf-8")
    for name, p in dc.items():
        body = [f"<!-- Ricostruito dall'export di Claude Design. Template, logica e props del Design Component '{name}'. -->",
                "<!-- TEMPLATE -->", p["html"], "<!-- LOGIC (JS) -->", "<script>", p["js"], "</script>",
                "<!-- PROPS (JSON) -->", "<script type=\"application/json\">", p["props"], "</script>"]
        (a.out_files / name).write_text("\n".join(body), encoding="utf-8")
    print(f"{len(chats)} chat, {len(files)} file, {len(dc)} design component")


if __name__ == "__main__":
    main()
