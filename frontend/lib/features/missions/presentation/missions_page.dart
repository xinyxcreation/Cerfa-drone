import 'package:flutter/material.dart';
import '../../management/models/company_site.dart';
import '../../management/services/sites_service.dart';
import '../../management/services/clients_service.dart';

import '../models/mission.dart';
import '../services/missions_service.dart';

class MissionsPage extends StatefulWidget {

  const MissionsPage({
    super.key,
  });

  @override
  State<MissionsPage> createState() =>
      _MissionsPageState();
}

class _MissionsPageState
    extends State<MissionsPage> {

  late Future<List<Mission>>
      _future;

  @override
  void initState() {

    super.initState();

    _load();
  }

  void _load() {

    _future =
        MissionsService.getMissions();
  }

  Future<void> _refresh() async {

    setState(_load);

    try {
      await _future;
    } catch (_) {}
  }

  Color _statusColor(
    String code,
  ) {

    switch (code.toUpperCase()) {

      case 'COMPLETED':
      case 'TERMINEE':
      case 'TERMINÉE':
        return const Color(0xFF2E7D32);

      case 'CANCELLED':
      case 'ANNULEE':
      case 'ANNULÉE':
        return const Color(0xFFC62828);

      case 'IN_PROGRESS':
      case 'EN_COURS':
        return const Color(0xFF1565C0);

      default:
        return const Color(0xFFD97706);
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F5F5),

      appBar: AppBar(

        backgroundColor:
            const Color(0xFF111111),

        foregroundColor:
            Colors.white,

        title:
            const Text(
          'Missions',
          style: TextStyle(
            fontWeight:
                FontWeight.w800,
          ),
        ),

        actions: [

          IconButton(
            tooltip: 'Actualiser',
            onPressed: _refresh,
            icon:
                const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () async {

          final created =
              await Navigator.of(context)
                  .push<Mission>(
            MaterialPageRoute(
              builder: (_) =>
                  const CreateMissionPage(),
            ),
          );

          if (created != null &&
              mounted) {

            _refresh();
          }
        },
        icon:
            const Icon(
          Icons.add,
        ),
        label:
            const Text(
          'Nouvelle mission',
        ),
      ),

      body:
          FutureBuilder<List<Mission>>(
        future: _future,
        builder: (
          context,
          snapshot,
        ) {

          if (
              snapshot.connectionState ==
              ConnectionState.waiting
          ) {

            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {

            return Center(
              child:
                  Padding(
                padding:
                    const EdgeInsets.all(24),
                child:
                    Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [

                    const Icon(
                      Icons.error_outline,
                      size: 48,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      snapshot.error
                          .toString()
                          .replaceFirst(
                            'Exception: ',
                            '',
                          ),
                      textAlign:
                          TextAlign.center,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    FilledButton.icon(
                      onPressed: _refresh,
                      icon:
                          const Icon(
                        Icons.refresh,
                      ),
                      label:
                          const Text(
                        'Réessayer',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final missions =
              snapshot.data ?? [];

          if (missions.isEmpty) {

            return RefreshIndicator(
              onRefresh: _refresh,
              child:
                  ListView(
                children: const [

                  SizedBox(
                    height: 160,
                  ),

                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                  ),

                  SizedBox(
                    height: 16,
                  ),

                  Center(
                    child:
                        Text(
                      'Aucune mission',
                      style:
                          TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 8,
                  ),

                  Center(
                    child:
                        Text(
                      'Créez votre première mission.',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child:
                ListView.separated(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                100,
              ),
              itemCount:
                  missions.length,
              separatorBuilder:
                  (_, _) =>
                      const SizedBox(
                height: 10,
              ),
              itemBuilder:
                  (context, index) {

                final mission =
                    missions[index];

                final statusColor =
                    _statusColor(
                  mission.statusCode,
                );

                return Card(
                  elevation: 0,
                  child:
                      InkWell(
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                    onTap: () {

                      Navigator.of(context)
                          .push(
                        MaterialPageRoute(
                          builder: (_) =>
                              MissionDetailsPage(
                            mission:
                                mission,
                          ),
                        ),
                      );
                    },
                    child:
                        Padding(
                      padding:
                          const EdgeInsets.all(
                        16,
                      ),
                      child:
                          Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [

                          Row(
                            children: [

                              Expanded(
                                child:
                                    Text(
                                  mission.title,
                                  style:
                                      const TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                              ),

                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      statusColor
                                          .withValues(
                                    alpha: 0.10,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    20,
                                  ),
                                ),
                                child:
                                    Text(
                                  mission.statusLabel,
                                  style:
                                      TextStyle(
                                    color:
                                        statusColor,
                                    fontSize:
                                        12,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          if (mission.reference !=
                              null)
                            Text(
                              mission.reference!,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            mission.clientName,
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            'Pilote : ${mission.pilotName}',
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            mission.categoryLabel,
                          ),

                          if (mission.plannedAt !=
                              null) ...[

                            const SizedBox(
                              height: 4,
                            ),

                            Text(
                              'Prévue le ${_formatDate(mission.plannedAt!)}',
                            ),
                          ],

                          if (mission.isArchived) ...[

                            const SizedBox(
                              height: 8,
                            ),

                            const Text(
                              'ARCHIVÉE',
                              style:
                                  TextStyle(
                                color:
                                    Color(
                                  0xFF616161,
                                ),
                                fontWeight:
                                    FontWeight
                                        .w800,
                                fontSize:
                                    11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(
    DateTime date,
  ) {

    final local =
        date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}


// ==================================================================
// CREATION
// ==================================================================

class CreateMissionPage
    extends StatefulWidget {

  const CreateMissionPage({
    super.key,
  });

  @override
  State<CreateMissionPage> createState() =>
      _CreateMissionPageState();
}

class _CreateMissionPageState
    extends State<CreateMissionPage> {

  MissionReferenceData? _references;

  List<CompanySite> _sites = [];
  CompanySite? _selectedSite;
  String _siteSearch = '';

  bool _loading = true;
  bool _saving = false;

  final _formKey =
      GlobalKey<FormState>();

  final _title =
      TextEditingController();

  final _reference =
      TextEditingController();

  final _description =
      TextEditingController();

  final _address =
      TextEditingController();

  final _address2 =
      TextEditingController();

  final _postalCode =
      TextEditingController();

  final _city =
      TextEditingController();

  String? _clientId;
  String? _pilotId;
  String? _categoryId;
  String? _statusId;
  String? _droneId;
  String? _prefectureId;

  DateTime? _plannedAt;

  @override
  void initState() {

    super.initState();

    _loadReferences();
  }

  @override
  void dispose() {

    _title.dispose();
    _reference.dispose();
    _description.dispose();
    _address.dispose();
    _address2.dispose();
    _postalCode.dispose();
    _city.dispose();

    super.dispose();
  }

  Future<void> _loadReferences() async {

    try {

      final references =
          await MissionsService
              .getReferences();

      final sites =
          await SitesService
              .getSites();

      if (!mounted) return;

      setState(() {

        _references =
            references;

        _sites =
            sites
                .where((site) => site.isActive)
                .toList();

        _loading = false;
      });

    } catch (error) {

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(
            error
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    }
  }

  void _selectSite(CompanySite site) {
    setState(() {
      _selectedSite = site;
      _siteSearch = site.name;

      _clientId = site.clientId;
      _categoryId = site.categoryId;
      _droneId = site.defaultDroneId;
      _pilotId = site.defaultPilotId;
      _prefectureId = site.prefectureId;

      _address.text = site.addressLine1;
      _address2.text = site.addressLine2 ?? '';
      _postalCode.text = site.postalCode;
      _city.text = site.city;

      if (_description.text.trim().isEmpty &&
          site.description != null) {
        _description.text = site.description!;
      }
    });
  }

  void _selectCategory(String? categoryId) {
    if (categoryId == null) {
      setState(() {
        _categoryId = null;
      });
      return;
    }

    final categories = _references?.categories ?? [];

    Map<String, dynamic>? category;

    for (final item in categories) {
      if (item['id']?.toString() == categoryId) {
        category = item;
        break;
      }
    }

    setState(() {
      _categoryId = categoryId;

      final defaultDroneId =
          category?['default_drone_id']?.toString();

      if (defaultDroneId != null &&
          defaultDroneId.isNotEmpty) {
        _droneId = defaultDroneId;
      }

      final categoryDescription =
          category?['description']?.toString().trim();

      if (_description.text.trim().isEmpty &&
          categoryDescription != null &&
          categoryDescription.isNotEmpty) {
        _description.text = categoryDescription;
      }
    });
  }


  Future<void> _addNewClient() async {
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    try {
      final result = await showDialog<Map<String, String>>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Ajouter un nouveau client'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nom obligatoire';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(dialogContext).pop(),
                child: const Text('Annuler'),
              ),
              FilledButton.icon(
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }

                  Navigator.of(dialogContext).pop({
                    'name': nameController.text.trim(),
                    'email': emailController.text.trim(),
                    'phone': phoneController.text.trim(),
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Créer'),
              ),
            ],
          );
        },
      );

      if (result == null || !mounted) {
        return;
      }

      final client = await ClientsService.createClient(
        name: result['name']!,
        email: result['email']?.trim().isEmpty == true
            ? null
            : result['email'],
        phone: result['phone']?.trim().isEmpty == true
            ? null
            : result['phone'],
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _clientId = client.id;
      });

      // Recharge les références pour que le nouveau client
      // apparaisse immédiatement dans la liste.
      final references =
          await MissionsService.getReferences();

      if (!mounted) {
        return;
      }

      setState(() {
        _references = references;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Client « ${client.name} » créé et sélectionné.',
          ),
        ),
      );
    } finally {
      nameController.dispose();
      emailController.dispose();
      phoneController.dispose();
    }
  }

  Future<void> _save() async {

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_clientId == null ||
        _pilotId == null ||
        _categoryId == null ||
        _droneId == null ||
        _prefectureId == null) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text(
            'Veuillez compléter les sélections obligatoires.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    try {

      final mission =
          await MissionsService
              .createMission(

        clientId:
            _clientId!,

        pilotId:
            _pilotId!,

        categoryId:
            _categoryId!,

        siteId:
            _selectedSite?.id,

        latitude:
            _selectedSite?.latitude,

        longitude:
            _selectedSite?.longitude,

        statusId:
            _statusId,

        title:
            _title.text,

        reference:
            _reference.text.trim().isEmpty
                ? null
                : _reference.text.trim(),

        description:
            _description.text.trim().isEmpty
                ? null
                : _description.text.trim(),

        plannedAt:
            _plannedAt,

        droneId:
            _droneId!,

        prefectureId:
            _prefectureId!,

        addressLine1:
            _address.text,

        addressLine2:
            _address2.text.trim().isEmpty
                ? null
                : _address2.text.trim(),

        postalCode:
            _postalCode.text,

        city:
            _city.text,
      );

      if (!mounted) return;

      Navigator.of(context)
          .pop(mission);

    } catch (error) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(
            error
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );

    } finally {

      if (mounted) {

        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    if (_loading) {

      return const Scaffold(
        body:
            Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    final r =
        _references;

    if (r == null) {

      return const Scaffold(
        body:
            Center(
          child:
              Text(
            'Impossible de charger les données.',
          ),
        ),
      );
    }

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F5F5),

      appBar:
          AppBar(
        backgroundColor:
            const Color(0xFF111111),
        foregroundColor:
            Colors.white,
        title:
            const Text(
          'Nouvelle mission',
          style:
              TextStyle(
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),

      body:
          Form(
        key: _formKey,
        child:
            ListView(
          padding:
              const EdgeInsets.all(
            16,
          ),
          children: [

            // ====================================================
            // SITE
            // ====================================================

            Autocomplete<CompanySite>(
              displayStringForOption:
                  (site) => site.name,

              optionsBuilder:
                  (TextEditingValue value) {
                final query =
                    value.text.trim().toLowerCase();

                if (query.isEmpty) {
                  return _sites;
                }

                return _sites.where((site) {
                  final name =
                      site.name.toLowerCase();

                  final reference =
                      site.siteReference
                              ?.toLowerCase() ??
                          '';

                  final address =
                      site.addressLine1
                          .toLowerCase();

                  final city =
                      site.city.toLowerCase();

                  return name.contains(query) ||
                      reference.contains(query) ||
                      address.contains(query) ||
                      city.contains(query);
                });
              },

              onSelected:
                  _selectSite,

              fieldViewBuilder:
                  (
                    context,
                    controller,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                if (_siteSearch.isNotEmpty &&
                    controller.text.isEmpty) {
                  controller.text =
                      _siteSearch;
                }

                return TextFormField(
                  controller:
                      controller,
                  focusNode:
                      focusNode,
                  decoration:
                      InputDecoration(
                    labelText:
                        'Site',
                    hintText:
                        'Rechercher un site...',
                    prefixIcon:
                        const Icon(
                      Icons.location_on_outlined,
                    ),
                    suffixIcon:
                        _selectedSite != null
                            ? IconButton(
                                icon:
                                    const Icon(
                                  Icons.clear,
                                ),
                                onPressed: () {
                                  controller.clear();

                                  setState(() {
                                    _selectedSite =
                                        null;
                                    _siteSearch = '';
                                  });
                                },
                              )
                            : null,
                    border:
                        const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _siteSearch = value;

                    if (_selectedSite != null &&
                        value !=
                            _selectedSite!.name) {
                      setState(() {
                        _selectedSite = null;
                      });
                    }
                  },
                );
              },

              optionsViewBuilder:
                  (
                    context,
                    onSelected,
                    options,
                  ) {
                return Align(
                  alignment:
                      Alignment.topLeft,
                  child: Material(
                    elevation: 4,
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(
                        maxHeight: 300,
                      ),
                      child: ListView.builder(
                        padding:
                            EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount:
                            options.length,
                        itemBuilder:
                            (context, index) {
                          final site =
                              options.elementAt(
                            index,
                          );

                          return ListTile(
                            leading:
                                const Icon(
                              Icons.location_on_outlined,
                            ),
                            title:
                                Text(
                              site.name,
                            ),
                            subtitle:
                                Text(
                              '${site.addressLine1}, '
                              '${site.postalCode} '
                              '${site.city}',
                            ),
                            onTap: () =>
                                onSelected(
                              site,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),

            if (_selectedSite != null) ...[
              const SizedBox(height: 8),

              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Site sélectionné : '
                          '${_selectedSite!.name}',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            TextFormField(
              controller:
                  _title,
              decoration:
                  const InputDecoration(
                labelText:
                    'Titre *',
                border:
                    OutlineInputBorder(),
              ),
              validator:
                  (value) =>
                      value == null ||
                              value.trim().isEmpty
                          ? 'Titre obligatoire'
                          : null,
            ),

            const SizedBox(
              height: 12,
            ),

            TextFormField(
              controller:
                  _reference,
              decoration:
                  const InputDecoration(
                labelText:
                    'Référence',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            _clientSelector(
              clients: r.clients,
            ),

            const SizedBox(
              height: 12,
            ),

            _dropdown(
              label: 'Pilote *',
              value: _pilotId,
              items: r.pilots,
              labelBuilder:
                  (item) {

                final name =
                    '${item['firstname'] ?? ''} '
                    '${item['lastname'] ?? ''}'
                    .trim();

                return name.isEmpty
                    ? item['email']
                          ?.toString() ??
                        ''
                    : name;
              },
              valueBuilder:
                  (item) =>
                      item['id']
                          ?.toString() ??
                      '',
              onChanged:
                  (value) =>
                      setState(
                () {
                  _pilotId =
                      value;
                },
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            _dropdown(
              label:
                  'Catégorie *',
              value:
                  _categoryId,
              items:
                  r.categories,
              labelBuilder:
                  (item) =>
                      item['label']
                          ?.toString() ??
                      '',
              valueBuilder:
                  (item) =>
                      item['id']
                          ?.toString() ??
                      '',
              onChanged:
                  _selectCategory,
            ),

            const SizedBox(
              height: 12,
            ),

            _dropdown(
              label:
                  'Statut',
              value:
                  _statusId,
              items:
                  r.statuses,
              labelBuilder:
                  (item) =>
                      item['label']
                          ?.toString() ??
                      '',
              valueBuilder:
                  (item) =>
                      item['id']
                          ?.toString() ??
                      '',
              onChanged:
                  (value) =>
                      setState(
                () {
                  _statusId =
                      value;
                },
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            const Text(
              'Intervention',
              style:
                  TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            _dropdown(
              label:
                  'Drone *',
              value:
                  _droneId,
              items:
                  r.drones,
              labelBuilder:
                  (item) {

                final nickname =
                    item['nickname']
                            ?.toString()
                            .trim() ??
                        '';

                final model =
                    '${item['manufacturer'] ?? ''} '
                    '${item['model'] ?? ''}'
                    .trim();

                final serial =
                    item['serial_number']
                            ?.toString() ??
                        '';

                if (nickname.isNotEmpty) {
                  return '$nickname — $model';
                }

                return '$model — $serial';
              },
              valueBuilder:
                  (item) =>
                      item['id']
                          ?.toString() ??
                      '',
              onChanged:
                  (value) =>
                      setState(
                () {
                  _droneId =
                      value;
                },
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            _dropdown(
              label:
                  'Préfecture *',
              value:
                  _prefectureId,
              items:
                  r.prefectures,
              labelBuilder:
                  (item) {

                final name =
                    item['name']
                            ?.toString() ??
                        '';

                final code =
                    item['code']
                            ?.toString() ??
                        '';

                return code.isEmpty
                    ? name
                    : '$code — $name';
              },
              valueBuilder:
                  (item) =>
                      item['id']
                          ?.toString() ??
                      '',
              onChanged:
                  (value) =>
                      setState(
                () {
                  _prefectureId =
                      value;
                },
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            TextFormField(
              controller:
                  _address,
              decoration:
                  const InputDecoration(
                labelText:
                    'Adresse *',
                border:
                    OutlineInputBorder(),
              ),
              validator:
                  (value) =>
                      value == null ||
                              value.trim().isEmpty
                          ? 'Adresse obligatoire'
                          : null,
            ),

            const SizedBox(
              height: 12,
            ),

            TextFormField(
              controller:
                  _address2,
              decoration:
                  const InputDecoration(
                labelText:
                    'Complément d’adresse',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Row(
              children: [

                Expanded(
                  child:
                      TextFormField(
                    controller:
                        _postalCode,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Code postal *',
                      border:
                          OutlineInputBorder(),
                    ),
                    validator:
                        (value) =>
                            value == null ||
                                    value.trim().isEmpty
                                ? 'Obligatoire'
                                : null,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  flex: 2,
                  child:
                      TextFormField(
                    controller:
                        _city,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Ville *',
                      border:
                          OutlineInputBorder(),
                    ),
                    validator:
                        (value) =>
                            value == null ||
                                    value.trim().isEmpty
                                ? 'Obligatoire'
                                : null,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 16,
            ),

            OutlinedButton.icon(
              onPressed: () async {

                final selected =
                    await showDatePicker(
                  context:
                      context,
                  firstDate:
                      DateTime.now()
                          .subtract(
                    const Duration(
                      days: 1,
                    ),
                  ),
                  lastDate:
                      DateTime.now()
                          .add(
                    const Duration(
                      days: 3650,
                    ),
                  ),
                  initialDate:
                      _plannedAt ??
                      DateTime.now(),
                );

                if (selected != null &&
                    mounted) {

                  setState(() {

                    _plannedAt =
                        DateTime(
                      selected.year,
                      selected.month,
                      selected.day,
                      9,
                    );
                  });
                }
              },
              icon:
                  const Icon(
                Icons.calendar_today,
              ),
              label:
                  Text(
                _plannedAt == null
                    ? 'Date prévue'
                    : 'Prévue le '
                        '${_plannedAt!.day.toString().padLeft(2, '0')}/'
                        '${_plannedAt!.month.toString().padLeft(2, '0')}/'
                        '${_plannedAt!.year}',
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            FilledButton.icon(
              onPressed:
                  _saving
                      ? null
                      : _save,
              icon:
                  _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2,
                          ),
                        )
                      : const Icon(
                          Icons.save_outlined,
                        ),
              label:
                  Text(
                _saving
                    ? 'Enregistrement...'
                    : 'Créer la mission',
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _clientSelector({
    required List<Map<String, dynamic>> clients,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: _clientId,
      decoration: const InputDecoration(
        labelText: 'Client *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person_outline),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: '__NEW_CLIENT__',
          child: Row(
            children: [
              Icon(Icons.person_add_outlined),
              SizedBox(width: 10),
              Text('Ajouter nouveau client'),
            ],
          ),
        ),
        ...clients.map(
          (item) {
            final id =
                item['id']?.toString() ?? '';
            final name =
                item['name']?.toString() ?? '';

            return DropdownMenuItem<String>(
              value: id,
              child: Text(name),
            );
          },
        ),
      ],
      onChanged: (value) {
        if (value == '__NEW_CLIENT__') {
          _addNewClient();
          return;
        }

        setState(() {
          _clientId = value;
        });
      },
      validator: (value) {
        if (_clientId == null ||
            _clientId!.isEmpty) {
          return 'Client obligatoire';
        }
        return null;
      },
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<Map<String, dynamic>>
        items,
    required String Function(
      Map<String, dynamic>,
    ) labelBuilder,
    required String Function(
      Map<String, dynamic>,
    ) valueBuilder,
    required ValueChanged<String?>
        onChanged,
  }) {

    return DropdownButtonFormField<String>(
      initialValue:
          items.any(
        (item) =>
            valueBuilder(item) ==
            value,
      )
          ? value
          : null,
      decoration:
          InputDecoration(
        labelText:
            label,
        border:
            const OutlineInputBorder(),
      ),
      items:
          items
              .map(
                (item) =>
                    DropdownMenuItem<String>(
                  value:
                      valueBuilder(item),
                  child:
                      Text(
                    labelBuilder(item),
                    overflow:
                        TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
      onChanged:
          onChanged,
    );
  }
}


// ==================================================================
// DETAIL
// ==================================================================

class MissionDetailsPage
    extends StatefulWidget {

  const MissionDetailsPage({
    super.key,
    required this.mission,
  });

  final Mission mission;

  @override
  State<MissionDetailsPage> createState() =>
      _MissionDetailsPageState();
}

class _MissionDetailsPageState
    extends State<MissionDetailsPage> {

  late Mission _mission;

  @override
  void initState() {

    super.initState();

    _mission =
        widget.mission;
  }

  Future<void> _archive() async {

    try {

      await MissionsService.archive(
        _mission.id,
      );

      if (!mounted) return;

      final updated =
          await MissionsService.getMission(
        _mission.id,
      );

      setState(() {
        _mission = updated;
      });

    } catch (error) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(
            error
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    }
  }

  Future<void> _delete() async {

    final confirm =
        await showDialog<bool>(
      context: context,
      builder:
          (context) =>
              AlertDialog(
        title:
            const Text(
          'Supprimer la mission ?',
        ),
        content:
            const Text(
          'La mission sera supprimée de l’application par suppression logique.',
        ),
        actions: [

          TextButton(
            onPressed:
                () =>
                    Navigator.pop(
              context,
              false,
            ),
            child:
                const Text(
              'Annuler',
            ),
          ),

          FilledButton(
            onPressed:
                () =>
                    Navigator.pop(
              context,
              true,
            ),
            child:
                const Text(
              'Supprimer',
            ),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    try {

      await MissionsService
          .deleteMission(
        _mission.id,
      );

      if (!mounted) return;

      Navigator.of(context).pop();

    } catch (error) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(
            error
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF5F5F5),

      appBar:
          AppBar(
        backgroundColor:
            const Color(0xFF111111),
        foregroundColor:
            Colors.white,
        title:
            const Text(
          'Mission',
          style:
              TextStyle(
            fontWeight:
                FontWeight.w800,
          ),
        ),
        actions: [

          IconButton(
            tooltip:
                _mission.isArchived
                    ? 'Désarchiver'
                    : 'Archiver',
            onPressed:
                _archive,
            icon:
                Icon(
              _mission.isArchived
                  ? Icons.unarchive_outlined
                  : Icons.archive_outlined,
            ),
          ),

          IconButton(
            tooltip:
                'Supprimer',
            onPressed:
                _delete,
            icon:
                const Icon(
              Icons.delete_outline,
            ),
          ),
        ],
      ),

      body:
          ListView(
        padding:
            const EdgeInsets.all(
          16,
        ),
        children: [

          _infoCard(
            'Mission',
            [
              _row(
                'Titre',
                _mission.title,
              ),
              if (_mission.reference != null)
                _row(
                  'Référence',
                  _mission.reference!,
                ),
              _row(
                'Statut',
                _mission.statusLabel,
              ),
              _row(
                'Catégorie',
                _mission.categoryLabel,
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          _infoCard(
            'Client',
            [
              _row(
                'Client',
                _mission.clientName,
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          _infoCard(
            'Pilote',
            [
              _row(
                'Pilote',
                _mission.pilotName,
              ),
              _row(
                'E-mail',
                _mission.pilotEmail,
              ),
            ],
          ),

          if (_mission.plannedAt != null) ...[

            const SizedBox(
              height: 12,
            ),

            _infoCard(
              'Planification',
              [
                _row(
                  'Prévue',
                  _formatDate(
                    _mission.plannedAt!,
                  ),
                ),
              ],
            ),
          ],

          if (_mission.description != null &&
              _mission.description!
                  .trim()
                  .isNotEmpty) ...[

            const SizedBox(
              height: 12,
            ),

            _infoCard(
              'Description',
              [
                Text(
                  _mission.description!,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoCard(
    String title,
    List<Widget> children,
  ) {

    return Card(
      elevation: 0,
      child:
          Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child:
            Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Text(
              title,
              style:
                  const TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(
    String label,
    String value,
  ) {

    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 8,
      ),
      child:
          Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          SizedBox(
            width: 110,
            child:
                Text(
              label,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child:
                Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(
    DateTime date,
  ) {

    final d =
        date.toLocal();

    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year} à '
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }
}
