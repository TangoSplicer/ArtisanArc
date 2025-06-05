class ComplianceTag {
  final String name;
  final String country;
  final String applicableCraft;

  const ComplianceTag({
    required this.name,
    required this.country,
    required this.applicableCraft,
  });
}

const List<ComplianceTag> predefinedComplianceTags = [
  ComplianceTag(name: 'UKCA', country: 'UK', applicableCraft: 'Crochet'),
  ComplianceTag(name: 'BS EN71', country: 'UK', applicableCraft: 'Toy Making'),
  ComplianceTag(name: 'CPSR', country: 'UK', applicableCraft: 'Soap Making'),
  ComplianceTag(name: 'ASTM D-4236', country: 'US', applicableCraft: 'Art Supplies'),
  ComplianceTag(name: 'CPSIA', country: 'US', applicableCraft: 'Toy Making'),
  ComplianceTag(name: 'FDA Safety', country: 'US', applicableCraft: 'Cosmetics'),
];