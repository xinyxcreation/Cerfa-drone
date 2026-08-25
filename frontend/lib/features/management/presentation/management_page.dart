import 'package:flutter/material.dart';

import '../../auth/models/current_user.dart';
import '../models/company_pilot.dart';
import '../services/pilots_service.dart';
import '../../models/company.dart';
import '../../company/services/company_service.dart';

class ManagementPage extends StatelessWidget {
  const ManagementPage({
    super.key,
    required this.user,
  });

  final CurrentUser user;

  @override
  Widget build(BuildContext context) {
    final role = user.role.toUpperCase();
    final canManageCompany =
    role == 'OWNER' || role == 'MANAGER';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: const Text(
            'Gestion',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          20,
          16,
          30,
        ),
        children: [
          if (canManageCompany)
            _ManagementCard(
              icon: Icons.business_outlined,
              title: 'Entreprise',
              subtitle: user.companyName,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CompanyPage(
                      user: user,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            if (canManageCompany)
              _ManagementCard(
                icon: Icons.person_outline,
                title: 'Pilotes',
                subtitle: 'Gérer les pilotes de l’entreprise',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                      PilotsPage(
                        user: user,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              _ManagementCard(
                icon: Icons.flight_outlined,
                title: 'Drones',
                subtitle:
                'Gérer les drones de l’entreprise',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DronesPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              _ManagementCard(
                icon: Icons.location_on_outlined,
                title: 'Sites',
                subtitle:
                'Gérer les sites d’intervention',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SitesPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              _ManagementCard(
                icon: Icons.folder_outlined,
                title: 'Documents',
                subtitle:
                'Documents et justificatifs',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DocumentsPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              _ManagementCard(
                icon: Icons.settings_outlined,
                title: 'Paramètres',
                subtitle:
                'Configuration de CERFA DRONE',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettingsPage(),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }
}

// ==================================================================
// CARTE GESTION
// ==================================================================

class _ManagementCard extends StatelessWidget {
  const _ManagementCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E4),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFE30613),
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
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

// ==================================================================
// ENTREPRISE
// ==================================================================

class CompanyPage extends StatefulWidget {
  const CompanyPage({
    super.key,
    required this.user,
  });

  final CurrentUser user;

  @override
  State<CompanyPage> createState() =>
  _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  late Future<Company> _companyFuture;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  void _loadCompany() {
    _companyFuture =
    CompanyService.getCompany();
  }

  Future<void> _refresh() async {
    setState(_loadCompany);

    try {
      await _companyFuture;
    } catch (_) {}
  }

  Future<void> _editCompany(
    Company company,
  ) async {
    final updated =
    await Navigator.of(context).push<Company>(
      MaterialPageRoute(
        builder: (_) => EditCompanyPage(
          company: company,
        ),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _companyFuture =
        Future.value(updated);
      });
    }
  }

  String _roleLabel(String role) {
    switch (role.toUpperCase()) {
      case 'OWNER':
        return 'Propriétaire';

      case 'MANAGER':
        return 'Gestionnaire';

      case 'PILOT':
        return 'Pilote';

      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.user.role.toUpperCase();
    final canEdit =
    role == 'OWNER' || role == 'MANAGER';

    return _ManagementSubPage(
      title: 'Entreprise',
      icon: Icons.business_outlined,
      actions: [
        IconButton(
          tooltip: 'Actualiser',
          onPressed: _refresh,
          icon: const Icon(
            Icons.refresh,
          ),
        ),
      ],
      children: [
        FutureBuilder<Company>(
          future: _companyFuture,
          builder: (
            context,
            snapshot,
          ) {
            if (snapshot.connectionState ==
              ConnectionState.waiting) {
              return const _CompanyLoadingState();
              }

              if (snapshot.hasError) {
                return _CompanyErrorState(
                  message: snapshot.error
                  ?.toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  ) ??
                  'Impossible de charger l’entreprise.',
                  onRetry: () {
                    setState(_loadCompany);
                  },
                );
              }

              final company = snapshot.data;

              if (company == null) {
                return _CompanyErrorState(
                  message:
                  'Aucune entreprise disponible.',
                  onRetry: () {
                    setState(_loadCompany);
                  },
                );
              }

              return Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  _CompanyHeaderCard(
                    company: company,
                    role: _roleLabel(
                      widget.user.role,
                    ),
                    canEdit: canEdit,
                    onEdit: () =>
                    _editCompany(company),
                  ),

                  const SizedBox(height: 16),

                  _CompanySection(
                    title: 'Identité',
                    icon:
                    Icons.business_outlined,
                    children: [
                      _CompanyInfoRow(
                        label: 'Nom de l’entreprise',
                        value: company.name,
                      ),
                      _CompanyInfoRow(
                        label: 'Raison sociale',
                        value: company.legalName,
                      ),
                      _CompanyInfoRow(
                        label: 'Nom du contact',
                        value: company.contactName,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _CompanySection(
                    title: 'Informations administratives',
                    icon: Icons.badge_outlined,
                    children: [
                      _CompanyInfoRow(
                        label: 'SIRET',
                        value: company.siret,
                      ),
                      _CompanyInfoRow(
                        label:
                        'N° exploitant AlphaTango',
                        value:
                        company.alphatangoOperatorNumber,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _CompanySection(
                    title: 'Coordonnées',
                    icon: Icons.contact_phone_outlined,
                    children: [
                      _CompanyInfoRow(
                        label: 'E-mail',
                        value: company.email,
                      ),
                      _CompanyInfoRow(
                        label: 'Téléphone',
                        value: company.phone,
                      ),
                      _CompanyInfoRow(
                        label: 'Site internet',
                        value: company.websiteUrl,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _CompanySection(
                    title: 'Adresse',
                    icon: Icons.location_on_outlined,
                    children: [
                      _CompanyInfoRow(
                        label: 'Adresse',
                        value: company.addressLine1,
                      ),
                      _CompanyInfoRow(
                        label: 'Complément',
                        value: company.addressLine2,
                      ),
                      _CompanyInfoRow(
                        label: 'Code postal',
                        value: company.postalCode,
                      ),
                      _CompanyInfoRow(
                        label: 'Ville',
                        value: company.city,
                      ),
                      _CompanyInfoRow(
                        label: 'Pays',
                        value: company.country,
                      ),
                    ],
                  ),

                  if (company.notes != null &&
                    company.notes!
                    .trim()
                    .isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _CompanySection(
                        title: 'Notes',
                        icon: Icons.notes_outlined,
                        children: [
                          _CompanyInfoRow(
                            label: 'Notes',
                            value: company.notes,
                          ),
                        ],
                      ),
                    ],
                ],
              );
          },
        ),
      ],
    );
  }
}
// ==================================================================
// EN-TÊTE ENTREPRISE
// ==================================================================

class _CompanyHeaderCard extends StatelessWidget {
  const _CompanyHeaderCard({
    required this.company,
    required this.role,
    required this.canEdit,
    required this.onEdit,
  });

  final Company company;
  final String role;
  final bool canEdit;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color:
              const Color(0xFFFFE4E4),
              borderRadius:
              BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.business_outlined,
              color: Color(0xFFE30613),
              size: 38,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            company.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF222222),
            ),
          ),

          const SizedBox(height: 6),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color:
              const Color(0xFFFFE4E4),
              borderRadius:
              BorderRadius.circular(20),
            ),
            child: Text(
              role,
              style: const TextStyle(
                color: Color(0xFFE30613),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          if (canEdit) ...[
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onEdit,
                style:
                FilledButton.styleFrom(
                  backgroundColor:
                  const Color(0xFFE30613),
                  foregroundColor:
                    Colors.white,
                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(12),
                    ),
                ),
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 19,
                ),
                label: const Text(
                  'Modifier l’entreprise',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ==================================================================
// SECTION ENTREPRISE
// ==================================================================

class _CompanySection extends StatelessWidget {
  const _CompanySection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color:
                const Color(0xFFE30613),
                size: 21,
              ),

              const SizedBox(width: 9),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w800,
                  color:
                  Color(0xFF222222),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ...children,
        ],
      ),
    );
  }
}

// ==================================================================
// INFORMATION ENTREPRISE
// ==================================================================

class _CompanyInfoRow extends StatelessWidget {
  const _CompanyInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final displayValue =
    value == null ||
    value!.trim().isEmpty
    ? 'Non renseigné'
    : value!.trim();

    final empty =
    value == null ||
    value!.trim().isEmpty;

    return Padding(
      padding:
      const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color:
              Colors.grey.shade600,
              fontWeight:
              FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            displayValue,
            style: TextStyle(
              fontSize: 15,
              fontWeight:
              FontWeight.w700,
              color: empty
              ? Colors.grey.shade400
              : const Color(0xFF222222),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// CHARGEMENT ENTREPRISE
// ==================================================================

class _CompanyLoadingState
extends StatelessWidget {
  const _CompanyLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE30613),
        ),
      ),
    );
  }
}

// ==================================================================
// ERREUR ENTREPRISE
// ==================================================================

class _CompanyErrorState
extends StatelessWidget {
  const _CompanyErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFE30613),
            size: 46,
          ),

          const SizedBox(height: 14),

          const Text(
            'Impossible de charger l’entreprise',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color:
              Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 18),

          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(
              Icons.refresh,
            ),
            label: const Text(
              'Réessayer',
            ),
          ),
        ],
      ),
    );
  }
}
// ==================================================================
// MODIFICATION ENTREPRISE
// ==================================================================

