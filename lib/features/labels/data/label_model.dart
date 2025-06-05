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
  LabelTemplate(
    id: 'avery_l7160',
    name: 'Avery L7160 (3x7)',
    width: 63.5,
    height: 38.1,
    columns: 3,
    rows: 7,
  ),
  LabelTemplate(
    id: 'small_square',
    name: 'Small Square (4x5)',
    width: 50.0,
    height: 50.0,
    columns: 4,
    rows: 5,
  ),
];