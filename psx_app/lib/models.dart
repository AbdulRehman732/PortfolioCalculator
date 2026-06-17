class Stock {
  final String symbol;
  final String name;
  final String sector;
  final double price;
  final double? dividendYield;
  final String marketCap;
  final String volume;
  final String change;
  final double? de;
  final double? icr;
  final double? netDebtEbitda;
  final double? assetTurnover;
  final double? invTurnover;
  final double? pfcf;
  final double? fcfYield;
  final double? ocfRatio;
  final int? brScore;
  final String verdict;

  Stock({
    required this.symbol,
    required this.name,
    required this.sector,
    required this.price,
    this.dividendYield,
    this.marketCap = '',
    this.volume = '',
    this.change = '',
    this.de,
    this.icr,
    this.netDebtEbitda,
    this.assetTurnover,
    this.invTurnover,
    this.pfcf,
    this.fcfYield,
    this.ocfRatio,
    this.brScore,
    this.verdict = '',
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return Stock(
      symbol: json['symbol']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sector: json['sector']?.toString() ?? '',
      price: parseDouble(json['price']) ?? 0,
      dividendYield:
          parseDouble(json['yield']) ?? parseDouble(json['dividendYield']),
      marketCap: json['marketCap']?.toString() ?? '',
      volume: json['volume']?.toString() ?? '',
      change: json['change']?.toString() ?? '',
      de: parseDouble(json['de']),
      icr: parseDouble(json['icr']),
      netDebtEbitda: parseDouble(json['netDebtEbitda']),
      assetTurnover: parseDouble(json['assetTurnover']),
      invTurnover: parseDouble(json['invTurnover']),
      pfcf: parseDouble(json['pfcf']),
      fcfYield: parseDouble(json['fcfYield']),
      ocfRatio: parseDouble(json['ocfRatio']),
      brScore: json['brScore'] is int
          ? json['brScore'] as int
          : int.tryParse(json['brScore']?.toString() ?? ''),
      verdict: json['verdict']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'sector': sector,
      'price': price,
      'yield': dividendYield,
      'marketCap': marketCap,
      'volume': volume,
      'change': change,
      'de': de,
      'icr': icr,
      'netDebtEbitda': netDebtEbitda,
      'assetTurnover': assetTurnover,
      'invTurnover': invTurnover,
      'pfcf': pfcf,
      'fcfYield': fcfYield,
      'ocfRatio': ocfRatio,
      'brScore': brScore,
      'verdict': verdict,
    };
  }
}

class PortfolioItem {
  final String symbol;
  final String name;
  final String sector;
  final String tier;
  int shares;
  double avgBuy;
  double dpshist;

  PortfolioItem({
    required this.symbol,
    required this.name,
    required this.sector,
    required this.tier,
    required this.shares,
    required this.avgBuy,
    required this.dpshist,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      symbol: json['symbol']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sector: json['sector']?.toString() ?? '',
      tier: json['tier']?.toString() ?? '',
      shares: (json['shares'] is int
              ? json['shares']
              : int.tryParse(json['shares']?.toString() ?? '0')) ??
          0,
      avgBuy: (json['avgBuy'] is num
              ? (json['avgBuy'] as num).toDouble()
              : double.tryParse(json['avgBuy']?.toString() ?? '0')) ??
          0,
      dpshist: (json['dpshist'] is num
              ? (json['dpshist'] as num).toDouble()
              : double.tryParse(json['dpshist']?.toString() ?? '0')) ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'sector': sector,
      'tier': tier,
      'shares': shares,
      'avgBuy': avgBuy,
      'dpshist': dpshist,
    };
  }
}

class TransactionEntry {
  final String symbol;
  final String type;
  final int shares;
  final double price;
  final String date;

  TransactionEntry({
    required this.symbol,
    required this.type,
    required this.shares,
    required this.price,
    required this.date,
  });

  factory TransactionEntry.fromJson(Map<String, dynamic> json) {
    return TransactionEntry(
      symbol: json['symbol']?.toString() ?? '',
      type: json['type']?.toString() ?? 'buy',
      shares: (json['shares'] is int
              ? json['shares']
              : int.tryParse(json['shares']?.toString() ?? '0')) ??
          0,
      price: (json['price'] is num
              ? (json['price'] as num).toDouble()
              : double.tryParse(json['price']?.toString() ?? '0')) ??
          0,
      date: json['date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'type': type,
      'shares': shares,
      'price': price,
      'date': date,
    };
  }
}

class DividendEntry {
  final String symbol;
  final double amount;
  final String note;
  final String date;

  DividendEntry({
    required this.symbol,
    required this.amount,
    required this.note,
    required this.date,
  });

  factory DividendEntry.fromJson(Map<String, dynamic> json) {
    return DividendEntry(
      symbol: json['symbol']?.toString() ?? '',
      amount: (json['amount'] is num
              ? (json['amount'] as num).toDouble()
              : double.tryParse(json['amount']?.toString() ?? '0')) ??
          0,
      note: json['note']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'symbol': symbol, 'amount': amount, 'note': note, 'date': date};
  }
}

class NewsArticle {
  final String title;
  final String pubDate;
  final String sentiment;
  final int score;
  final String summary;
  final String link;

  NewsArticle({
    required this.title,
    required this.pubDate,
    required this.sentiment,
    required this.score,
    required this.summary,
    required this.link,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title']?.toString() ?? '',
      pubDate: json['pubDate']?.toString() ?? '',
      sentiment: json['sentiment']?.toString() ?? 'Neutral',
      score: json['score'] is int
          ? json['score']
          : int.tryParse(json['score']?.toString() ?? '0') ?? 0,
      summary: json['summary']?.toString() ?? '',
      link: json['link']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'pubDate': pubDate,
      'sentiment': sentiment,
      'score': score,
      'summary': summary,
      'link': link,
    };
  }
}

class NewsAnalysis {
  final String symbol;
  final String overallSentiment;
  final String impactExplanation;
  final List<NewsArticle> articles;

  NewsAnalysis({
    required this.symbol,
    required this.overallSentiment,
    required this.impactExplanation,
    required this.articles,
  });

  factory NewsAnalysis.fromJson(Map<String, dynamic> json) {
    final articles = <NewsArticle>[];
    if (json['articles'] is List) {
      for (final item in json['articles']) {
        if (item is Map<String, dynamic>) {
          articles.add(NewsArticle.fromJson(item));
        }
      }
    }
    return NewsAnalysis(
      symbol: json['symbol']?.toString() ?? '',
      overallSentiment: json['overallSentiment']?.toString() ?? 'Neutral',
      impactExplanation: json['impactExplanation']?.toString() ?? '',
      articles: articles,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'overallSentiment': overallSentiment,
      'impactExplanation': impactExplanation,
      'articles': articles.map((e) => e.toJson()).toList(),
    };
  }
}
