from pathlib import Path
import shutil
import subprocess
import sys
from datetime import datetime

P = Path("lib/features/management/presentation/management_page.dart")

print("🚀 PATCH UI AJOUTER SITE")
print("=" * 60)

text = P.read_text(encoding="utf-8")

backup = P.with_name(
    P.name + f".bak-create-site-ui-{datetime.now():%Y%m%d-%H%M%S}"
)
shutil.copy2(P, backup)

# ================================================================
# LOCALISER _CreateSitePageState
# ================================================================

start = text.find("class _CreateSitePageState")

if start == -1:
    print("❌ _CreateSitePageState introuvable")
    sys.exit(1)

build_start = text.find(
    "  @override\n  Widget build(BuildContext context) {",
    start,
)

if build_start == -1:
    print("❌ build() de _CreateSitePageState introuvable")
    sys.exit(1)

return_start = text.find(
    "    return Scaffold(",
    build_start,
)

if return_start == -1:
    print("❌ return Scaffold() introuvable")
    sys.exit(1)

# ================================================================
# TROUVER LA FIN DU SCAFFOLD
# ================================================================

# On parcourt les parenthèses à partir de Scaffold(
# pour trouver exactement sa fermeture.
paren_start = text.find("Scaffold(", return_start)

depth = 0
in_string = False
string_char = None
escape = False

end = None

i = paren_start

while i < len(text):
    c = text[i]

    if in_string:
        if escape:
            escape = False
        elif c == "\\":
            escape = True
        elif c == string_char:
            in_string = False
        i += 1
        continue

    if c in ("'", '"'):
        in_string = True
        string_char = c
        i += 1
        continue

    if c == "(":
        depth += 1

    elif c == ")":
        depth -= 1

        if depth == 0:
            end = i + 1
            break

    i += 1

if end is None:
    print("❌ Impossible de trouver la fin du Scaffold")
    sys.exit(1)

old_scaffold = text[return_start:end]

# ================================================================
# EXTRAIRE LE BODY DU SCAFFOLD
# ================================================================

body_marker = "\n      body:"

body_pos = old_scaffold.find(body_marker)

if body_pos == -1:
    print("❌ body: introuvable dans Scaffold")
    sys.exit(1)

# Tout ce qui suit "body:" constitue l'expression du body.
body_expression = old_scaffold[
    body_pos + len(body_marker):
].strip()

# Le texte récupéré contient encore la fermeture du Scaffold :
#     );
# On la retire avant de placer le body dans children: [].
if body_expression.endswith(");"):
    body_expression = body_expression[:-2].rstrip()

# Le body du Scaffold possède généralement une virgule finale.
if body_expression.endswith(","):
    body_expression = body_expression[:-1].rstrip()

# ================================================================
# NOUVELLE STRUCTURE
# ================================================================

new_widget = """    return _ManagementSubPage(
      title: 'Ajouter un site',
      icon: Icons.location_on_outlined,
      children: [
        %s,
      ],
    )""" % body_expression

text = (
    text[:return_start]
    + new_widget
    + text[end:]
)

# ================================================================
# ÉCRITURE
# ================================================================

P.write_text(text, encoding="utf-8")

print("✅ Scaffold spécifique supprimé")
print("✅ _ManagementSubPage utilisé")
print("   → bouton retour")
print("   → bandeau")
print("   → icône")
print("   → structure Gestion")

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
print("✅ UI AJOUTER SITE CORRIGÉE")
print("=" * 60)

print("""
Ajouter un site

  ✅ bouton ← Retour à Sites
  ✅ AppBar Gestion
  ✅ bandeau avec icône
  ✅ formulaire conservé
  ✅ menu inférieur conservé
""")

print(f"💾 sauvegarde : {backup}")
