import 'package:flutter/material.dart';

import '../../features/auth/models/current_user.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/management/presentation/management_page.dart';
import '../../features/missions/presentation/missions_page.dart';
import '../../features/profile/presentation/profile_page.dart';

const Color red = Color(0xFFE30613);

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.user,
    required this.onLogout,
  });

  final CurrentUser user;
  final VoidCallback onLogout;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  Widget? _managementSubPage;
  String _managementTitle = 'Gestion';
  List<Widget>? _managementActions;

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;

      if (index == 4) {
        _managementSubPage = null;
        _managementTitle = 'Gestion';
        _managementActions = null;
      } else {
        _managementSubPage = null;
        _managementTitle = 'Gestion';
        _managementActions = null;
      }
    });
  }

  void _openManagementPage(Widget page) {
    setState(() {
      _managementSubPage = page;
      _managementTitle = 'Gestion';
      _managementActions = null;
    });
  }

  void _configureManagementAppBar(
    String title,
    List<Widget>? actions,
  ) {
    if (!mounted ||
        _currentIndex != 4 ||
        _managementSubPage == null) {
      return;
    }

    if (_managementTitle == title &&
        ((_managementActions == null && actions == null) ||
         (_managementActions != null &&
          actions != null &&
          _managementActions!.length == actions.length))) {
      return;
    }

    setState(() {
      _managementTitle = title;
      _managementActions = actions;
    });
  }

  void _backToManagement() {
    setState(() {
      _managementSubPage = null;
      _managementTitle = 'Gestion';
      _managementActions = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // ============================================================
      // APPBAR GLOBALE
      // ============================================================

      appBar: _currentIndex == 4
          ? AppBar(
              backgroundColor: const Color(0xFF111111),
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              titleSpacing: 0,

              leading: _managementSubPage == null
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Retour à Gestion',
                      onPressed: _backToManagement,
                    ),

              title: Text(
                _managementTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),

              actions: _managementActions,
            )
          : null,

      // ============================================================
      // CONTENU PRINCIPAL
      // ============================================================

      body: ManagementAppBarScope(
        currentTitle: _managementTitle,
        onChanged: _configureManagementAppBar,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // --------------------------------------------------------
            // 0 — ACCUEIL
            // --------------------------------------------------------

            HomePage(
              user: widget.user,
              onLogout: widget.onLogout,
              showNavigation: false,
            ),

            // --------------------------------------------------------
            // 1 — MISSIONS
            // --------------------------------------------------------

            const _SectionPage(
              title: 'Missions',
              icon: Icons.assignment_outlined,
              description: 'Gérer vos missions',
            ),

            // --------------------------------------------------------
            // 2 — NOUVELLE MISSION
            // --------------------------------------------------------

            const CreateMissionPage(),

            // --------------------------------------------------------
            // 3 — STATISTIQUES
            // --------------------------------------------------------

            const _SectionPage(
              title: 'Statistiques',
              icon: Icons.bar_chart_outlined,
              description: 'Suivre votre activité',
            ),

            // --------------------------------------------------------
            // 4 — GESTION
            // --------------------------------------------------------

            _managementSubPage ??
                ManagementPage(
                  user: widget.user,
                  onOpenPage: _openManagementPage,
                ),

            // --------------------------------------------------------
            // 5 — MON PROFIL
            // --------------------------------------------------------

            const ProfilePage(),
          ],
        ),
      ),

      // ============================================================
      // NAVIGATION BASSE
      // ============================================================

      bottomNavigationBar: _BottomNavigation(
        currentIndex: _currentIndex,
        onSelected: _selectTab,
      ),
    );
  }
}

// ==================================================================
// NAVIGATION BASSE
// ==================================================================

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.currentIndex,
    required this.onSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          12,
          0,
          12,
          10,
        ),
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.08,
                ),
                blurRadius: 18,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // ====================================================
              // ACCUEIL
              // ====================================================

              Expanded(
                child: _NavigationItem(
                  index: 0,
                  currentIndex: currentIndex,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Accueil',
                  onTap: onSelected,
                ),
              ),

              // ====================================================
              // MISSIONS
              // ====================================================

              Expanded(
                child: _NavigationItem(
                  index: 1,
                  currentIndex: currentIndex,
                  icon: Icons.assignment_outlined,
                  activeIcon: Icons.assignment,
                  label: 'Missions',
                  onTap: onSelected,
                ),
              ),

              // ====================================================
              // NOUVELLE MISSION
              // ====================================================

              Expanded(
                child: _NewMissionButton(
                  active: currentIndex == 2,
                  onTap: () => onSelected(2),
                ),
              ),

              // ====================================================
              // STATISTIQUES
              // ====================================================

              Expanded(
                child: _NavigationItem(
                  index: 3,
                  currentIndex: currentIndex,
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart,
                  label: 'Stats',
                  onTap: onSelected,
                ),
              ),

              // ====================================================
              // GESTION
              // ====================================================

              Expanded(
                child: _NavigationItem(
                  index: 4,
                  currentIndex: currentIndex,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Gestion',
                  onTap: onSelected,
                ),
              ),

              // ====================================================
              // PROFIL
              // ====================================================

              Expanded(
                child: _NavigationItem(
                  index: 5,
                  currentIndex: currentIndex,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profil',
                  onTap: onSelected,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// ITEM DE NAVIGATION
// ==================================================================

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  final int index;
  final int currentIndex;

  final IconData icon;
  final IconData activeIcon;

  final String label;

  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bool active = index == currentIndex;

    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
            duration: const Duration(
              milliseconds: 180,
            ),
            width: 50,
            height: 30,
            decoration: BoxDecoration(
              color: active
              ? const Color(0xFFFFE4E4)
              : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              active ? activeIcon : icon,
              size: 22,
              color: active
              ? red
              : const Color(0xFF444444),
            ),
          ),

          const SizedBox(height: 3),

            SizedBox(
              width: double.infinity,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active
                  ? FontWeight.w600
                  : FontWeight.w400,
                  color: active
                  ? red
                  : const Color(0xFF444444),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// BOUTON NOUVELLE MISSION
// ==================================================================

class _NewMissionButton extends StatelessWidget {
  const _NewMissionButton({
    required this.active,
    required this.onTap,
  });

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(
              milliseconds: 180,
            ),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: red,
              shape: BoxShape.circle,
              boxShadow: active
              ? [
                BoxShadow(
                  color: red.withValues(
                    alpha: 0.25,
                  ),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
              : null,
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 25,
            ),
          ),

          const SizedBox(height: 2),

          const Text(
            'Nouvelle mission',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF444444),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// ÉCRANS TEMPORAIRES
// ==================================================================

class _SectionPage extends StatelessWidget {
  const _SectionPage({
    required this.title,
    required this.icon,
    required this.description,
  });

  final String title;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: const Color(0xFFE30613),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF222222),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
