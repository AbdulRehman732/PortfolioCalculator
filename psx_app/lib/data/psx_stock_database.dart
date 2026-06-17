// Complete list of PSX-listed companies
// Data used for local search functionality in Add Stock screen

class PsxStockDatabase {
  static const List<Map<String, String>> allStocks = [
    // ── Fertilizers ───────────────────────────────────────────────────
    {'symbol': 'FFC',    'name': 'Fauji Fertilizer Co',            'sector': 'Fertilizer'},
    {'symbol': 'EFERT',  'name': 'Engro Fertilizers',              'sector': 'Fertilizer'},
    {'symbol': 'FATIMA', 'name': 'Fatima Fertilizer Co',           'sector': 'Fertilizer'},
    {'symbol': 'FFBL',   'name': 'Fauji Fertilizer Bin Qasim',     'sector': 'Fertilizer'},
    {'symbol': 'DAWH',   'name': 'Dawood Hercules Corp',           'sector': 'Fertilizer'},

    // ── Banking ───────────────────────────────────────────────────────
    {'symbol': 'HBL',    'name': 'Habib Bank Limited',             'sector': 'Banking'},
    {'symbol': 'MCB',    'name': 'MCB Bank Limited',               'sector': 'Banking'},
    {'symbol': 'UBL',    'name': 'United Bank Limited',            'sector': 'Banking'},
    {'symbol': 'ABL',    'name': 'Allied Bank Limited',            'sector': 'Banking'},
    {'symbol': 'NBP',    'name': 'National Bank of Pakistan',      'sector': 'Banking'},
    {'symbol': 'BAFL',   'name': 'Bank Alfalah Limited',           'sector': 'Banking'},
    {'symbol': 'BAHL',   'name': 'Bank Al Habib Limited',          'sector': 'Banking'},
    {'symbol': 'BIPL',   'name': 'BankIslami Pakistan',            'sector': 'Banking'},
    {'symbol': 'MEBL',   'name': 'Meezan Bank',                    'sector': 'Banking'},
    {'symbol': 'BOP',    'name': 'Bank of Punjab',                 'sector': 'Banking'},
    {'symbol': 'AKBL',   'name': 'Askari Bank Limited',            'sector': 'Banking'},
    {'symbol': 'JSBL',   'name': 'JS Bank Limited',                'sector': 'Banking'},
    {'symbol': 'SILK',   'name': 'Silkbank Limited',               'sector': 'Banking'},
    {'symbol': 'SNBL',   'name': 'Summit Bank Limited',            'sector': 'Banking'},
    {'symbol': 'SMBL',   'name': 'SME Bank Limited',               'sector': 'Banking'},
    {'symbol': 'BOK',    'name': 'Bank of Khyber',                 'sector': 'Banking'},
    {'symbol': 'FAYSAL', 'name': 'Faysal Bank Limited',            'sector': 'Banking'},
    {'symbol': 'DUBL',   'name': 'Dubai Islamic Bank Pakistan',    'sector': 'Banking'},

    // ── Energy / Oil & Gas ────────────────────────────────────────────
    {'symbol': 'OGDC',   'name': 'Oil & Gas Dev Co',               'sector': 'Energy'},
    {'symbol': 'PPL',    'name': 'Pakistan Petroleum Ltd',         'sector': 'Energy'},
    {'symbol': 'PSO',    'name': 'Pakistan State Oil',             'sector': 'Energy'},
    {'symbol': 'MARI',   'name': 'Mari Petroleum',                 'sector': 'Energy'},
    {'symbol': 'HUBC',   'name': 'Hub Power Company',              'sector': 'Energy'},
    {'symbol': 'KAPCO',  'name': 'Kot Addu Power Co',              'sector': 'Energy'},
    {'symbol': 'NCPL',   'name': 'Nishat Chunian Power',           'sector': 'Energy'},
    {'symbol': 'NPL',    'name': 'Nishat Power Limited',           'sector': 'Energy'},
    {'symbol': 'PKGP',   'name': 'PakGen Power Ltd',               'sector': 'Energy'},
    {'symbol': 'ATRL',   'name': 'Attock Refinery Limited',        'sector': 'Energy'},
    {'symbol': 'NRL',    'name': 'National Refinery Limited',      'sector': 'Energy'},
    {'symbol': 'PRL',    'name': 'Pakistan Refinery Limited',      'sector': 'Energy'},
    {'symbol': 'SNGP',   'name': 'Sui Northern Gas Pipelines',     'sector': 'Energy'},
    {'symbol': 'SSGC',   'name': 'Sui Southern Gas Co',            'sector': 'Energy'},
    {'symbol': 'PGAS',   'name': 'Pakistan Gas Ltd',               'sector': 'Energy'},
    {'symbol': 'SEARL',  'name': 'The Searle Company',             'sector': 'Pharma'},

    // ── Cement ───────────────────────────────────────────────────────
    {'symbol': 'LUCK',   'name': 'Lucky Cement',                   'sector': 'Cement'},
    {'symbol': 'CHCC',   'name': 'Cherat Cement',                  'sector': 'Cement'},
    {'symbol': 'DGKC',   'name': 'D.G. Khan Cement',               'sector': 'Cement'},
    {'symbol': 'MLCF',   'name': 'Maple Leaf Cement',              'sector': 'Cement'},
    {'symbol': 'KOHC',   'name': 'Kohat Cement',                   'sector': 'Cement'},
    {'symbol': 'PIOC',   'name': 'Pioneer Cement',                 'sector': 'Cement'},
    {'symbol': 'FCCL',   'name': 'Fauji Cement Co',                'sector': 'Cement'},
    {'symbol': 'ACPL',   'name': 'Attock Cement Pakistan',         'sector': 'Cement'},
    {'symbol': 'GWLC',   'name': 'Gharibwal Cement',               'sector': 'Cement'},
    {'symbol': 'BWCL',   'name': 'Bestway Cement',                 'sector': 'Cement'},
    {'symbol': 'POWER',  'name': 'Frontier Cement Co',             'sector': 'Cement'},

    // ── Textiles ──────────────────────────────────────────────────────
    {'symbol': 'NCL',    'name': 'Nishat (Chunian) Ltd',           'sector': 'Textiles'},
    {'symbol': 'NML',    'name': 'Nishat Mills Limited',           'sector': 'Textiles'},
    {'symbol': 'GATM',   'name': 'Gul Ahmed Textile Mills',        'sector': 'Textiles'},
    {'symbol': 'KTML',   'name': 'Kohinoor Textile Mills',         'sector': 'Textiles'},
    {'symbol': 'RCML',   'name': 'Reliance Cotton Mills',          'sector': 'Textiles'},
    {'symbol': 'CRTM',   'name': 'Crescent Textile Mills',         'sector': 'Textiles'},
    {'symbol': 'YUNUS',  'name': 'Yunus Textile Mills',            'sector': 'Textiles'},
    {'symbol': 'SQTM',   'name': 'Saqib Textile Mills',            'sector': 'Textiles'},
    {'symbol': 'MZTL',   'name': 'Mazhar Textile Mills',           'sector': 'Textiles'},
    {'symbol': 'SAPT',   'name': 'Sapphire Textile Mills',         'sector': 'Textiles'},
    {'symbol': 'SPNTM',  'name': 'Sapphire Fibres',                'sector': 'Textiles'},
    {'symbol': 'GTYR',   'name': 'General Tyre & Rubber',          'sector': 'Textiles'},

    // ── Technology & Telecom ─────────────────────────────────────────
    {'symbol': 'SYS',    'name': 'Systems Limited',                'sector': 'Technology'},
    {'symbol': 'TRG',    'name': 'TRG Pakistan',                   'sector': 'Technology'},
    {'symbol': 'AVN',    'name': 'Avanceon Limited',               'sector': 'Technology'},
    {'symbol': 'TELE',   'name': 'Telecard Limited',               'sector': 'Technology'},
    {'symbol': 'NETSOL', 'name': 'NetSol Technologies',            'sector': 'Technology'},
    {'symbol': 'PTC',    'name': 'Pakistan Telecom Co (PTCL)',      'sector': 'Technology'},
    {'symbol': 'TPPL',   'name': 'Techno Power Plant',             'sector': 'Technology'},

    // ── Pharma ───────────────────────────────────────────────────────
    {'symbol': 'FEROZ',  'name': 'Ferozsons Laboratories',         'sector': 'Pharma'},
    {'symbol': 'GLAXO',  'name': 'GlaxoSmithKline Pakistan',       'sector': 'Pharma'},
    {'symbol': 'AGP',    'name': 'AGP Limited',                    'sector': 'Pharma'},
    {'symbol': 'HINOON', 'name': 'Highnoon Laboratories',          'sector': 'Pharma'},
    {'symbol': 'INIL',   'name': 'International Industries',       'sector': 'Pharma'},
    {'symbol': 'SAMI',   'name': 'Sami Pharmaceuticals',           'sector': 'Pharma'},

    // ── Food & Beverages ─────────────────────────────────────────────
    {'symbol': 'NATF',   'name': 'National Foods Limited',         'sector': 'Food'},
    {'symbol': 'NESTLE', 'name': 'Nestle Pakistan Limited',        'sector': 'Food'},
    {'symbol': 'OLPL',   'name': ' Oleander Pakistan',             'sector': 'Food'},
    {'symbol': 'COLG',   'name': 'Colgate-Palmolive Pakistan',     'sector': 'Food'},
    {'symbol': 'ALNRS',  'name': 'Al-Noor Sugar Mills',            'sector': 'Food'},
    {'symbol': 'SSML',   'name': 'Shakarganj Sugar Mills',         'sector': 'Food'},
    {'symbol': 'CSAP',   'name': 'Chiniot Sugar & Allied',         'sector': 'Food'},
    {'symbol': 'FNEL',   'name': 'Faran Sugar Mills',              'sector': 'Food'},
    {'symbol': 'SHFA',   'name': 'Shifa International Hospital',   'sector': 'Healthcare'},

    // ── Conglomerate & Diversified ───────────────────────────────────
    {'symbol': 'ENGRO',  'name': 'Engro Corporation',              'sector': 'Conglomerate'},
    {'symbol': 'PKGS',   'name': 'Packages Limited',               'sector': 'Conglomerate'},
    {'symbol': 'ABOT',   'name': 'Abbott Laboratories Pakistan',   'sector': 'Conglomerate'},
    {'symbol': 'GATOL',  'name': 'Gatron Industries',              'sector': 'Conglomerate'},

    // ── Steel & Metals ───────────────────────────────────────────────
    {'symbol': 'ISL',    'name': 'International Steels Limited',   'sector': 'Steel'},
    {'symbol': 'ASTL',   'name': 'Amreli Steels Limited',          'sector': 'Steel'},
    {'symbol': 'CSIL',   'name': 'Crescent Steel & Allied',        'sector': 'Steel'},

    // ── Insurance ────────────────────────────────────────────────────
    {'symbol': 'JLICL',  'name': 'Jubilee Life Insurance',         'sector': 'Insurance'},
    {'symbol': 'AICL',   'name': 'Adamjee Insurance',              'sector': 'Insurance'},
    {'symbol': 'EFU',    'name': 'EFU Life Assurance',             'sector': 'Insurance'},
    {'symbol': 'PCAL',   'name': 'Pakistan Insurance Corp',        'sector': 'Insurance'},
    {'symbol': 'IGIIL',  'name': 'IGI Life Insurance',             'sector': 'Insurance'},

    // ── Automobiles ──────────────────────────────────────────────────
    {'symbol': 'PSMC',   'name': 'Pak Suzuki Motor Co',            'sector': 'Automobile'},
    {'symbol': 'INDU',   'name': 'Indus Motor Company',            'sector': 'Automobile'},
    {'symbol': 'HCAR',   'name': 'Honda Atlas Cars Pakistan',      'sector': 'Automobile'},
    {'symbol': 'ATLH',   'name': 'Atlas Honda Limited',            'sector': 'Automobile'},
    {'symbol': 'SAZEW',  'name': 'Sazgar Engineering Works',       'sector': 'Automobile'},
    {'symbol': 'MTL',    'name': 'Millat Tractors Limited',        'sector': 'Automobile'},
    {'symbol': 'AGTL',   'name': 'Al-Ghazi Tractors Limited',      'sector': 'Automobile'},

    // ── Chemicals ────────────────────────────────────────────────────
    {'symbol': 'ICI',    'name': 'ICI Pakistan Limited',           'sector': 'Chemical'},
    {'symbol': 'EPCL',   'name': 'Engro Polymer & Chemicals',      'sector': 'Chemical'},
    {'symbol': 'LOTCHEM','name': 'Lotte Chemical Pakistan',        'sector': 'Chemical'},

    // ── Real Estate & Construction ───────────────────────────────────
    {'symbol': 'PACE',   'name': 'PACE Pakistan Limited',          'sector': 'Real Estate'},
    {'symbol': 'CEPB',   'name': 'Century Paper & Board Mills',    'sector': 'Real Estate'},

    // ── Media & Publishing ───────────────────────────────────────────
    {'symbol': 'JDWS',   'name': 'JDW Sugar Mills',                'sector': 'Media'},
    {'symbol': 'PNSC',   'name': 'Pakistan National Shipping',     'sector': 'Shipping'},
  ];

  // Search for stocks by symbol or name
  static List<Map<String, String>> searchStocks(String query) {
    if (query.isEmpty) return [];

    final q = query.toLowerCase();
    return allStocks
        .where((stock) =>
            stock['symbol']!.toLowerCase().contains(q) ||
            stock['name']!.toLowerCase().contains(q))
        .toList();
  }

  // Get stock by symbol
  static Map<String, String>? getStockBySymbol(String symbol) {
    try {
      return allStocks.firstWhere(
        (stock) => stock['symbol']!.toUpperCase() == symbol.toUpperCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get all stocks in a sector
  static List<Map<String, String>> getStocksBySector(String sector) {
    return allStocks
        .where((stock) =>
            stock['sector']!.toLowerCase() == sector.toLowerCase())
        .toList();
  }

  // Get all sectors
  static List<String> getAllSectors() {
    final sectors = <String>{};
    for (var stock in allStocks) {
      sectors.add(stock['sector']!);
    }
    return sectors.toList()..sort();
  }
}
