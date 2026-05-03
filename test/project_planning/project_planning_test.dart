import 'package:flutter_test/flutter_test.dart';
import 'package:artisanarc/features/project/data/project_model.dart';
import 'package:artisanarc/features/project/domain/entities/supply_need.dart';

void main() {
  group('ProjectPlanning', () {
    test('create a new project', () {
      final project = Project(
        id: '1',
        name: 'New Collection',
        description: 'A collection of summer wear.',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        milestones: [],
        supplyNeeds: [],
        createdAt: DateTime.now(),
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
        endDate: DateTime.now().add(const Duration(days: 30)),
        milestones: [],
        supplyNeeds: [],
        createdAt: DateTime.now(),
      );
      final milestone = Milestone(
        id: 'm1',
        name: 'Design Phase',
        description: 'Complete all design work.',
        dueDate: DateTime.now().add(const Duration(days: 7)),
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
        endDate: DateTime.now().add(const Duration(days: 30)),
        milestones: [],
        supplyNeeds: [],
        createdAt: DateTime.now(),
      );
      final supplyNeed = SupplyNeed(
        id: 's1',
        itemName: 'Cotton Fabric',
        quantityNeeded: 100,
        unit: 'meters',
        isSourced: false,
      );
      project.supplyNeeds.add(supplyNeed);
      expect(project.supplyNeeds, isNotEmpty);
      expect(project.supplyNeeds.first.itemName, 'Cotton Fabric');
    });
  });
}
