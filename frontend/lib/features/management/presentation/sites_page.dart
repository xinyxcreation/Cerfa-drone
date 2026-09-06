import 'package:flutter/material.dart';

import '../../missions/models/mission.dart';
import '../../missions/services/missions_service.dart';
import '../models/company_client.dart';
import '../models/company_site.dart';
import '../services/clients_service.dart';
import '../services/sites_service.dart';

class SitesPage extends StatefulWidget {
  const SitesPage({super.key});

  @override
  State<SitesPage> createState() => _SitesPageState();
}

class _SitesPageState extends State<SitesPage> {
  late Future<List<CompanySite>> _sitesFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _sitesFuture = SitesService.getSites();
  }

  Future<void> _refresh() async {
    setState(_load);
    try {
      await _sitesFuture;
    } catch (_) {}
  }

  Future<void> _addSite() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const _CreateSitePage(),
      ),
    );

    if (created == true && mounted) {
      setState(_load);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: const Text(
          'Sites',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Ajouter',
            onPressed: _addSite,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<CompanySite>>(
        future: _sitesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error
                              ?.toString()
                              .replaceFirst('Exception: ', '') ??
                          'Impossible de charger les sites.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => setState(_load),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          final sites = snapshot.data ?? [];

          if (sites.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 140),
                  Icon(
                    Icons.location_on_outlined,
                    size: 64,
                    color: Color(0xFF777777),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Aucun site enregistré',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Ajoutez votre premier site d’intervention.',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: sites.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final site = sites[index];

                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E4),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFFE30613),
                      ),
                    ),
                    title: Text(
                      site.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (site.clientName != null)
                            Text('Client : ${site.clientName}'),
                          Text(
                            '${site.addressLine1}, '
                            '${site.postalCode} ${site.city}',
                          ),
                          if (site.prefectureName != null)
                            Text(
                              'Préfecture : ${site.prefectureName}',
                            ),
                          if (site.categoryLabel != null)
                            Text(
                              'Catégorie : ${site.categoryLabel}',
                            ),
                        ],
                      ),
                    ),
                    trailing: IconButton(
                      tooltip: 'Modifier',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () async {
                        final updated =
                            await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => _CreateSitePage(site: site),
                          ),
                        );

                        if (updated == true && mounted) {
                          setState(_load);
                        }
                      },
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
}
class _CreateSitePage extends StatefulWidget {
  const _CreateSitePage({
    this.site,
  });

  final CompanySite? site;

  @override
  State<_CreateSitePage> createState() => _CreateSitePageState();
}

