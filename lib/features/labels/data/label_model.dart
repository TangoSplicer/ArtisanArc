class LabelTemplate {
  final String id;
  final String name;
  final double width;   // in mm
  final double height;  // in mm
  final int columns;
  final int rows;

  const LabelTemplate({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.columns,
    required this.rows,
  });
}

final List<LabelTemplate> predefinedTemplates = [
  LabelTemplate(id: 'avery_l7160', name: 'Avery L7160 — 63.5 × 38.1 mm (3 × 7)', width: 63.5, height: 38.1, columns: 3, rows: 7),
  LabelTemplate(id: 'avery_l7161', name: 'Avery L7161 — 63.5 × 46.6 mm (3 × 6)', width: 63.5, height: 46.6, columns: 3, rows: 6),
  LabelTemplate(id: 'avery_l7162', name: 'Avery L7162 — 99.1 × 33.9 mm (2 × 8)', width: 99.1, height: 33.9, columns: 2, rows: 8),
  LabelTemplate(id: 'avery_l7163', name: 'Avery L7163 — 99.1 × 38.1 mm (2 × 7)', width: 99.1, height: 38.1, columns: 2, rows: 7),
  LabelTemplate(id: 'address_small', name: 'Small Address — 66 × 25.4 mm (3 × 10)', width: 66.0, height: 25.4, columns: 3, rows: 10),
  LabelTemplate(id: 'address_large', name: 'Large Address — 99.1 × 57 mm (2 × 5)', width: 99.1, height: 57.0, columns: 2, rows: 5),
  LabelTemplate(id: 'jar_round', name: 'Jar Label — 60 × 60 mm (3 × 4)', width: 60.0, height: 60.0, columns: 3, rows: 4),
  LabelTemplate(id: 'small_square', name: 'Small Square — 50 × 50 mm (4 × 5)', width: 50.0, height: 50.0, columns: 4, rows: 5),
  LabelTemplate(id: 'shipping', name: 'Shipping Label — 105 × 74 mm (2 × 4)', width: 105.0, height: 74.0, columns: 2, rows: 4),
  LabelTemplate(id: 'tall_tag', name: 'Tall Tag — 45 × 70 mm (4 × 4)', width: 45.0, height: 70.0, columns: 4, rows: 4),
];