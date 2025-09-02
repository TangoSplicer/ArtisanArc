import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // For navigation

// Assuming these use cases exist and are registered with GetIt
import 'package:artisanarc/features/project/domain/usecases/create_project.dart';
import 'package:artisanarc/features/project/domain/usecases/get_project_by_id.dart';
import 'package:artisanarc/features/project/domain/usecases/update_project.dart';
import 'package:artisanarc/features/project/data/project_model.dart'; // Use data model instead
import 'package:artisanarc/features/project/domain/entities/supply_need.dart'; // Import SupplyNeed


class ProjectPlannerScreen extends StatefulWidget {
  final String? projectId; // Nullable for add mode

  const ProjectPlannerScreen({super.key, this.projectId});

  @override
  State<ProjectPlannerScreen> createState() => _ProjectPlannerScreenState();
}

class _ProjectPlannerScreenState extends State<ProjectPlannerScreen> {
  // Use cases from GetIt
  late final CreateProject _createProjectUseCase;
  late final GetProjectById _getProjectByIdUseCase;
  late final UpdateProject _updateProjectUseCase;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController(); // Added description
  final _craftController = TextEditingController(); // Will be replaced or improved

  DateTime _startDate = DateTime.now();
  DateTime? _endDate; // Nullable

  List<Milestone> _milestones = [];
  List<SupplyNeed> _supplyNeeds = []; // Added SupplyNeeds list

  bool _isLoading = false;
  bool get _isEditMode => widget.projectId != null;
  Project? _editingProject; // Stores the original project being edited

  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    // Initialize use cases - ensuring GetIt is configured before this screen is reached
    _createProjectUseCase = GetIt.I<CreateProject>();
    _getProjectByIdUseCase = GetIt.I<GetProjectById>();
    _updateProjectUseCase = GetIt.I<UpdateProject>();

