class ComplianceTag {
  final String name;
  final String country;
  final List<String> applicableCraft;

  const ComplianceTag({
    required this.name,
    required this.country,
    required this.applicableCraft,
  });
}

const List<ComplianceTag> predefinedComplianceTags = [
  ComplianceTag(
      name: 'Allergen Information Record',
      country: 'General',
      applicableCraft: ['Candle Making', 'Cosmetics', 'Soap Making']),
  ComplianceTag(
      name: 'ASTM D-4236',
      country: 'US',
      applicableCraft: ['Art Supplies', 'Painting']),
  ComplianceTag(
      name: 'BS EN 71 Toy Safety Record',
      country: 'UK/EU',
      applicableCraft: ['Toy Making']),
  ComplianceTag(
      name: 'CPSIA Record', country: 'US', applicableCraft: ['Toy Making']),
  ComplianceTag(
      name: 'CPSR Product Safety Assessment',
      country: 'UK/EU',
      applicableCraft: ['Cosmetics', 'Soap Making']),
  ComplianceTag(
      name: 'Care and Use Instructions',
      country: 'General',
      applicableCraft: [
        'Candle Making',
        'Ceramics',
        'Jewellery Making',
        'Textiles'
      ]),
  ComplianceTag(
      name: 'Cosmetic Product Information File',
      country: 'UK/EU',
      applicableCraft: ['Cosmetics', 'Soap Making']),
  ComplianceTag(
      name: 'Electrical Safety Check',
      country: 'General',
      applicableCraft: ['Candle Making', 'Electronics', 'Woodworking']),
  ComplianceTag(
      name: 'Fire Safety Check',
      country: 'General',
      applicableCraft: ['Candle Making', 'Studio', 'Woodworking']),
  ComplianceTag(
      name: 'Food Contact Materials Record',
      country: 'General',
      applicableCraft: ['Ceramics', 'Pottery']),
  ComplianceTag(
      name: 'General Product Safety Record',
      country: 'General',
      applicableCraft: ['All Crafts']),
  ComplianceTag(
      name: 'Hazard and Risk Assessment',
      country: 'General',
      applicableCraft: ['All Crafts']),
  ComplianceTag(
      name: 'Insurance Record',
      country: 'General',
      applicableCraft: ['All Crafts']),
  ComplianceTag(
      name: 'Material Safety Data Sheet',
      country: 'General',
      applicableCraft: [
        'Ceramics',
        'Resin Art',
        'Soap Making',
        'Textile Dyeing'
      ]),
  ComplianceTag(
      name: 'Product Batch Record',
      country: 'General',
      applicableCraft: ['Candle Making', 'Cosmetics', 'Soap Making']),
  ComplianceTag(
      name: 'REACH Substance Record',
      country: 'UK/EU',
      applicableCraft: ['Jewellery Making', 'Resin Art', 'Textile Dyeing']),
  ComplianceTag(
      name: 'Safety Data Sheet Review',
      country: 'General',
      applicableCraft: ['Adhesives', 'Paint', 'Resin Art']),
  ComplianceTag(
      name: 'UKCA Conformity Record',
      country: 'UK',
      applicableCraft: ['Electronics', 'Toy Making']),
  ComplianceTag(
      name: 'US FDA Cosmetic Record',
      country: 'US',
      applicableCraft: ['Cosmetics', 'Soap Making']),
  ComplianceTag(
      name: 'Waste Disposal Record',
      country: 'General',
      applicableCraft: ['Ceramics', 'Resin Art', 'Textile Dyeing']),
];
