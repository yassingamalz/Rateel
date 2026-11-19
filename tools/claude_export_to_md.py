#!/usr/bin/env python3
"""Converte l'export di claude.ai (conversations.json) in un file Markdown per chat.

Uso:
    python3 tools/claude_export_to_md.py conversations.json docs/knowledge-base/chats/full \
        --ids docs/knowledge-base/chats/ids.txt

Senza --ids converte tutte le conversazioni dell'export.
"""
import argparse
import json
import re
from pathlib import Path


def message_text(msg: dict) -> str:
    parts = []
    for block in msg.get("content") or []:
        kind = block.get("type")
        if kind == "text" and block.get("text"):
            parts.append(block["text"])
        elif kind == "tool_use":
            payload = json.dumps(block.get("input", {}), ensure_ascii=False, indent=2)
            parts.append(f"<details><summary>tool: {block.get('name', '')}</summary>\n\n```json\n{payload}\n```\n</details>")
        elif kind == "tool_result":
            inner = block.get("content")
            if isinstance(inner, list):
                inner = "\n".join(c.get("text", "") for c in inner if isinstance(c, dict))
            parts.append(f"<details><summary>tool result</summary>\n\n```\n{inner or ''}\n```\n</details>")
    if not parts and msg.get("text"):
        parts.append(msg["text"])
    for att in msg.get("attachments") or []:
        name = att.get("file_name", "allegato")
        body = att.get("extracted_content")
        parts.append(f"<details><summary>allegato: {name}</summary>\n\n```\n{body or ''}\n```\n</details>")
    for f in msg.get("files") or []:
        parts.append(f"_file allegato: {f.get('file_name', '')}_")
    return "\n\n".join(parts).strip()


def slug(text: str) -> str:
    text = re.sub(r"[^\w\s-]", "", text or "", flags=re.UNICODE).strip().lower()
    return re.sub(r"[\s_]+", "-", text)[:60] or "chat"


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("export", type=Path)
    ap.add_argument("outdir", type=Path)
    ap.add_argument("--ids", type=Path, help="file con un UUID di chat per riga")
    args = ap.parse_args()

    conversations = json.loads(args.export.read_text(encoding="utf-8"))
    wanted = None
    if args.ids:
        wanted = {l.strip() for l in args.ids.read_text().splitlines() if l.strip()}

    args.outdir.mkdir(parents=True, exist_ok=True)
    written = 0
    for conv in conversations:
        uuid = conv.get("uuid", "")
        if wanted is not None and uuid not in wanted:
            continue
        title = conv.get("name") or "(senza titolo)"
        date = (conv.get("updated_at") or conv.get("created_at") or "")[:10]
        lines = [
            f"# {title}",
            "",
            f"- Link: https://claude.ai/chat/{uuid}",
            f"- Creata: {conv.get('created_at', '')}",
            f"- Aggiornata: {conv.get('updated_at', '')}",
            "",
        ]
        for msg in conv.get("chat_messages") or []:
            who = "Yassin" if msg.get("sender") == "human" else "Claude"
            lines += [f"## {who} ({msg.get('created_at', '')[:16]})", "", message_text(msg), ""]
        out = args.outdir / f"{date}-{uuid[:8]}-{slug(title)}.md"
        out.write_text("\n".join(lines), encoding="utf-8")
        written += 1

    missing = (wanted or set()) - {c.get("uuid") for c in conversations}
    print(f"Scritte {written} chat in {args.outdir}")
    if missing:
        print(f"{len(missing)} UUID non trovati nell'export:", *sorted(missing), sep="\n  ")


if __name__ == "__main__":
    main()
