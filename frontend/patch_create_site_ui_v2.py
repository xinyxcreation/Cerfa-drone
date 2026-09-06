from pathlib import Path
import shutil
import subprocess
import sys
from datetime import datetime

P = Path("lib/features/management/presentation/management_page.dart")

print("🚀 PATCH UI AJOUTER SITE v2")
print("=" * 60)

text = P.read_text(encoding="utf-8")

backup = P.with_name(
    P.name + f".bak-create-site-ui-{datetime.now():%Y%m%d-%H%M%S}"
)
shutil.copy2(P, backup)

# ================================================================
# LOCALISATION DE _CreateSitePageState
# ================================================================

class_start = text.find("class _CreateSitePageState")

if class_start == -1:
    raise RuntimeError("_CreateSitePageState introuvable")

build_start = text.find(
    "Widget build(BuildContext context)",
    class_start,
)

if build_start == -1:
    raise RuntimeError("build de _CreateSitePageState introuvable")

scaffold_start = text.find(
    "return Scaffold(",
    build_start,
)

if scaffold_start == -1:
    raise RuntimeError("return Scaffold introuvable")

# ================================================================
# PARSEUR DE PARENTHESES / CROCHETS / ACCOLADES
# ================================================================

def skip_string(s, i):
    quote = s[i]

    # Dart raw string r'...' / r"..."
    if i > 0 and s[i - 1] == "r":
        pass

    i += 1
    escaped = False

    while i < len(s):
        c = s[i]

        if escaped:
            escaped = False
        elif c == "\\":
            escaped = True
        elif c == quote:
            return i + 1

        i += 1

    raise RuntimeError("chaîne Dart non terminée")


def find_scaffold_end(s, start):
    depth = 0
    i = start

    while i < len(s):
        c = s[i]

        if c in ("'", '"'):
            i = skip_string(s, i)
            continue

        if c == "(":
            depth += 1
        elif c == ")":
            depth -= 1

            if depth == 0:
                return i + 1

        i += 1

    raise RuntimeError("fin du Scaffold introuvable")


scaffold_end = find_scaffold_end(text, scaffold_start)

scaffold = text[scaffold_start:scaffold_end]

# ================================================================
# TROUVER body: AU PREMIER NIVEAU DU SCAFFOLD
# ================================================================

body_pos = scaffold.find("body:")

if body_pos == -1:
    raise RuntimeError("body: introuvable")

# Vérifie que body: est bien au niveau direct du Scaffold.
# On démarre juste après "Scaffold(".
depth_paren = 1
depth_bracket = 0
depth_brace = 0

i = len("return Scaffold(")

body_real_pos = None

while i < len(scaffold):
    c = scaffold[i]

    if c in ("'", '"'):
        i = skip_string(scaffold, i)
        continue

    if c == "(":
        depth_paren += 1
    elif c == ")":
        depth_paren -= 1
    elif c == "[":
        depth_bracket += 1
    elif c == "]":
        depth_bracket -= 1
    elif c == "{":
        depth_brace += 1
    elif c == "}":
        depth_brace -= 1

    if (
        scaffold.startswith("body:", i)
        and depth_paren == 1
        and depth_bracket == 0
        and depth_brace == 0
    ):
        body_real_pos = i
        break

    i += 1

if body_real_pos is None:
    raise RuntimeError("body: direct du Scaffold introuvable")

body_start = body_real_pos + len("body:")

# ================================================================
# TROUVER LA FIN DE body:
# ================================================================

depth_paren = 0
depth_bracket = 0
depth_brace = 0

i = body_start

body_end = None

while i < len(scaffold):
    c = scaffold[i]

    if c in ("'", '"'):
        i = skip_string(scaffold, i)
        continue

    if c == "(":
        depth_paren += 1
    elif c == ")":
        if depth_paren == 0:
            # fermeture du Scaffold
            body_end = i
            break
        depth_paren -= 1
    elif c == "[":
        depth_bracket += 1
    elif c == "]":
        depth_bracket -= 1
    elif c == "{":
        depth_brace += 1
    elif c == "}":
        depth_brace -= 1
    elif c == ",":
        if (
            depth_paren == 0
            and depth_bracket == 0
            and depth_brace == 0
        ):
            body_end = i
            break

    i += 1

if body_end is None:
    raise RuntimeError("fin du body introuvable")

body_expression = scaffold[body_start:body_end].strip()

if not body_expression:
    raise RuntimeError("body vide")

print("\n🔎 body du formulaire récupéré")
print(f"   longueur : {len(body_expression)} caractères")

# ================================================================
# REMPLACEMENT
# ================================================================

new_container = f"""return _ManagementSubPage(
      title: widget.site == null
          ? 'Nouveau site'
          : 'Modifier le site',
      icon: Icons.location_on_outlined,
      children: [
        {body_expression},
      ],
    )"""

text = (
    text[:scaffold_start]
    + new_container
    + text[scaffold_end:]
)

P.write_text(text, encoding="utf-8")

print("✅ Scaffold du formulaire remplacé")
print("✅ _ManagementSubPage utilisé")
print("   → bouton retour")
print("   → AppBar Gestion")
print("   → bandeau avec icône")
print("   → formulaire conservé")


# ================================================================
# FORMAT
# ================================================================

print("\n🧹 dart format")

r = subprocess.run([
    "dart",
    "format",
    "lib/features/management/presentation/management_page.dart",
])

if r.returncode != 0:
    print("❌ dart format échoué")
    print("↩ restauration automatique")

    shutil.copy2(backup, P)
    sys.exit(1)


# ================================================================
# ANALYSE
# ================================================================

print("\n🔍 flutter analyze")

r = subprocess.run([
    "flutter",
    "analyze",
])

if r.returncode != 0:
    print("\n❌ flutter analyze échoué")
    print("↩ restauration automatique")

    shutil.copy2(backup, P)

    subprocess.run(
        [
            "dart",
            "format",
            "lib/features/management/presentation/management_page.dart",
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    print("✅ restauration terminée")
    sys.exit(1)


print("\n" + "=" * 60)
print("✅ AJOUTER / MODIFIER SITE : UI CORRIGÉE")
print("=" * 60)

print("""
Écran site
 ├── ← bouton retour
 ├── AppBar noire
 ├── bandeau Gestion
 ├── formulaire existant
 └── menu inférieur AppShell

✅ aucune modification des champs
✅ aucune modification du service
✅ aucune modification de la sauvegarde
""")

print(f"💾 sauvegarde : {backup}")
