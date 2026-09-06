from pathlib import Path
import shutil
import subprocess
import sys
from datetime import datetime

APP = Path("lib/core/navigation/app_shell.dart")
MGMT = Path("lib/features/management/presentation/management_page.dart")

print("🚀 PATCH NAVIGATION GESTION v2")
print("=" * 60)

for p in (APP, MGMT):
    if not p.exists():
        print(f"❌ Introuvable : {p}")
        sys.exit(1)

# Sécurité : on ne touche rien si les fichiers sont déjà modifiés.
for p in (APP, MGMT):
    r = subprocess.run(
        ["git", "diff", "--quiet", "--", str(p)]
    )
    if r.returncode != 0:
        print(f"❌ {p} contient déjà des modifications Git.")
        print("🛑 Abandon pour éviter tout écrasement.")
        sys.exit(1)

app_backup = APP.with_name(
    APP.name + ".bak-before-management-stack"
)
mgmt_backup = MGMT.with_name(
    MGMT.name + ".bak-before-management-stack"
)

shutil.copy2(APP, app_backup)
shutil.copy2(MGMT, mgmt_backup)

app = APP.read_text(encoding="utf-8")
mgmt = MGMT.read_text(encoding="utf-8")

original_app = app
original_mgmt = mgmt


def replace_once(text, old, new, name):
    count = text.count(old)

    if count != 1:
        raise RuntimeError(
            f"{name} : trouvé {count} fois, attendu 1"
        )

    return text.replace(old, new, 1)


# ================================================================
# APP SHELL
# ================================================================

print("\n🔧 app_shell.dart")

old = """  Widget? _managementSubPage;
  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
      _managementSubPage = null;
    });
  }

  void _openManagementPage(Widget page) {
    setState(() {
      _managementSubPage = page;
    });
  }

  void _backToManagement() {
    setState(() {
      _managementSubPage = null;
    });
  }
"""

new = """  final List<_ManagementEntry> _managementStack =
      <_ManagementEntry>[];

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
      _managementStack.clear();
    });
  }

  void _openManagementPage(
    Widget page, {
    VoidCallback? onReturn,
  }) {
    setState(() {
      _managementStack.add(
        _ManagementEntry(
          page: page,
          onReturn: onReturn,
        ),
      );
    });
  }

  void _backToManagement() {
    if (_managementStack.isEmpty) {
      return;
    }

    final entry = _managementStack.last;

    setState(() {
      _managementStack.removeLast();
    });

    entry.onReturn?.call();
  }
"""

app = replace_once(
    app,
    old,
    new,
    "pile Gestion",
)

old = """            _managementSubPage ??
                ManagementPage(
                  user: widget.user,
                  onOpenPage: _openManagementPage,
                ),
"""

new = """            _managementStack.isEmpty
                ? ManagementPage(
                    user: widget.user,
                    onOpenPage: _openManagementPage,
                  )
                : _managementStack.last.page,
"""

app = replace_once(
    app,
    old,
    new,
    "affichage pile Gestion",
)

marker = "class _AppShellState extends State<AppShell> {"

entry = """class _ManagementEntry {
  const _ManagementEntry({
    required this.page,
    this.onReturn,
  });

  final Widget page;
  final VoidCallback? onReturn;
}

"""

app = replace_once(
    app,
    marker,
    entry + marker,
    "_ManagementEntry",
)

print("   ✅ pile Gestion")


# ================================================================
# MANAGEMENT PAGE : TYPE CALLBACK
# ================================================================

print("\n🔧 management_page.dart")

marker = "class ManagementBackScope extends InheritedWidget {"

typedef = """typedef ManagementPageOpener = void Function(
  Widget page, {
  VoidCallback? onReturn,
});

"""

mgmt = replace_once(
    mgmt,
    marker,
    typedef + marker,
    "ManagementPageOpener",
)

mgmt = replace_once(
    mgmt,
    "  final ValueChanged<Widget> onOpenPage;",
    "  final ManagementPageOpener onOpenPage;",
    "type onOpenPage",
)


# ================================================================
# PILOTS PAGE
# ================================================================

print("🔧 Pilotes")

# Appel depuis ManagementPage.
old = """                    PilotsPage(
                      user: user,
                    ),"""

new = """                    PilotsPage(
                      user: user,
                      onOpenPage: onOpenPage,
                    ),"""

mgmt = replace_once(
    mgmt,
    old,
    new,
    "appel PilotsPage",
)

# Constructor PilotsPage.
old = """class PilotsPage extends StatefulWidget {
  const PilotsPage({
    super.key,
    required this.user,
  });

  final CurrentUser user;
"""

