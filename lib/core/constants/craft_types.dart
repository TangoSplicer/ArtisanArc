enum CraftType {
  crochet,
  knitting,
  sewing,
  embroidery,
  quilting,
  paperCraft,
  macrame,
  beadwork,
  painting,
  calligraphy,
  woodburning,
  crossStitch,
  leatherworking,
  resinArt,
  soapMaking,
  candleMaking,
}

extension CraftTypeExtension on CraftType {
  String get label {
    switch (this) {
      case CraftType.crochet: return 'Crochet';
      case CraftType.knitting: return 'Knitting';
      case CraftType.sewing: return 'Sewing';
      case CraftType.embroidery: return 'Embroidery';
      case CraftType.quilting: return 'Quilting';
      case CraftType.paperCraft: return 'Paper Craft';
      case CraftType.macrame: return 'Macramé';
      case CraftType.beadwork: return 'Beadwork';
      case CraftType.painting: return 'Painting';
      case CraftType.calligraphy: return 'Calligraphy';
      case CraftType.woodburning: return 'Woodburning';
      case CraftType.crossStitch: return 'Cross-stitch';
      case CraftType.leatherworking: return 'Leatherworking';
      case CraftType.resinArt: return 'Resin Art';
      case CraftType.soapMaking: return 'Soap Making';
      case CraftType.candleMaking: return 'Candle Making';
    }
  }
}