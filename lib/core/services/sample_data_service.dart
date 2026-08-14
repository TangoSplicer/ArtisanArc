import 'package:hive/hive.dart';

import '../../features/business/data/sale_model.dart';
import '../../features/inventory/data/inventory_model.dart';
import '../../features/project/data/project_model.dart';
import '../../features/project/domain/entities/supply_need.dart';
import '../../features/shopping/data/shopping_list_model.dart';

/// Provides optional, clearly fictional starter content for first-time users.
/// It is only created when the user asks for it and can be removed in Settings.
class SampleDataService {
  static const _inventoryBox = 'inventoryBox';
  static const _salesBox = 'salesBox';
  static const _stallSessionsBox = 'stallSessionsBox';
  static const _projectsBox = 'projectsBox';
  static const _shoppingListsBox = 'shoppingListsBox';
  static const _complianceBox = 'complianceBox';

  static Future<bool> hasCraftData() async {
    final inventory = await Hive.openBox<InventoryItem>(_inventoryBox);
    final sales = await Hive.openBox<SaleRecord>(_salesBox);
    final sessions = await Hive.openBox(_stallSessionsBox);
    final projects = await Hive.openBox<Project>(_projectsBox);
    final shopping = await Hive.openBox<ShoppingList>(_shoppingListsBox);
    return inventory.isNotEmpty ||
        sales.isNotEmpty ||
        sessions.isNotEmpty ||
        projects.isNotEmpty ||
        shopping.isNotEmpty;
  }

