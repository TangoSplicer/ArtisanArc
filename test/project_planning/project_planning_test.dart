import 'package:flutter_test/flutter_test.dart';
import 'package:artisanarc/features/project_planning/domain/entities/project.dart';
import 'package:artisanarc/features/project_planning/domain/entities/milestone.dart';
import 'package:artisanarc/features/project_planning/domain/entities/supply_need.dart';

void main() {
  group('ProjectPlanning', () {
    test('create a new project', () {
      final project = Project(
        id: '1',
        name: 'New Collection',
        description: 'A collection of summer wear.',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 30)),
        milestones: [],
        supplyNeeds: [],
      );
      expect(project.name, 'New Collection');
      expect(project.description, 'A collection of summer wear.');
      expect(project.milestones, isEmpty);
      expect(project.supplyNeeds, isEmpty);
    });

    test('add a milestone to a project', () {
      final project = Project(
        id: '1',
        name: 'New Collection',
        description: 'A collection of summer wear.',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 30)),
        milestones: [],
        supplyNeeds: [],
      );
      final milestone = Milestone(
        id: 'm1',
        name: 'Design Phase',
        description: 'Complete all design work.',
        dueDate: DateTime.now().add(Duration(days: 7)),
        isCompleted: false,
      );
      project.milestones.add(milestone);
      expect(project.milestones, isNotEmpty);
      expect(project.milestones.first.name, 'Design Phase');
    });

    test('add a supply need to a project', () {
      final project = Project(
        id: '1',
        name: 'New Collection',
        description: 'A collection of summer wear.',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: 30)),
        milestones: [],
        supplyNeeds: [],
      );
      final supplyNeed = SupplyNeed(
        id: 's1',
        itemName: 'Cotton Fabric',
        quantity: 100,
        unit: 'meters',
        supplier: 'Fabric Corp',
        estimatedCost: 500.0,
      );
      project.supplyNeeds.add(supplyNeed);
      expect(project.supplyNeeds, isNotEmpty);
      expect(project.supplyNeeds.first.itemName, 'Cotton Fabric');
    });
  });
}
