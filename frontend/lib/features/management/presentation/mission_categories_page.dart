import 'package:flutter/material.dart';

import '../models/company_drone.dart';
import '../models/mission_category.dart';
import '../services/drones_service.dart';
import '../services/mission_categories_service.dart';

class MissionCategoriesPage extends StatefulWidget {
  const MissionCategoriesPage({super.key});

  @override
  State<MissionCategoriesPage> createState() =>
      _MissionCategoriesPageState();
}

class _MissionCategoriesPageState
    extends State<MissionCategoriesPage> {
  bool _loading = true;
  String? _error;

  List<MissionCategory> _categories = [];
  List<CompanyDrone> _drones = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        MissionCategoriesService.getCategories(),
        DronesService.getDrones(),
      ]);

      if (!mounted) return;

      setState(() {
        _categories =
            results[0] as List<MissionCategory>;

        _drones =
            (results[1] as List<CompanyDrone>)
                .where((drone) => drone.isActive)
                .toList();

        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openCategoryDialog({
    MissionCategory? category,
  }) async {
    final codeController =
        TextEditingController(
      text: category?.code ?? '',
    );

    final labelController =
        TextEditingController(
      text: category?.label ?? '',
    );

    final descriptionController =
        TextEditingController(
      text: category?.description ?? '',
    );

    final isEditing = category != null;

    String? selectedDroneId =
        category?.defaultDroneId;

    if (selectedDroneId != null &&
        !_drones.any(
          (drone) => drone.id == selectedDroneId,
        )) {
      selectedDroneId = null;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool saving = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing
                    ? 'Modifier la catégorie'
                    : 'Nouvelle catégorie',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: codeController,
                      decoration:
                          const InputDecoration(
                        labelText: 'Code',
                        hintText: 'inspection',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: labelController,
                      decoration:
                          const InputDecoration(
                        labelText: 'Nom',
                        hintText: 'Inspection',
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String?>(
                      initialValue: selectedDroneId,
                      decoration:
                          const InputDecoration(
                        labelText: 'Drone par défaut',
                        prefixIcon:
                            Icon(Icons.flight),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            'Aucun drone par défaut',
                          ),
                        ),
                        ..._drones.map(
                          (drone) =>
                              DropdownMenuItem<String?>(
                            value: drone.id,
                            child: Text(
                              drone.displayName,
                            ),
                          ),
                        ),
                      ],
                      onChanged: saving
                          ? null
                          : (value) {
                              setDialogState(() {
                                selectedDroneId =
                                    value;
                              });
                            },
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller:
                          descriptionController,
                      maxLines: 4,
                      decoration:
                          const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving
                      ? null
                      : () => Navigator.pop(
                            dialogContext,
                            false,
                          ),
                  child:
                      const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final code =
                              codeController.text
                                  .trim();

                          final label =
                              labelController.text
                                  .trim();

                          if (code.isEmpty ||
                              label.isEmpty) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Le code et le nom sont obligatoires.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(
                            () => saving = true,
                          );

                          try {
                            final description =
                                descriptionController
                                    .text
                                    .trim();

                            if (isEditing) {
                              await MissionCategoriesService
                                  .updateCategory(
                                categoryId:
                                    category.id,
                                code: code,
                                label: label,
                                description:
                                    description
                                            .isEmpty
                                        ? null
                                        : description,
                                sortOrder:
                                    category.sortOrder,
                                defaultDroneId:
                                    selectedDroneId,
                              );
                            } else {
                              await MissionCategoriesService
                                  .createCategory(
                                code: code,
                                label: label,
                                description:
                                    description
                                            .isEmpty
                                        ? null
                                        : description,
                                defaultDroneId:
                                    selectedDroneId,
                              );
                            }

                            if (dialogContext.mounted) {
                              Navigator.pop(
                                dialogContext,
                                true,
                              );
                            }
                          } catch (error) {
                            if (!context.mounted) {
                              return;
                            }

                            setDialogState(
                              () => saving = false,
                            );

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              SnackBar(
                                content: Text(
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
                        },
                  child: Text(
                    saving
                        ? 'Enregistrement...'
                        : isEditing
                            ? 'Enregistrer'
                            : 'Créer',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    codeController.dispose();
    labelController.dispose();
    descriptionController.dispose();

    if (result == true) {
      _load();
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
          'Catégories',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Ajouter',
            onPressed: _openCategoryDialog,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _load,
                child:
                    const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Text(
          'Aucune catégorie.\nAjoutez votre première catégorie.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding:
            const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          100,
        ),
        itemCount: _categories.length,
        separatorBuilder: (_, _) =>
            const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final category =
              _categories[index];

          final droneName =
              category.defaultDroneName;

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(
                  Icons.category_outlined,
                ),
              ),
              title: Text(
                category.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                '${category.code}\n'
                '${category.description ?? 'Aucune description'}\n'
                'Drone par défaut : '
                '${droneName ?? 'Aucun'}',
              ),
              isThreeLine: true,
              trailing: IconButton(
                tooltip: 'Modifier',
                icon: const Icon(
                  Icons.edit_outlined,
                ),
                onPressed: () =>
                    _openCategoryDialog(
                  category: category,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