new = """class PilotsPage extends StatefulWidget {
  const PilotsPage({
    super.key,
    required this.user,
    required this.onOpenPage,
  });

  final CurrentUser user;
  final ManagementPageOpener onOpenPage;
"""

mgmt = replace_once(
    mgmt,
    old,
    new,
    "constructor PilotsPage",
)

# ----------------------------------------------------------------
# _openCreatePilot
# ----------------------------------------------------------------

start = mgmt.index("  Future<void> _openCreatePilot() async {")

end = mgmt.index(
    "\n  Future<void> _openPilot(",
    start,
)

old = mgmt[start:end]

new = """  void _openCreatePilot() {
    widget.onOpenPage(
      CreatePilotPage(
        user: widget.user,
      ),
      onReturn: _loadPilots,
    );
  }
"""

mgmt = mgmt[:start] + new + mgmt[end:]

# ----------------------------------------------------------------
# _openPilot
# ----------------------------------------------------------------

start = mgmt.index(
    "  Future<void> _openPilot(",
)

end = mgmt.index(
    "\n  @override",
    start,
)

old = mgmt[start:end]

new = """  void _openPilot(CompanyPilot pilot) {
    widget.onOpenPage(
      PilotDetailsPage(
        pilot: pilot,
      ),
      onReturn: _loadPilots,
    );
  }
"""

mgmt = mgmt[:start] + new + mgmt[end:]

print("   ✅ ouverture création pilote")
print("   ✅ ouverture détail pilote")

# ----------------------------------------------------------------
# CreatePilotPage : retour dans AppShell
# ----------------------------------------------------------------

count = mgmt.count("Navigator.of(context).pop(true);")

# On ne fait PAS de remplacement global.
# On cible uniquement la zone CreatePilotPage.
start = mgmt.index(
    "class _CreatePilotPageState"
)

end = mgmt.index(
    "// ==================================================================\n// DETAIL PILOTE",
    start,
)

block = mgmt[start:end]

if block.count("Navigator.of(context).pop(true);") != 1:
    raise RuntimeError(
        "retour CreatePilotPage : occurrence inattendue"
    )

block = block.replace(
    "Navigator.of(context).pop(true);",
    "ManagementBackScope.maybeOf(context)?.onBack();",
    1,
)

mgmt = mgmt[:start] + block + mgmt[end:]

# ----------------------------------------------------------------
# PilotDetailsPage : retour dans AppShell
# ----------------------------------------------------------------

start = mgmt.index(
    "class _PilotDetailsPageState"
)

end = mgmt.index(
    "// ==================================================================",
    start + 10,
)

block = mgmt[start:end]

if block.count("Navigator.of(context).pop(true);") != 1:
    raise RuntimeError(
        "retour PilotDetailsPage : occurrence inattendue"
    )

block = block.replace(
    "Navigator.of(context).pop(true);",
    "ManagementBackScope.maybeOf(context)?.onBack();",
    1,
)

mgmt = mgmt[:start] + block + mgmt[end:]

print("   ✅ retour création pilote")
print("   ✅ retour détail pilote")


# ================================================================
# DRONES PAGE
# ================================================================

print("\n🔧 Drones")

old = """                    const DronesPage(),
"""

new = """                    DronesPage(
                      onOpenPage: onOpenPage,
                    ),
"""

mgmt = replace_once(
    mgmt,
    old,
    new,
    "appel DronesPage",
)

old = """class DronesPage extends StatefulWidget {
  const DronesPage({
    super.key,
  });

  @override
"""

new = """class DronesPage extends StatefulWidget {
  const DronesPage({
    super.key,
    required this.onOpenPage,
  });

  final ManagementPageOpener onOpenPage;

  @override
"""

mgmt = replace_once(
    mgmt,
    old,
    new,
    "constructor DronesPage",
)

# ----------------------------------------------------------------
# _addDrone
# ----------------------------------------------------------------

start = mgmt.index(
    "  Future<void> _addDrone() async {"
)

end = mgmt.index(
    "\n  Future<void> _openDrone(",
    start,
)

new = """  void _addDrone() {
    widget.onOpenPage(
      const CreateDronePage(),
      onReturn: () {
        _loadDrones();
      },
    );
  }
"""

mgmt = mgmt[:start] + new + mgmt[end:]

# ----------------------------------------------------------------
# _openDrone
# ----------------------------------------------------------------

start = mgmt.index(
    "  Future<void> _openDrone(",
)

end = mgmt.index(
    "\n  @override",
    start,
)