class EditCompanyPage extends StatefulWidget {
  const EditCompanyPage({
    super.key,
    required this.company,
  });

  final Company company;

  @override
  State<EditCompanyPage> createState() =>
  _EditCompanyPageState();
}

class _EditCompanyPageState
extends State<EditCompanyPage> {
  final _formKey =
  GlobalKey<FormState>();

  late final TextEditingController
  _nameController;

  late final TextEditingController
  _legalNameController;

  late final TextEditingController
  _contactNameController;

  late final TextEditingController
  _siretController;

  late final TextEditingController
  _alphaTangoController;

  late final TextEditingController
  _emailController;

  late final TextEditingController
  _phoneController;

  late final TextEditingController
  _websiteController;

  late final TextEditingController
  _address1Controller;

  late final TextEditingController
  _address2Controller;

  late final TextEditingController
  _postalCodeController;

  late final TextEditingController
  _cityController;

  late final TextEditingController
  _countryController;

  late final TextEditingController
  _notesController;

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    final company = widget.company;

    _nameController =
    TextEditingController(
      text: company.name,
    );

    _legalNameController =
    TextEditingController(
      text: company.legalName ?? '',
    );

    _contactNameController =
    TextEditingController(
      text: company.contactName ?? '',
    );

    _siretController =
    TextEditingController(
      text: company.siret ?? '',
    );

    _alphaTangoController =
    TextEditingController(
      text:
      company.alphatangoOperatorNumber,
    );

    _emailController =
    TextEditingController(
      text: company.email ?? '',
    );

    _phoneController =
    TextEditingController(
      text: company.phone ?? '',
    );

    _websiteController =
    TextEditingController(
      text: company.websiteUrl ?? '',
    );

    _address1Controller =
    TextEditingController(
      text: company.addressLine1 ?? '',
    );

    _address2Controller =
    TextEditingController(
      text: company.addressLine2 ?? '',
    );

    _postalCodeController =
    TextEditingController(
      text: company.postalCode ?? '',
    );

    _cityController =
    TextEditingController(
      text: company.city ?? '',
    );

    _countryController =
    TextEditingController(
      text: company.country,
    );

    _notesController =
    TextEditingController(
      text: company.notes ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _legalNameController.dispose();
    _contactNameController.dispose();
    _siretController.dispose();
    _alphaTangoController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  String? _nullable(
    TextEditingController controller,
  ) {
    final value =
    controller.text.trim();

    return value.isEmpty ? null : value;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!
      .validate()) {
      return;
      }

      setState(() {
        _loading = true;
      });

    final updated = Company(
      id: widget.company.id,
      name: _nameController.text.trim(),
      legalName:
      _nullable(_legalNameController),
      contactName:
      _nullable(_contactNameController),
      siret: _nullable(_siretController),
      alphatangoOperatorNumber:
      _alphaTangoController.text.trim(),
      email: _nullable(_emailController),
      phone: _nullable(_phoneController),
      websiteUrl:
      _nullable(_websiteController),
      addressLine1:
      _nullable(_address1Controller),
      addressLine2:
      _nullable(_address2Controller),
      postalCode:
      _nullable(_postalCodeController),
      city: _nullable(_cityController),
      country:
      _countryController.text.trim(),
      logoPath: widget.company.logoPath,
      signaturePath:
      widget.company.signaturePath,
      isActive: widget.company.isActive,
      notes: _nullable(_notesController),
      createdAt: widget.company.createdAt,
      updatedAt: widget.company.updatedAt,
    );

    try {
      final result =
      await CompanyService.updateCompany(
        updated,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
      .showSnackBar(
        const SnackBar(
          content: Text(
            'Entreprise enregistrée.',
          ),
          behavior:
          SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(result);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
      .showSnackBar(
        SnackBar(
          content: Text(
            error
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            ),
          ),
          backgroundColor:
          const Color(0xFFB91C1C),
          behavior:
          SnackBarBehavior.floating,
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

  @override
  Widget build(BuildContext context) {
    return _ManagementSubPage(
      title: 'Modifier l’entreprise',
      icon: Icons.business_outlined,
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              _FormField(
                controller: _nameController,
                label:
                'Nom de l’entreprise',
                icon:
                Icons.business_outlined,
                enabled: !_loading,
                validator: (value) {
                  if (value == null ||
                    value.trim().isEmpty) {
                    return
                    'Le nom de l’entreprise est obligatoire.';
                    }

                    return null;
                },
              ),

              const SizedBox(height: 12),

              _FormField(
                controller:
                _legalNameController,
                label: 'Raison sociale',
                icon: Icons.badge_outlined,
                enabled: !_loading,
              ),

              const SizedBox(height: 12),

              _FormField(
                controller:
                _contactNameController,
                label: 'Nom du contact',
                icon:
                Icons.person_outline,
                enabled: !_loading,
              ),

              const SizedBox(height: 12),

              _FormField(
                controller: _siretController,
                label: 'SIRET',
                icon: Icons.numbers_outlined,
                keyboardType:
                TextInputType.number,
                enabled: !_loading,
                validator: (value) {
                  final siret =
                  value?.trim() ?? '';

              if (siret.isEmpty) {
                return null;
              }

              if (!RegExp(
                r'^\d{14}$',
              ).hasMatch(siret)) {
                return
                'Le SIRET doit contenir exactement 14 chiffres.';
              }

              return null;
                },
              ),

              const SizedBox(height: 12),

              _FormField(
                controller:
                _alphaTangoController,
                label:
                'N° exploitant AlphaTango',
                icon:
                Icons.flight_takeoff_outlined,
                enabled: !_loading,
                validator: (value) {
                  if (value == null ||
                    value.trim().isEmpty) {
                    return
                    'Le numéro AlphaTango est obligatoire.';
                    }

                    return null;
                },
              ),

              const SizedBox(height: 12),

              _FormField(
                controller: _emailController,
                label: 'E-mail',
                icon:
                Icons.email_outlined,
                keyboardType:
                TextInputType.emailAddress,
                enabled: !_loading,
                validator: (value) {
                  final email =
                  value?.trim() ?? '';

              if (email.isEmpty) {
                return null;
              }

              if (!RegExp(
                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
              ).hasMatch(email)) {
                return
                'Adresse e-mail invalide.';
              }

              return null;
                },
              ),

              const SizedBox(height: 12),

              _FormField(
                controller: _phoneController,
                label: 'Téléphone',
                icon:
                Icons.phone_outlined,
                keyboardType:
                TextInputType.phone,
                enabled: !_loading,
              ),

              const SizedBox(height: 12),

              _FormField(
                controller:
                _websiteController,
                label: 'Site internet',
                icon:
                Icons.language_outlined,
                keyboardType:
                TextInputType.url,
                enabled: !_loading,
              ),

              const SizedBox(height: 20),

              const Align(
                alignment:
                Alignment.centerLeft,
                child: Text(
                  'Adresse',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w800,
                    color:
                    Color(0xFF222222),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _FormField(
                controller:
                _address1Controller,
                label: 'Adresse',
                icon:
                Icons.location_on_outlined,
                enabled: !_loading,
              ),

              const SizedBox(height: 12),

              _FormField(
                controller:
                _address2Controller,
                label: 'Complément d’adresse',
                icon:
                Icons.home_outlined,
                enabled: !_loading,
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _FormField(
                      controller:
                      _postalCodeController,
                      label: 'Code postal',
                      icon:
                      Icons.markunread_mailbox_outlined,
                      keyboardType:
                      TextInputType.number,
                      enabled: !_loading,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _FormField(
                      controller:
                      _cityController,
                      label: 'Ville',
                      icon:
                      Icons.location_city_outlined,
                      enabled: !_loading,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _FormField(
                controller:
                _countryController,
                label: 'Pays',
                icon:
                Icons.public_outlined,
                enabled: !_loading,
                validator: (value) {
                  if (value == null ||
                    value.trim().isEmpty) {
                    return
                    'Le pays est obligatoire.';
                    }

                    return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller:
                _notesController,
                enabled: !_loading,
                maxLines: 5,
                decoration:
                _inputDecoration(
                  label: 'Notes',
                  icon:
                  Icons.notes_outlined,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                  _loading ? null : _save,
                  style:
                  FilledButton.styleFrom(
                    backgroundColor:
                    const Color(0xFFE30613),
                    foregroundColor:
                      Colors.white,
                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          13,
                        ),
                      ),
                  ),
                  child: _loading
                  ? const SizedBox(
                    width: 21,
                    height: 21,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color:
                      Colors.white,
                    ),
                  )
                  : const Text(
                    'Enregistrer',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// PILOTES
// ==================================================================

class PilotsPage extends StatefulWidget {
  const PilotsPage({
    super.key,
    required this.user,
  });

  final CurrentUser user;

  @override
  State<PilotsPage> createState() =>
  _PilotsPageState();
}

class _PilotsPageState extends State<PilotsPage> {
  late Future<List<CompanyPilot>> _pilotsFuture;

  @override
  void initState() {
    super.initState();
    _loadPilots();
  }

  void _loadPilots() {
    _pilotsFuture =
    PilotsService.getPilots();
  }

  Future<void> _refresh() async {
    setState(_loadPilots);

    try {
      await _pilotsFuture;
    } catch (_) {}
  }

  Future<void> _openCreatePilot() async {
    final created =
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
        CreatePilotPage(
          user: widget.user,
        ),
      ),
    );

    if (created == true && mounted) {
      setState(_loadPilots);
    }
  }

  Future<void> _openPilot(
    CompanyPilot pilot,
  ) async {
    final changed =
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
        PilotDetailsPage(
          pilot: pilot,
        ),
      ),
    );

    if (changed == true && mounted) {
      setState(_loadPilots);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ManagementSubPage(
      title: 'Pilotes',
      icon: Icons.person_outline,
      actions: [
        IconButton(
          tooltip: 'Actualiser',
          onPressed: _refresh,
          icon: const Icon(
            Icons.refresh,
          ),
        ),
      ],
      children: [
        FutureBuilder<List<CompanyPilot>>(
          future: _pilotsFuture,
          builder: (
            context,
            snapshot,
          ) {
            if (snapshot.connectionState ==
              ConnectionState.waiting) {
              return const _PilotLoadingState();
              }

              if (snapshot.hasError) {
                return _PilotErrorState(
                  message: snapshot.error
                  ?.toString()
                  .replaceFirst(
                    'Exception: ',
                    '',
                  ) ??
                  'Impossible de charger les pilotes.',
                  onRetry: () {
                    setState(_loadPilots);
                  },
                );
              }

              final pilots =
              snapshot.data ?? [];

              return Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  _PilotHeader(
                    count: pilots.length,
                    onAdd: _openCreatePilot,
                  ),

                  const SizedBox(height: 16),

                  if (pilots.isEmpty)
                  const _EmptyPilotsState()
                    else
                      ...pilots.map(
                        (pilot) => Padding(
                          padding:
                          const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: _PilotCard(
                            pilot: pilot,
                            onTap: () =>
                            _openPilot(pilot),
                          ),
                        ),
                      ),
                ],
              );
          },
        ),
      ],
    );
  }
}

// ==================================================================
// HEADER PILOTES
// ==================================================================

class _PilotHeader extends StatelessWidget {
  const _PilotHeader({
    required this.count,
    required this.onAdd,
  });

  final int count;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Équipe de pilotes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF222222),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                count == 0
                ? 'Aucun pilote'
              : '$count pilote${count > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        FilledButton.icon(
          onPressed: onAdd,
          style: FilledButton.styleFrom(
            backgroundColor:
            const Color(0xFFE30613),
            foregroundColor: Colors.white,
              padding:
              const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(12),
              ),
          ),
          icon: const Icon(
            Icons.person_add_outlined,
            size: 19,
          ),
          label: const Text(
            'Ajouter',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// CARTE PILOTE
// ==================================================================

class _PilotCard extends StatelessWidget {
  const _PilotCard({
    required this.pilot,
    required this.onTap,
  });

  final CompanyPilot pilot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                  color:
                  const Color(0xFFFFE4E4),
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: Text(
                  pilot.initials,
                  style: const TextStyle(
                    color: Color(0xFFE30613),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                      overflow:
                      TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                        Colors.grey.shade600,
                      ),
                    ),

                    if (pilot.phone != null &&
                      pilot.phone!
                      .trim()
                      .isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          pilot.phone!,
                          style: TextStyle(
                            fontSize: 13,
                            color:
                            Colors.grey.shade600,
                          ),
                        ),
                      ],
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

// ==================================================================
// AJOUT PILOTE
// ==================================================================

class CreatePilotPage extends StatefulWidget {
  const CreatePilotPage({
    super.key,
    required this.user,
  });

  final CurrentUser user;

  @override
  State<CreatePilotPage> createState() =>
  _CreatePilotPageState();
}

class _CreatePilotPageState
extends State<CreatePilotPage> {
  final _formKey =
  GlobalKey<FormState>();

  final _firstnameController =
  TextEditingController();

  final _lastnameController =
  TextEditingController();

  final _emailController =
  TextEditingController();

  final _phoneController =
  TextEditingController();

  final _passwordController =
  TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;
  bool _isSelfPilot = false;

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      if (_isSelfPilot) {
        await PilotsService.setCurrentUserPilot(true);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Vous êtes maintenant pilote.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        await PilotsService.createPilot(
          firstname: _firstnameController.text,
          lastname: _lastnameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phone: _phoneController.text,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pilote créé avec succès.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);

    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              const Color(0xFFB91C1C),
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

  @override
  Widget build(BuildContext context) {
    return _ManagementSubPage(
      title: 'Ajouter un pilote',
      icon: Icons.person_add_outlined,
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              if (!widget.user.isPilot) ...[
                Card(
                  margin: EdgeInsets.zero,
                  child: CheckboxListTile(
                    value: _isSelfPilot,
                    onChanged: _loading
                        ? null
                        : (value) {
                            setState(() {
                              _isSelfPilot = value ?? false;

                              if (_isSelfPilot) {
                                _firstnameController.text =
                                    widget.user.firstName;
                                _lastnameController.text =
                                    widget.user.lastName;
                                _emailController.text =
                                    widget.user.email;
                                _phoneController.text =
                                    widget.user.phone ?? '';
                              }
                            });
                          },
                    secondary: const Icon(
                      Icons.flight_outlined,
                    ),
                    title: const Text(
                      'Je suis pilote',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: const Text(
                      'Utiliser mon compte actuel comme pilote.',
                    ),
                    controlAffinity:
                        ListTileControlAffinity.trailing,
                  ),
                ),

                const SizedBox(height: 12),
              ],

              _FormField(
                controller:
                _firstnameController,
                label: 'Prénom',
                icon:
                Icons.person_outline,
                enabled: !_loading,
                validator: (value) {
                  if (value == null ||
                    value.trim().isEmpty) {
                    return 'Le prénom est obligatoire.';
                    }

                    return null;
                },
              ),

              const SizedBox(height: 12),

              _FormField(
                controller:
                _lastnameController,
                label: 'Nom',
                icon:
                Icons.person_outline,
                enabled: !_loading,
                validator: (value) {
                  if (value == null ||
                    value.trim().isEmpty) {
                    return 'Le nom est obligatoire.';
                    }

                    return null;
                },
              ),

              const SizedBox(height: 12),

              _FormField(
                controller:
                _emailController,
                label: 'Adresse e-mail',
                icon: Icons.email_outlined,
                keyboardType:
                TextInputType.emailAddress,
                enabled: !_loading,
                validator: (value) {
                  final email =
                  value?.trim() ?? '';

              if (email.isEmpty) {
                return 'L’adresse e-mail est obligatoire.';
              }

              final valid = RegExp(
                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
              ).hasMatch(email);

              if (!valid) {
                return 'Adresse e-mail invalide.';
              }

              return null;
                },
              ),

              const SizedBox(height: 12),

              _FormField(
                controller:
                _phoneController,
                label: 'Téléphone',
                icon:
                Icons.phone_outlined,
                keyboardType:
                TextInputType.phone,
                enabled: !_loading,
              ),

              const SizedBox(height: 12),

              if (!_isSelfPilot) ...[
                TextFormField(
                  controller:
                  _passwordController,
                  obscureText:
                  _obscurePassword,
                  enabled: !_loading,
                  validator: (value) {
                    if (value == null ||
                      value.isEmpty) {
                      return 'Le mot de passe est obligatoire.';
                    }

                    if (value.length < 8) {
                      return '8 caractères minimum.';
                    }

                    return null;
                  },
                  decoration:
                  _inputDecoration(
                    label: 'Mot de passe initial',
                    icon:
                    Icons.lock_outline,
                    suffixIcon:
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                          !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons
                        .visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 10),

              Align(
                alignment:
                Alignment.centerLeft,
                child: Text(
                  'Le pilote pourra utiliser ce mot de passe pour sa première connexion.',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                    Colors.grey.shade600,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                  _loading ? null : _create,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                    const Color(0xFFE30613),
                    foregroundColor:
                      Colors.white,
                      padding:
                      const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(13),
                      ),
                  ),
                  child: _loading
                  ? const SizedBox(
                    width: 21,
                    height: 21,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color:
                      Colors.white,
                    ),
                  )
                  : const Text(
                    'Créer le pilote',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================================================================
// DETAIL PILOTE
// ==================================================================

class PilotDetailsPage extends StatefulWidget {
  const PilotDetailsPage({
    super.key,
    required this.pilot,
  });

  final CompanyPilot pilot;

  @override
  State<PilotDetailsPage> createState() =>
  _PilotDetailsPageState();
}

class _PilotDetailsPageState
extends State<PilotDetailsPage> {
  bool _loading = false;

  Future<void> _deactivate() async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
          const Text('Désactiver le pilote ?'),
          content: Text(
            '${widget.pilot.displayName} ne sera plus associé à l’entreprise.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
              Navigator.of(context)
              .pop(false),
              child:
              const Text('Annuler'),
            ),
            FilledButton(
              style:
              FilledButton.styleFrom(
                backgroundColor:
                const Color(0xFFE30613),
              ),
              onPressed: () =>
              Navigator.of(context)
              .pop(true),
              child:
              const Text('Désactiver'),
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
      await PilotsService
      .deactivatePilot(
        widget.pilot.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
      .showSnackBar(
        const SnackBar(
          content: Text(
            'Pilote désactivé.',
          ),
          behavior:
          SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(true);

    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
      .showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
          backgroundColor:
          const Color(0xFFB91C1C),
          behavior:
          SnackBarBehavior.floating,
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

  @override
  Widget build(BuildContext context) {
    final pilot = widget.pilot;

    return _ManagementSubPage(
      title: 'Pilote',
      icon: Icons.person_outline,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color:
                  const Color(0xFFFFE4E4),
                  borderRadius:
                  BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Text(
                  pilot.initials,
                  style: const TextStyle(
                    color: Color(0xFFE30613),
                    fontSize: 24,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                pilot.displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight:
                  FontWeight.w800,
                  color:
                  Color(0xFF222222),
                ),
              ),

              const SizedBox(height: 5),

              Text(
                pilot.role,
                style: const TextStyle(
                  color:
                  Color(0xFFE30613),
                  fontSize: 13,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        _InfoCard(
          title: 'Adresse e-mail',
          value: pilot.email,
        ),

        if (pilot.phone != null &&
          pilot.phone!
          .trim()
          .isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoCard(
              title: 'Téléphone',
              value: pilot.phone!,
            ),
          ],

          if (pilot.joinedAt != null) ...[
            const SizedBox(height: 12),
            _InfoCard(
              title: 'Membre depuis',
              value:
              _formatDate(pilot.joinedAt!),
            ),
          ],

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed:
              _loading ? null : _deactivate,
              style:
              OutlinedButton.styleFrom(
                foregroundColor:
                  const Color(0xFFE30613),
                  side: const BorderSide(
                    color:
                    Color(0xFFE30613),
                  ),
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(13),
                  ),
              ),
              icon: _loading
              ? const SizedBox(
                width: 18,
                height: 18,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
              : const Icon(
                Icons.person_off_outlined,
              ),
              label: Text(
                _loading
                ? 'Désactivation...'
              : 'Désactiver le pilote',
              style: const TextStyle(
                fontWeight:
                FontWeight.w700,
              ),
              ),
            ),
          ),
      ],
    );
  }
}

// ==================================================================
// CHAMPS FORMULAIRE
// ==================================================================

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(
        label: label,
        icon: icon,
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required String label,
  required IconData icon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius:
      BorderRadius.circular(13),
      borderSide: BorderSide.none,
    ),
    enabledBorder:
    OutlineInputBorder(
      borderRadius:
      BorderRadius.circular(13),
      borderSide: BorderSide.none,
    ),
    focusedBorder:
    OutlineInputBorder(
      borderRadius:
      BorderRadius.circular(13),
      borderSide: const BorderSide(
        color: Color(0xFFE30613),
        width: 1.4,
      ),
    ),
    errorBorder:
    OutlineInputBorder(
      borderRadius:
      BorderRadius.circular(13),
      borderSide: const BorderSide(
        color: Color(0xFFDC2626),
      ),
    ),
    focusedErrorBorder:
    OutlineInputBorder(
      borderRadius:
      BorderRadius.circular(13),
      borderSide: const BorderSide(
        color: Color(0xFFDC2626),
        width: 1.4,
      ),
    ),
  );
}

// ==================================================================
// CHARGEMENT
// ==================================================================

class _PilotLoadingState
extends StatelessWidget {
  const _PilotLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE30613),
        ),
      ),
    );
  }
}

// ==================================================================
// ERREUR
// ==================================================================

class _PilotErrorState
extends StatelessWidget {
  const _PilotErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Color(0xFFE30613),
            size: 46,
          ),

          const SizedBox(height: 14),

          const Text(
            'Impossible de charger les pilotes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 18),

          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(
              Icons.refresh,
            ),
            label: const Text(
              'Réessayer',
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// ÉTAT VIDE
// ==================================================================

class _EmptyPilotsState
extends StatelessWidget {
  const _EmptyPilotsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.person_outline,
            size: 48,
            color: Color(0xFFE30613),
          ),

          const SizedBox(height: 14),

          const Text(
            'Aucun pilote',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Ajoutez le premier pilote de cette entreprise.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 18),

        ],
      ),
    );
  }
}

// ==================================================================
// SOUS-PAGE
// ==================================================================

class _ManagementSubPage
extends StatelessWidget {
  const _ManagementSubPage({
    required this.title,
    required this.icon,
    required this.children,
    this.actions,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F5F5),

      appBar: AppBar(
        backgroundColor:
        const Color(0xFF111111),
        foregroundColor: Colors.white,
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: actions,
      ),

      body: ListView(
        padding:
        const EdgeInsets.all(16),
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color:
              const Color(0xFFFFE4E4),
              borderRadius:
              BorderRadius.circular(17),
            ),
            child: Icon(
              icon,
              color:
              const Color(0xFFE30613),
              size: 30,
            ),
          ),

          const SizedBox(height: 20),

          ...children,
        ],
      ),
    );
  }
}

// ==================================================================
// INFO
// ==================================================================

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight:
              FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight:
              FontWeight.w700,
              color:
              Color(0xFF222222),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// DRONES
// ==================================================================

class DronesPage extends StatelessWidget {
  const DronesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _ManagementSubPage(
      title: 'Drones',
      icon: Icons.flight_outlined,
      children: [
        _EmptyManagementState(
          icon: Icons.flight_outlined,
          title: 'Aucun drone chargé',
          message:
          'Les drones de l’entreprise seront affichés ici.',
        ),
      ],
    );
  }
}

// ==================================================================
// SITES
// ==================================================================

class SitesPage extends StatelessWidget {
  const SitesPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _ManagementSubPage(
      title: 'Sites',
      icon: Icons.location_on_outlined,
      children: [
        _EmptyManagementState(
          icon: Icons.location_on_outlined,
          title: 'Aucun site chargé',
          message:
          'Les sites d’intervention seront affichés ici.',
        ),
      ],
    );
  }
}

// ==================================================================
// DOCUMENTS
// ==================================================================

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _ManagementSubPage(
      title: 'Documents',
      icon: Icons.folder_outlined,
      children: [
        _EmptyManagementState(
          icon: Icons.folder_outlined,
          title: 'Aucun document chargé',
          message:
          'Les documents de l’entreprise seront affichés ici.',
        ),
      ],
    );
  }
}

// ==================================================================
// PARAMÈTRES
// ==================================================================

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _ManagementSubPage(
      title: 'Paramètres',
      icon: Icons.settings_outlined,
      children: [
        _EmptyManagementState(
          icon: Icons.settings_outlined,
          title: 'Paramètres',
          message:
          'Les paramètres de l’application seront disponibles ici.',
        ),
      ],
    );
  }
}

// ==================================================================
// ÉTAT VIDE AUTRES SECTIONS
// ==================================================================

class _EmptyManagementState
extends StatelessWidget {
  const _EmptyManagementState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color:
            const Color(0xFFE30613),
          ),

          const SizedBox(height: 14),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color:
              Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final day =
  date.day.toString().padLeft(2, '0');

  final month =
  date.month.toString().padLeft(2, '0');

  return '$day/$month/${date.year}';
}
