class MarketSignal {
  final DateTime date;
  final double index;

  const MarketSignal({required this.date, required this.index});

  factory MarketSignal.fromJson(Map<String, dynamic> json) {
    return MarketSignal(
      date: DateTime.parse(json['date'] as String),
      index: (json['index'] as num).toDouble(),
    );
  }

  String get monthLabel {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

enum RecommendationTone { up, down, flat }

class MarketRecommendation {
  final String tag;
  final String action;
  final String body;
  final RecommendationTone tone;

  const MarketRecommendation({
    required this.tag,
    required this.action,
    required this.body,
    required this.tone,
  });
}