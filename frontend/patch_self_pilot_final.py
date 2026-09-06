from pathlib import Path
import shutil
import subprocess
import sys
from datetime import datetime

ROOT = Path.cwd()
FILE = ROOT / "lib/features/management/presentation/management_page.dart"

text = FILE.read_text(encoding="utf-8")

START = text.find("class CreatePilotPage extends StatefulWidget")
END = text.find("// ==================================================================\n// DETAIL PILOTE", START)

if START == -1 or END == -1:
    raise RuntimeError("❌ Bloc CreatePilotPage introuvable.")

block = text[START:END]

backup = FILE.with_name(
    f"{FILE.name}.bak-self-pilot-{datetime.now():%Y%m%d-%H%M%S}"
)

shutil.copy2(FILE, backup)

try:
    print("🔧 CreatePilotPage")

    # ------------------------------------------------------------
    # État
    # ------------------------------------------------------------

    if "_alreadyPilot" not in block:
        marker = "  bool _isSelfPilot = false;"

        if marker not in block:
            raise RuntimeError(
                "❌ _isSelfPilot introuvable."
            )

        block = block.replace(
            marker,
            """  bool _isSelfPilot = false;
  bool _alreadyPilot = false;
  bool _checkingPilot = true;""",
            1,
        )

        print("   ✅ état ajouté")
    else:
        print("   ℹ️ état déjà présent")

    # ------------------------------------------------------------
    # initState + vérification
    # ------------------------------------------------------------

    if "_checkIfAlreadyPilot()" not in block:

        marker = "  @override\n  void dispose()"

        pos = block.find(marker)

        if pos == -1:
            raise RuntimeError(
                "❌ dispose() de CreatePilotPage introuvable."
            )

        code = """  @override
  void initState() {
    super.initState();
    _checkIfAlreadyPilot();
  }

  Future<void> _checkIfAlreadyPilot() async {
    try {
      final pilots = await PilotsService.getPilots();

      final currentEmail =
          widget.user.email.trim().toLowerCase();

      final alreadyPilot = pilots.any(
        (pilot) =>
            pilot.email.trim().toLowerCase() ==
            currentEmail,
      );

      if (!mounted) return;

      setState(() {
        _alreadyPilot = alreadyPilot;
        _checkingPilot = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _checkingPilot = false;
      });
    }
  }

"""

        block = block[:pos] + code + block[pos:]

        print("   ✅ vérification profil pilote ajoutée")
    else:
        print("   ℹ️ vérification déjà présente")

    # ------------------------------------------------------------
    # Case « Je suis pilote »
    # ------------------------------------------------------------

    old = "if (!widget.user.isPilot) ...["

    new = """if (!_checkingPilot &&
                  !widget.user.isPilot &&
                  !_alreadyPilot) ...["""

    if new not in block:

        count = block.count(old)

        if count != 1:
            raise RuntimeError(
                f"❌ condition trouvée {count} fois."
            )

        block = block.replace(old, new, 1)

        print("   ✅ affichage de « Je suis pilote » corrigé")
    else:
        print("   ℹ️ condition déjà corrigée")

    # ------------------------------------------------------------
    # Remplacement strict du bloc
    # ------------------------------------------------------------

    text = text[:START] + block + text[END:]

    FILE.write_text(text, encoding="utf-8")

    # ------------------------------------------------------------
    # Format
    # ------------------------------------------------------------

    print("\n🧹 dart format")

    result = subprocess.run(
        ["dart", "format", str(FILE)],
        cwd=ROOT,
    )

    if result.returncode != 0:
        raise RuntimeError("❌ dart format a échoué.")

    # ------------------------------------------------------------
    # Analyse
    # ------------------------------------------------------------

    print("\n🔍 flutter analyze")

    result = subprocess.run(
        ["flutter", "analyze"],
        cwd=ROOT,
    )

    if result.returncode != 0:
        raise RuntimeError("❌ flutter analyze a échoué.")

except Exception as error:

    print(f"\n❌ {error}")
    print("↩️ Restauration automatique...")

    shutil.copy2(backup, FILE)

    print("✅ fichier restauré")
    print(f"💾 backup : {backup}")

    sys.exit(1)

print("\n" + "=" * 60)
print("✅ CORRECTION TERMINÉE")
print("=" * 60)
print("La case « Je suis pilote » est maintenant masquée")
print("si l'e-mail du compte existe déjà dans les pilotes.")
print(f"💾 Backup : {backup}")