class _CreateSitePageState extends State<_CreateSitePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _referenceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _address2Controller = TextEditingController();
  final _postalController = TextEditingController();
  final _cityController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _notesController = TextEditingController();

  List<CompanyClient> _clients = [];
  List<Map<String, dynamic>> _prefectures = [];

  CompanyClient? _client;
  Map<String, dynamic>? _prefecture;

  bool _loading = true;
  bool _saving = false;
  bool _favorite = false;

  @override
  void initState() {
    super.initState();

    final site = widget.site;

    if (site != null) {
      _nameController.text = site.name;
      _referenceController.text = site.siteReference ?? '';
      _descriptionController.text = site.description ?? '';
      _addressController.text = site.addressLine1;
      _address2Controller.text = site.addressLine2 ?? '';
      _postalController.text = site.postalCode;
      _cityController.text = site.city;
      _latitudeController.text =
          site.latitude?.toString() ?? '';
      _longitudeController.text =
          site.longitude?.toString() ?? '';
      _notesController.text = site.notes ?? '';
      _favorite = site.isFavorite;
    }

    _loadReferences();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _referenceController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _address2Controller.dispose();
    _postalController.dispose();
    _cityController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadReferences() async {
    try {
      final results = await Future.wait([
        ClientsService.getClients(),
              MissionsService.getReferences(),
      ]);

      final references = results[1] as MissionReferenceData;

      if (!mounted) return;

      final clients =
          results[0] as List<CompanyClient>;

      CompanyClient? selectedClient;
      Map<String, dynamic>? selectedPrefecture;

      final site = widget.site;

      if (site != null) {
        for (final client in clients) {
          if (client.id == site.clientId) {
            selectedClient = client;
            break;
          }
        }

        for (final prefecture in references.prefectures) {
          if (prefecture['id']?.toString() ==
              site.prefectureId) {
            selectedPrefecture = prefecture;
            break;
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _clients = clients;
        _prefectures = references.prefectures;
        _client = selectedClient;
        _prefecture = selectedPrefecture;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _createClient() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    final result =
        await showDialog<CompanyClient>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nouveau client'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Nom du client *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                final name =
                    nameController.text.trim();

                if (name.isEmpty) return;

                try {
                  final client =
                      await ClientsService.createClient(
                    name: name,
                    email: emailController.text
                            .trim()
                            .isEmpty
                        ? null
                        : emailController.text.trim(),
                    phone: phoneController.text
                            .trim()
                            .isEmpty
                        ? null
                        : phoneController.text.trim(),
                  );

                  if (context.mounted) {
                    Navigator.pop(
                      context,
                      client,
                    );
                  }
                } catch (e) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        e.toString().replaceFirst(
                          'Exception: ',
                          '',
                        ),
                      ),
                    ),
                  );
                }
              },
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    if (result == null || !mounted) return;

    setState(() {
      _clients = [..._clients, result];
      _client = result;
    });
  }
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    double? latitude;
    double? longitude;

    if (_latitudeController.text.trim().isNotEmpty) {
      latitude =
          double.tryParse(
        _latitudeController.text.trim()
            .replaceAll(',', '.'),
      );

      if (latitude == null) {
        _showError('Latitude invalide.');
        return;
      }
    }

    if (_longitudeController.text.trim().isNotEmpty) {
      longitude =
          double.tryParse(
        _longitudeController.text.trim()
            .replaceAll(',', '.'),
      );

      if (longitude == null) {
        _showError('Longitude invalide.');
        return;
      }
    }

    setState(() => _saving = true);

    try {
      final site = widget.site;

      final siteReference =
          _referenceController.text.trim().isEmpty
              ? null
              : _referenceController.text.trim();

      final description =
          _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim();

      final addressLine2 =
          _address2Controller.text.trim().isEmpty
              ? null
              : _address2Controller.text.trim();

      final notes =
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim();

      if (site == null) {
        await SitesService.createSite(
          name: _nameController.text.trim(),
          siteReference: siteReference,
          description: description,
          clientId: _client?.id,
          addressLine1: _addressController.text.trim(),
          addressLine2: addressLine2,
          postalCode: _postalController.text.trim(),
          city: _cityController.text.trim(),
          latitude: latitude,
          longitude: longitude,
          prefectureId:
              _prefecture?['id']?.toString(),
          isFavorite: _favorite,
          notes: notes,
        );
      } else {
        await SitesService.updateSite(
          siteId: site.id,
          name: _nameController.text.trim(),
          siteReference: siteReference,
          description: description,
          clientId: _client?.id,
          addressLine1: _addressController.text.trim(),
          addressLine2: addressLine2,
          postalCode: _postalController.text.trim(),
          city: _cityController.text.trim(),
          latitude: latitude,
          longitude: longitude,
          prefectureId:
              _prefecture?['id']?.toString(),
          isFavorite: _favorite,
          notes: notes,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() => _saving = false);

      _showError(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    );
  }

  String _prefectureLabel(
    Map<String, dynamic> prefecture,
  ) {
    final name =
        prefecture['prefecture_name']?.toString();

    final code =
        prefecture['code']?.toString();

    if (name != null && name.isNotEmpty) {
      if (code != null && code.isNotEmpty) {
        return '$code — $name';
      }
      return name;
    }

    return prefecture['city']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: Text(
          widget.site == null
              ? 'Nouveau site'
              : 'Modifier le site',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  30,
                ),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration:
                        _decoration('Nom du site'),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Le nom du site est obligatoire.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _referenceController,
                    decoration: _decoration(
                      'Référence du site',
                    ),
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<
                      CompanyClient>(
                    initialValue: _client,
                    decoration:
                        _decoration('Client'),
                    items: [
                      const DropdownMenuItem<
                          CompanyClient>(
                        value: null,
                        child:
                            Text('Aucun client'),
                      ),
                      ..._clients.map(
                        (client) =>
                            DropdownMenuItem(
                          value: client,
                          child: Text(
                            client.name,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(
                        () => _client = value,
                      );
                    },
                  ),

                  Align(
                    alignment:
                        Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _createClient,
                      icon: const Icon(
                        Icons.person_add_outlined,
                      ),
                      label: const Text(
                        'Ajouter nouveau client',
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  const SizedBox(height: 20),

                  const Text(
                    'Adresse du site',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _addressController,
                    decoration:
                        _decoration('Adresse'),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'L’adresse est obligatoire.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _address2Controller,
                    decoration:
                        _decoration('Complément'),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _postalController,
                    decoration:
                        _decoration('Code postal'),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Le code postal est obligatoire.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _cityController,
                    decoration:
                        _decoration('Ville'),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'La ville est obligatoire.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  DropdownButtonFormField<
                      Map<String, dynamic>>(
                    initialValue: _prefecture,
                    decoration: _decoration(
                      'Préfecture',
                    ),
                    items: [
                      const DropdownMenuItem<
                          Map<String, dynamic>>(
                        value: null,
                        child: Text(
                          'Aucune préfecture',
                        ),
                      ),
                      ..._prefectures.map(
                        (prefecture) =>
                            DropdownMenuItem(
                          value: prefecture,
                          child: Text(
                            _prefectureLabel(
                              prefecture,
                            ),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(
                        () => _prefecture = value,
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Coordonnées GPS',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller:
                              _latitudeController,
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration:
                              _decoration(
                            'Latitude',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller:
                              _longitudeController,
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration:
                              _decoration(
                            'Longitude',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  SwitchListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    title: Text(
                      'Site favori',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    subtitle: Text(
                      'Mettre ce site en évidence',
                    ),
                    value: _favorite,
                    onChanged: (value) {
                      setState(
                        () => _favorite = value,
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller:
                        _descriptionController,
                    maxLines: 3,
                    decoration: _decoration(
                      'Description',
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration:
                        _decoration('Notes'),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 50,
                    child: FilledButton.icon(
                      onPressed:
                          _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.save_outlined,
                            ),
                      label: Text(
                        _saving
                            ? 'Enregistrement...'
                            : widget.site == null
                                ? 'Créer le site'
                                : 'Enregistrer les modifications',
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