  static Future<void> loadStarterData({bool replaceExisting = false}) async {
    if (await hasCraftData() && !replaceExisting) {
      throw StateError(
          'Existing craft data must be cleared or replaced first.');
    }

    final inventory = await Hive.openBox<InventoryItem>(_inventoryBox);
    final sales = await Hive.openBox<SaleRecord>(_salesBox);
    final sessions = await Hive.openBox(_stallSessionsBox);
    final projects = await Hive.openBox<Project>(_projectsBox);
    final shopping = await Hive.openBox<ShoppingList>(_shoppingListsBox);

    if (replaceExisting) {
      await Future.wait([
        inventory.clear(),
        sales.clear(),
        sessions.clear(),
        projects.clear(),
        shopping.clear()
      ]);
    }

    final now = DateTime.now();
    final inventoryItems = <InventoryItem>[
      InventoryItem(
          id: 'sample-finished-bee',
          name: 'Crochet Bee Keyring',
          category: 'Finished Crochet Makes',
          quantity: 9,
          price: 5.00,
          storageLocation: 'Display Shelf',
          lastUpdated: now,
          itemType: 'finished'),
      InventoryItem(
          id: 'sample-finished-basket',
          name: 'Chunky Crochet Basket',
          category: 'Finished Crochet Makes',
          quantity: 3,
          price: 18.00,
          storageLocation: 'Display Shelf',
          lastUpdated: now,
          itemType: 'finished'),
      InventoryItem(
          id: 'sample-finished-tote',
          name: 'Granny Square Tote Bag',
          category: 'Finished Crochet Makes',
          quantity: 3,
          price: 28.00,
          storageLocation: 'Display Shelf',
          lastUpdated: now,
          itemType: 'finished'),
      InventoryItem(
          id: 'sample-finished-cozy',
          name: 'Knitted Mug Cozy',
          category: 'Finished Knitted Makes',
          quantity: 6,
          price: 9.00,
          storageLocation: 'Display Shelf',
          lastUpdated: now,
          itemType: 'finished'),
      InventoryItem(
          id: 'sample-finished-headband',
          name: 'Ribbed Knit Headband',
          category: 'Finished Knitted Makes',
          quantity: 6,
          price: 14.00,
          storageLocation: 'Display Shelf',
          lastUpdated: now,
          itemType: 'finished'),
      InventoryItem(
          id: 'sample-yarn-cotton',
          name: 'DK Cotton Yarn — Sage',
          category: 'Yarn & Fibre',
          quantity: 10,
          price: 3.75,
          storageLocation: 'Yarn Shelf',
          lastUpdated: now,
          itemType: 'material',
          reorderPoint: 4),
      InventoryItem(
          id: 'sample-yarn-wool',
          name: 'Chunky Wool Yarn — Oatmeal',
          category: 'Yarn & Fibre',
          quantity: 6,
          price: 5.50,
          storageLocation: 'Yarn Basket',
          lastUpdated: now,
          itemType: 'material',
          reorderPoint: 3),
      InventoryItem(
          id: 'sample-hook-4mm',
          name: '4 mm Ergonomic Crochet Hook',
          category: 'Crochet Hooks',
          quantity: 2,
          price: 4.50,
          storageLocation: 'Hook Case',
          lastUpdated: now,
          itemType: 'material'),
      InventoryItem(
          id: 'sample-marker-set',
          name: 'Locking Stitch Marker Set',
          category: 'Stitch Markers & Counters',
          quantity: 1,
          price: 3.25,
          storageLocation: 'Notions Tin',
          lastUpdated: now,
          itemType: 'material'),
    ];

    final sampleProject = Project(
      id: 'sample-project-tote',
      name: 'Granny Square Market Tote',
      description:
          'A beginner-friendly crochet tote using cotton yarn. Sample project for learning the planner.',
      craftType: 'Crochet',
      startDate: now.subtract(const Duration(days: 3)),
      endDate: now.add(const Duration(days: 11)),
      milestones: [
        Milestone(
            id: 'sample-milestone-colours',
            name: 'Choose colour palette',
            description: 'Select three cotton yarn colours.',
            dueDate: now.add(const Duration(days: 1)),
            isCompleted: true),
        Milestone(
            id: 'sample-milestone-squares',
            name: 'Crochet 13 granny squares',
            description: 'Keep a consistent tension and block as you go.',
            dueDate: now.add(const Duration(days: 6))),
        Milestone(
            id: 'sample-milestone-assemble',
            name: 'Assemble, line and finish',
            dueDate: now.add(const Duration(days: 11))),
      ],
      supplyNeeds: [
        SupplyNeed(
          id: 'sample-supply-cotton',
          itemName: 'DK Cotton Yarn — Sage',
          quantityNeeded: 4,
          unit: 'ball',
          isSourced: true,
          inventoryItemId: 'sample-yarn-cotton',
          estimatedCostEach: 3.75,
        ),
        SupplyNeed(
          id: 'sample-supply-hook',
          itemName: '4 mm Ergonomic Crochet Hook',
          quantityNeeded: 1,
          unit: 'piece',
          isSourced: true,
          inventoryItemId: 'sample-hook-4mm',
          estimatedCostEach: 4.50,
          isConsumable: false,
        ),
      ],
      createdAt: now.subtract(const Duration(days: 3)),
      lastUpdatedAt: now,
    );

    final eventName = 'Spring Makers Market';
    final eventLocation = 'Table 12 · Town Hall';
    final sampleSales = <SaleRecord>[
      SaleRecord(
          id: 'sample-sale-bee',
          itemId: 'sample-finished-bee',
          quantity: 3,
          pricePerUnit: 5.00,
          date: now.subtract(const Duration(hours: 3)),
          eventName: eventName,
          eventLocation: eventLocation),
      SaleRecord(
          id: 'sample-sale-basket',
          itemId: 'sample-finished-basket',
          quantity: 1,
          pricePerUnit: 18.00,
          date: now.subtract(const Duration(hours: 2, minutes: 20)),
          eventName: eventName,
          eventLocation: eventLocation),
      SaleRecord(
          id: 'sample-sale-cozy',
          itemId: 'sample-finished-cozy',
          quantity: 2,
          pricePerUnit: 9.00,
          date: now.subtract(const Duration(hours: 1, minutes: 10)),
          eventName: eventName,
          eventLocation: eventLocation),
    ];

    final sampleShoppingList = ShoppingList(
      id: 'sample-shopping-yarn',
      name: 'Yarn & Notions Refill',
      createdAt: now,
      items: [
        ShoppingListItem(
            id: 'sample-shopping-cotton',
            itemName: 'DK cotton yarn',
            quantity: '4 balls',
            notes: 'Teal, cream and coral'),
        ShoppingListItem(
            id: 'sample-shopping-eyes',
            itemName: 'Safety eyes',
            quantity: '1 pack',
            notes: '8 mm black'),
        ShoppingListItem(
            id: 'sample-shopping-stuffing',
            itemName: 'Toy stuffing',
            quantity: '1 bag'),
        ShoppingListItem(
            id: 'sample-shopping-markers',
            itemName: 'Locking stitch markers',
            quantity: '1 pack'),
      ],
    );

    await Future.wait([
      inventory.putAll({for (final item in inventoryItems) item.id: item}),
      sales.putAll({for (final sale in sampleSales) sale.id: sale}),
      projects.put(sampleProject.id, sampleProject),
      shopping.put(sampleShoppingList.id, sampleShoppingList),
    ]);
  }

  static Future<void> clearCraftData() async {
    final inventory = await Hive.openBox<InventoryItem>(_inventoryBox);
    final sales = await Hive.openBox<SaleRecord>(_salesBox);
    final sessions = await Hive.openBox(_stallSessionsBox);
    final projects = await Hive.openBox<Project>(_projectsBox);
    final shopping = await Hive.openBox<ShoppingList>(_shoppingListsBox);
    final compliance = await Hive.openBox(_complianceBox);
    await Future.wait([
      inventory.clear(),
      sales.clear(),
      sessions.clear(),
      projects.clear(),
      shopping.clear(),
      compliance.clear(),
    ]);
  }
}
