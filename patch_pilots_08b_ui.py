from pathlib import Path
from datetime import datetime
import shutil

path = Path(
    "frontend/lib/features/management/presentation/management_page.dart"
)

if not path.exists():
    raise SystemExit(f"❌ Fichier introuvable : {path}")

text = path.read_text(encoding="utf-8")

# ============================================================
# BACKUP
# ============================================================

backup = path.with_name(
    f"{path.stem}.bak-pilot-status-ui-{datetime.now():%Y%m%d-%H%M%S}{path.suffix}"
)
shutil.copy2(path, backup)

# ============================================================
# 1. REMPLACER _PilotCard
# ============================================================

old_card_start = "class _PilotCard extends StatelessWidget {"
old_card_end = "// ==================================================================\n// AJOUT PILOTE"

start = text.find(old_card_start)
end = text.find(old_card_end, start)

if start == -1 or end == -1:
    raise SystemExit("❌ Bloc _PilotCard introuvable.")

new_card = r"""class _PilotCard extends StatelessWidget {
  const _PilotCard({required this.pilot, required this.onTap});

  final CompanyPilot pilot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = pilot.isActive;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFFFFE4E4)
                      : const Color(0xFFF1F1F1),
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: Text(
                  pilot.initials,
                  style: TextStyle(
                    color: isActive
                        ? const Color(0xFFE30613)
                        : const Color(0xFF777777),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pilot.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF222222),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      pilot.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    if (pilot.phone != null &&
                        pilot.phone!.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        pilot.phone!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],

                    const SizedBox(height: 7),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFF1F1F1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isActive ? 'Actif' : 'Inactif',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF777777),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.chevron_right,
                color: Color(0xFF777777),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

"""

text = text[:start] + new_card + text[end:]

# ============================================================
# 2. REMPLACER LA MÉTHODE _deactivate + AJOUTER _reactivate
# ============================================================

old_method_start = "  Future<void> _deactivate() async {"
old_method_end = "  @override\n  Widget build(BuildContext context) {"

start = text.find(old_method_start)
end = text.find(old_method_end, start)

if start == -1 or end == -1:
    raise SystemExit("❌ Méthode _deactivate introuvable.")

new_methods = r"""  Future<void> _deactivate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Désactiver le pilote ?'),
          content: Text(
            '${widget.pilot.displayName} sera désactivé comme pilote de l’entreprise. '
            'Il restera présent dans la liste et pourra être réactivé.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE30613),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Désactiver'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await PilotsService.deactivatePilot(widget.pilot.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilote désactivé.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      ManagementBackScope.maybeOf(context)?.onBack();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFFB91C1C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _reactivate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Réactiver le pilote ?'),
          content: Text(
            '${widget.pilot.displayName} redeviendra pilote actif de l’entreprise.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Réactiver'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await PilotsService.reactivatePilot(widget.pilot.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilote réactivé.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      ManagementBackScope.maybeOf(context)?.onBack();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFFB91C1C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

"""

text = text[:start] + new_methods + text[end:]

# ============================================================
# 3. REMPLACER LE BOUTON DE DÉTAIL
# ============================================================

old_button = r"""        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _loading ? null : _deactivate,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE30613),
              side: const BorderSide(color: Color(0xFFE30613)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.person_off_outlined),
            label: Text(
              _loading ? 'Désactivation...' : 'Désactiver le pilote',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
"""

new_button = r"""        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _loading
                ? null
                : (pilot.isActive ? _deactivate : _reactivate),
            style: OutlinedButton.styleFrom(
              foregroundColor: pilot.isActive
                  ? const Color(0xFFE30613)
                  : const Color(0xFF2E7D32),
              side: BorderSide(
                color: pilot.isActive
                    ? const Color(0xFFE30613)
                    : const Color(0xFF2E7D32),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    pilot.isActive
                        ? Icons.person_off_outlined
                        : Icons.person_add_alt_1_outlined,
                  ),
            label: Text(
              _loading
                  ? (pilot.isActive
                      ? 'Désactivation...'
                      : 'Réactivation...')
                  : (pilot.isActive
                      ? 'Désactiver le pilote'
                      : 'Réactiver le pilote'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
"""

if old_button not in text:
    raise SystemExit("❌ Bouton de détail pilote introuvable.")

text = text.replace(old_button, new_button, 1)

# ============================================================
# ÉCRITURE
# ============================================================

path.write_text(text, encoding="utf-8")

print(f"💾 Backup : {backup}")
print()
print("============================================================")
print("✅ ÉTAPE 8B TERMINÉE")
print("============================================================")
print("• Carte pilote : Actif / Inactif")
print("• Détail : Désactiver / Réactiver")
print("• Confirmation adaptée")
print("• Retour vers la liste après action")
print("• Aucun pilote retiré de la liste")
