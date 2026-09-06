from pathlib import Path
import shutil
import subprocess
import sys
import re
from datetime import datetime

P = Path("lib/features/management/presentation/management_page.dart")

print("🚀 PATCH NAVIGATION SITES v3")
print("=" * 60)

text = P.read_text(encoding="utf-8")
original = text

backup = P.with_name(
    P.name + f".bak-sites-navigation-{datetime.now():%Y%m%d-%H%M%S}"
)
shutil.copy2(P, backup)

# ================================================================
# OUTIL REGEX SÉCURISÉ
# ================================================================

def sub_once(pattern, replacement, label, flags=re.MULTILINE):
    global text

    text2, count = re.subn(
        pattern,
        replacement,
        text,
        count=1,
        flags=flags,
    )

    if count != 1:
        raise RuntimeError(
            f"{label} : trouvé {count} fois, attendu 1"
        )

    text = text2


# ================================================================
# MANAGEMENT PAGE → SITES
# ================================================================

print("\n🔧 ManagementPage → SitesPage")

# On accepte toutes les indentations / mises en forme.
sub_once(
    r"onOpenPage\(\s*const\s+SitesPage\(\)\s*,?\s*\)",
    """onOpenPage(
                  SitesPage(
                    onOpenPage: onOpenPage,
                  ),
                )""",
    "appel SitesPage",
)

print("   ✅ SitesPage utilise la pile Gestion")


# ================================================================
# CONSTRUCTOR SITES PAGE
# ================================================================

print("\n🔧 SitesPage")

sub_once(
    r"""class SitesPage extends StatefulWidget \{
\s*const SitesPage\(\{super\.key\}\);
""",
    """class SitesPage extends StatefulWidget {
  const SitesPage({
    super.key,
    required this.onOpenPage,
  });

  final ManagementPageOpener onOpenPage;
""",
    "constructor SitesPage",
)

print("   ✅ onOpenPage ajouté à SitesPage")


# ================================================================
# _addSite
# ================================================================

print("\n🔧 _addSite")

start = text.find("  Future<void> _addSite() async {")

if start == -1:
    raise RuntimeError("_addSite introuvable")

# Trouve le prochain @override après _addSite.
end = text.find("\n  @override", start)

if end == -1:
    raise RuntimeError("fin de _addSite introuvable")

new_method = """  void _addSite() {
    widget.onOpenPage(
      const _CreateSitePage(),
      onReturn: () {
        setState(_load);
      },
    );
  }
"""

text = text[:start] + new_method + text[end:]

print("   ✅ _addSite utilise la pile Gestion")


# ================================================================
# CREATE SITE → RETOUR PILE GESTION
# ================================================================

print("\n🔧 _CreateSitePage")

start = text.find("class _CreateSitePageState")

if start == -1:
    raise RuntimeError("_CreateSitePageState introuvable")

# On prend jusqu'à la prochaine classe.
end = text.find("\nclass ", start + len("class _CreateSitePageState"))

if end == -1:
    end = len(text)

block = text[start:end]

count = block.count("Navigator.of(context).pop(true);")

if count != 1:
    raise RuntimeError(
        f"_CreateSitePageState : {count} pop(true), attendu 1"
    )

block = block.replace(
    "Navigator.of(context).pop(true);",
    "ManagementBackScope.maybeOf(context)?.onBack();",
    1,
)

text = text[:start] + block + text[end:]

print("   ✅ retour via ManagementBackScope")


# ================================================================
# ÉCRITURE
# ================================================================

if text == original:
    raise RuntimeError("Aucune modification effectuée")

P.write_text(text, encoding="utf-8")

print("\n💾 fichier modifié")
print(f"💾 sauvegarde : {backup}")


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
    print("↩ restauration")

    shutil.copy2(backup, P)
    sys.exit(1)


# ================================================================
# ANALYSE
# ================================================================

print("\n🔍 flutter analyze")

r = subprocess.run(["flutter", "analyze"])

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


# ================================================================
# FIN
# ================================================================

print("\n" + "=" * 60)
print("✅ NAVIGATION AJOUTER SITE CORRIGÉE")
print("=" * 60)

print("""
Gestion
 └── Sites
      └── Ajouter

      ✅ même AppShell
      ✅ même AppBar
      ✅ logo / bandeau
      ✅ menu inférieur
      ✅ retour vers Sites
      ✅ rechargement de la liste
""")

print(f"💾 sauvegarde : {backup}")