new = """  void _openDrone(CompanyDrone drone) {
    widget.onOpenPage(
      EditDronePage(
        drone: drone,
      ),
      onReturn: () {
        _loadDrones();
      },
    );
  }
"""

mgmt = mgmt[:start] + new + mgmt[end:]

print("   ✅ ouverture ajout drone")
print("   ✅ ouverture édition drone")


# ================================================================
# RETOURS FORMULAIRES DRONES
# ================================================================

# CreateDronePage
start = mgmt.index(
    "class _CreateDronePageState"
)

end = mgmt.index(
    "// ==================================================================",
    start + 10,
)

block = mgmt[start:end]

if "Navigator.of(context).pop(" not in block:
    raise RuntimeError(
        "aucun retour trouvé dans CreateDronePage"
    )

# On cible uniquement le pop(result.warning).
if "Navigator.of(context).pop(\n        result.warning,\n      );" in block:
    block = block.replace(
        """Navigator.of(context).pop(
        result.warning,
      );""",
        "ManagementBackScope.maybeOf(context)?.onBack();",
        1,
    )
elif "Navigator.of(context).pop(result.warning);" in block:
    block = block.replace(
        "Navigator.of(context).pop(result.warning);",
        "ManagementBackScope.maybeOf(context)?.onBack();",
        1,
    )
else:
    raise RuntimeError(
        "pop(result.warning) introuvable"
    )

mgmt = mgmt[:start] + block + mgmt[end:]

# EditDronePage
start = mgmt.index(
    "class _EditDronePageState"
)

end = mgmt.index(
    "// ==================================================================",
    start + 10,
)

block = mgmt[start:end]

pop_count = block.count(
    "Navigator.of(context).pop(true);"
)

if pop_count != 4:
    raise RuntimeError(
        f"EditDronePage : {pop_count} retours trouvés, attendu 4"
    )

block = block.replace(
    "Navigator.of(context).pop(true);",
    "ManagementBackScope.maybeOf(context)?.onBack();",
)

mgmt = mgmt[:start] + block + mgmt[end:]

print("   ✅ retour création drone")
print("   ✅ retours édition drone")


# ================================================================
# CORRECTION RESULT CREATE DRONE
# ================================================================

# CreateDronePage ne renvoie plus result.warning via Navigator.
# On supprime donc la variable devenue inutile.
import re

mgmt, removed = re.subn(
    r"""final\s+result\s*=\s*\n\s*await\s+DronesService\.createDrone\(""",
    """await DronesService.createDrone(""",
    mgmt,
    count=1,
)

if removed != 1:
    raise RuntimeError(
        f"variable result CreateDrone : {removed} occurrence trouvée, attendu 1"
    )

print("   ✅ variable result CreateDrone supprimée")


# ================================================================
# ÉCRITURE UNIQUEMENT SI TOUT EST OK
# ================================================================

if app == original_app:
    raise RuntimeError("app_shell.dart inchangé")

if mgmt == original_mgmt:
    raise RuntimeError("management_page.dart inchangé")

APP.write_text(app, encoding="utf-8")
MGMT.write_text(mgmt, encoding="utf-8")

print("\n💾 modifications écrites")


# ================================================================
# FORMAT
# ================================================================

print("\n🧹 dart format")

r = subprocess.run(
    [
        "dart",
        "format",
        str(APP),
        str(MGMT),
    ]
)

if r.returncode != 0:
    print("❌ dart format a échoué")
    print("↩ restauration automatique")

    shutil.copy2(app_backup, APP)
    shutil.copy2(mgmt_backup, MGMT)

    sys.exit(1)


# ================================================================
# ANALYSE
# ================================================================

print("\n🔍 flutter analyze")

r = subprocess.run(
    ["flutter", "analyze"]
)

if r.returncode != 0:
    print("\n❌ flutter analyze a échoué")
    print("↩ restauration automatique")

    shutil.copy2(app_backup, APP)
    shutil.copy2(mgmt_backup, MGMT)

    subprocess.run(
        [
            "dart",
            "format",
            str(APP),
            str(MGMT),
        ],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )

    print("✅ fichiers restaurés")
    sys.exit(1)


# ================================================================
# FIN
# ================================================================

print("\n" + "=" * 60)
print("✅ NAVIGATION GESTION CORRIGÉE")
print("=" * 60)

print("""
Gestion
 ├── Pilotes
 │    ├── Ajouter
 │    └── Détail
 │
 └── Drones
      ├── Ajouter
      └── Modifier

Les pages restent dans AppShell.
La navigation principale reste affichée.
Le retour recharge automatiquement la liste.
""")

print("💾 Sauvegardes :")
print(f"   {app_backup}")
print(f"   {mgmt_backup}")
