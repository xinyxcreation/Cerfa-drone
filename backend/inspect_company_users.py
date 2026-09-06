#!/usr/bin/env python3

from pathlib import Path
import re

ROOT = Path(".")
patterns = [
    "CREATE TABLE company_users",
    "company_users",
    "is_pilot",
    "is_active",
    "left_at",
]

print("=" * 70)
print("🔎 INSPECTION STRUCTURE company_users")
print("=" * 70)

files = []

for base in [
    ROOT / "src" / "database",
    ROOT / "src" / "migrations",
    ROOT / "migrations",
]:
    if base.exists():
        files.extend(base.rglob("*"))

files = [
    p for p in files
    if p.is_file()
    and p.suffix.lower() in {".sql", ".ts", ".js"}
]

found = False

for path in sorted(set(files)):
    try:
        text = path.read_text(encoding="utf-8")
    except Exception:
        continue

    if not any(pattern.lower() in text.lower() for pattern in patterns):
        continue

    found = True

    print()
    print("-" * 70)
    print(f"📄 {path}")
    print("-" * 70)

    lines = text.splitlines()

    for i, line in enumerate(lines):
        if any(pattern.lower() in line.lower() for pattern in patterns):
            start = max(0, i - 5)
            end = min(len(lines), i + 12)

            print(f"\n--- lignes {start + 1}-{end} ---")

            for n in range(start, end):
                print(f"{n + 1:4}: {lines[n]}")

if not found:
    print()
    print("❌ Aucune migration/structure trouvée.")
    print()
    print("Recherche élargie dans tout le backend...")

    for path in sorted(ROOT.rglob("*")):
        if not path.is_file():
            continue

        if any(part in {"node_modules", ".git", "dist", "build"} for part in path.parts):
            continue

        if path.suffix.lower() not in {".sql", ".ts", ".js"}:
            continue

        try:
            text = path.read_text(encoding="utf-8")
        except Exception:
            continue

        if "company_users" in text.lower():
            print(f"📄 {path}")

print()
print("=" * 70)
print("✅ INSPECTION TERMINÉE — AUCUNE MODIFICATION")
print("=" * 70)