    if (_isEditMode) {
      _loadProjectDetails();
    }
  }

  Future<void> _loadProjectDetails() async {
    setState(() => _isLoading = true);
    try {
      final project = await _getProjectByIdUseCase(widget.projectId!);
      if (project != null) {
        _editingProject = project;
        _nameController.text = project.name;
        _descriptionController.text = project.description ?? '';
        _craftController.text = project.craftType ?? ''; // Assuming craftType is a simple string for now
        _startDate = project.startDate ?? DateTime.now();
        _endDate = project.endDate;
        // Milestones need to be mutable for completion status, so create new instances
        _milestones = project.milestones.map((m) => Milestone( // Ensure Milestone class has these fields
          id: m.id, // Make sure Milestone class has id
          name: m.name,
          description: m.description, // Make sure Milestone class has description
          dueDate: m.dueDate,
          isCompleted: m.isCompleted,
        )).toList();
        _supplyNeeds = List<SupplyNeed>.from(project.supplyNeeds.map((s) => s.copyWith())); // Deep copy
      } else {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Error: Project not found. Creating a new one.')),
          );
         }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading project: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _craftController.dispose();
    super.dispose();
  }

  void _addOrEditMilestone({Milestone? existingMilestone, int? index}) {
    final isEditingMilestone = existingMilestone != null;
    final nameController = TextEditingController(text: existingMilestone?.name);
    final descriptionController = TextEditingController(text: existingMilestone?.description);
    DateTime dueDate = existingMilestone?.dueDate ?? DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditingMilestone ? 'Edit Milestone' : 'Add Milestone'),
          content: StatefulBuilder( // Use StatefulBuilder for date picker update
            builder: (BuildContext context, StateSetter setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Milestone Name')),
                    TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description (Optional)')),
                    const SizedBox(height: 10),
                    ListTile(
                      title: Text('Due Date: ${DateFormat.yMMMd().format(dueDate)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: dueDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)), // Allow past for flexibility
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (picked != null && picked != dueDate) {
                          setStateDialog(() => dueDate = picked);
                        }
                      },
                    ),
                  ],
                ),
              );
            }),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final newMilestone = Milestone(
                    id: existingMilestone?.id ?? _uuid.v4(),
                    name: nameController.text,
                    description: descriptionController.text,
                    dueDate: dueDate,
                    isCompleted: existingMilestone?.isCompleted ?? false,
                  );
                  setState(() {
                    if (isEditingMilestone && index != null) {
                      _milestones[index] = newMilestone;
                    } else {
                      _milestones.add(newMilestone);
                    }
                  });
                }
                Navigator.pop(dialogContext);
              },
              child: Text(isEditingMilestone ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _toggleMilestoneCompletion(int index) {
    setState(() {
      _milestones[index] = _milestones[index].copyWith(isCompleted: !_milestones[index].isCompleted);
    });
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final projectData = Project(
      id: _isEditMode ? widget.projectId! : _uuid.v4(),
      name: _nameController.text,
      description: _descriptionController.text,
      craftType: _craftController.text, // This needs better handling (e.g., dropdown, tags)
      startDate: _startDate,
      endDate: _endDate,
      milestones: _milestones,
      supplyNeeds: _supplyNeeds, // Added supplyNeeds to save
      createdAt: _isEditMode ? _editingProject!.createdAt : DateTime.now(),
      lastUpdatedAt: DateTime.now(),
    );

    try {
      if (_isEditMode) {
        await _updateProjectUseCase(projectData);
      } else {
        await _createProjectUseCase(projectData);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Project ${projectData.name} saved successfully!')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving project: $e')),
        );
       }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: (isStartDate ? _startDate : _endDate) ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101));
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = _startDate; // Ensure end date is not before start date
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  bool _isCraftTypeNotEmptyForAI() {
    return _craftController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Project' : 'Add New Project'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          if (_craftController.text.isNotEmpty) // Show AI button only if craftType is set
            IconButton(
              icon: const Icon(Icons.lightbulb_outline),
              tooltip: 'Get AI Crafting Hints',
              onPressed: () {
                // Ensure craftType is URL safe or handle encoding if needed by router
                context.push('/ai-assistant/${Uri.encodeComponent(_craftController.text)}');
              },
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveProject,
            tooltip: 'Save Project',
          ),
        ],
      ),
      body: _isLoading && _isEditMode && _editingProject == null // Show loader only on initial edit load
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Project Name*', border: OutlineInputBorder()),
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a project name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                     TextFormField(
                      controller: _craftController,
                      decoration: const InputDecoration(
                        labelText: 'Craft Type (e.g., Knitting, Woodwork)',
                        border: OutlineInputBorder(),
                        // Suffix icon could also work for AI assistant, but AppBar is cleaner
                      ),
                      onChanged: (value) {
                        // Rebuild actions in AppBar if craft type becomes empty/non-empty
                        // This is a bit heavy, a dedicated ValueListenableBuilder for the button might be better
                        // For simplicity, we'll rely on next field interaction or save attempt to update AppBar if needed,
                        // or accept that the button might not appear/disappear instantly on typing.
                        // A more reactive way: make _craftController a ValueNotifier or use a Form field's onChanged
                        // to call setState for just the button's visibility if it were part of the body.
                        // For AppBar, it's trickier without a full rebuild or a custom AppBar.
                        // For now, let's ensure it appears if text is present on build/rebuild.
                        if((value.isNotEmpty && !_isCraftTypeNotEmptyForAI()) || (value.isEmpty && _isCraftTypeNotEmptyForAI())) {
                           setState(() {}); // Trigger rebuild to show/hide AI button
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: Text('Start Date: ${DateFormat.yMMMd().format(_startDate)}'),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectDate(context, true),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text('End Date: ${_endDate != null ? DateFormat.yMMMd().format(_endDate!) : 'Not set'}'),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () => _selectDate(context, false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildMilestonesSection(context, colorScheme),
                    const SizedBox(height: 24),
                    _buildSupplyNeedsSection(context, colorScheme), // Added Supply Needs Section
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt_outlined),
                      label: Text(_isEditMode ? 'Update Project' : 'Save Project'),
                      onPressed: _isLoading ? null : _saveProject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMilestonesSection(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Milestones', style: Theme.of(context).textTheme.titleLarge),
            TextButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add'),
              onPressed: () => _addOrEditMilestone(),
            ),
          ],
        ),
        const Divider(),
        if (_milestones.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: Text('No milestones added yet.')),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _milestones.length,
            itemBuilder: (context, index) {
              final milestone = _milestones[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  leading: IconButton(
                    icon: Icon(
                      milestone.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: milestone.isCompleted ? colorScheme.secondary : null,
                    ),
                    onPressed: () => _toggleMilestoneCompletion(index),
                  ),
                  title: Text(
                    milestone.name,
                    style: TextStyle(
                      decoration: milestone.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    'Due: ${DateFormat.yMMMd().format(milestone.dueDate)}\n${milestone.description ?? ''}',
                    style: TextStyle(
                      decoration: milestone.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _addOrEditMilestone(existingMilestone: milestone, index: index);
                      } else if (value == 'delete') {
                        setState(() => _milestones.removeAt(index));
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
                      const PopupMenuItem<String>(value: 'delete', child: ListTile(leading: Icon(Icons.delete), title: Text('Delete'))),
                    ],
                  ),
                  isThreeLine: (milestone.description ?? '').isNotEmpty,
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildSupplyNeedsSection(BuildContext context, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Supply Needs', style: Theme.of(context).textTheme.titleLarge),
            TextButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add'),
              onPressed: () => _addOrEditSupplyNeed(),
            ),
          ],
        ),
        const Divider(),
        if (_supplyNeeds.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: Text('No supply needs added yet.')),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _supplyNeeds.length,
            itemBuilder: (context, index) {
              final supply = _supplyNeeds[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  leading: IconButton(
                    icon: Icon(
                      supply.isSourced ? Icons.check_box : Icons.check_box_outline_blank,
                      color: supply.isSourced ? colorScheme.secondary : null,
                    ),
                    onPressed: () => _toggleSupplySourced(index),
                  ),
                  title: Text(supply.itemName, style: TextStyle(decoration: supply.isSourced ? TextDecoration.lineThrough : null)),
                  subtitle: Text(
                    'Needed: ${supply.quantityNeeded} ${supply.unit}',
                    style: TextStyle(decoration: supply.isSourced ? TextDecoration.lineThrough : null)
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _addOrEditSupplyNeed(existingSupplyNeed: supply, index: index);
                      } else if (value == 'delete') {
                        setState(() => _supplyNeeds.removeAt(index));
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
                      const PopupMenuItem<String>(value: 'delete', child: ListTile(leading: Icon(Icons.delete), title: Text('Delete'))),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _addOrEditSupplyNeed({SupplyNeed? existingSupplyNeed, int? index}) {
    final isEditingSupply = existingSupplyNeed != null;
    final itemNameController = TextEditingController(text: existingSupplyNeed?.itemName);
    final quantityController = TextEditingController(text: existingSupplyNeed?.quantityNeeded.toString());
    final unitController = TextEditingController(text: existingSupplyNeed?.unit);
    // TODO: Consider pre-defined units or a better UX for unit input

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditingSupply ? 'Edit Supply Need' : 'Add Supply Need'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: itemNameController, decoration: const InputDecoration(labelText: 'Item Name')),
                TextField(
                  controller: quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity Needed'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(controller: unitController, decoration: const InputDecoration(labelText: 'Unit (e.g., meters, pcs)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                final itemName = itemNameController.text;
                final quantity = double.tryParse(quantityController.text);
                final unit = unitController.text;

                if (itemName.isNotEmpty && quantity != null && quantity > 0 && unit.isNotEmpty) {
                  final newSupplyNeed = SupplyNeed(
                    id: existingSupplyNeed?.id ?? _uuid.v4(),
                    itemName: itemName,
                    quantityNeeded: quantity,
                    unit: unit,
                    isSourced: existingSupplyNeed?.isSourced ?? false,
                  );
                  setState(() {
                    if (isEditingSupply && index != null) {
                      _supplyNeeds[index] = newSupplyNeed;
                    } else {
                      _supplyNeeds.add(newSupplyNeed);
                    }
                  });
                  Navigator.pop(dialogContext);
                } else {
                  // Optional: Show a small error in the dialog if validation fails
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields correctly.'), backgroundColor: Colors.red),
                  );
                }
              },
              child: Text(isEditingSupply ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _toggleSupplySourced(int index) {
    setState(() {
      _supplyNeeds[index] = _supplyNeeds[index].copyWith(isSourced: !_supplyNeeds[index].isSourced);
    });
  }
}