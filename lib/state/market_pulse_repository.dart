import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_signal.dart';

class MarketPulseRepository {
  static const _endpoint =
      'https://api.data.gov.my/data-catalogue?id=ipi&filter=abs@series&sort=-date&limit=13';

  Future<({List<MarketSignal> signals, bool isLive})> fetchRecent() async {
    try {
      final response = await http
          .get(Uri.parse(_endpoint))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as List<dynamic>;
        if (decoded.length > 1) {
          final signals = decoded
              .map((e) => MarketSignal.fromJson(e as Map<String, dynamic>))
              .toList()
              .reversed
              .toList();
          return (signals: signals, isLive: true);
        }
      }
    } catch (_) {
    }
    return (signals: _fallbackSignals, isLive: false);
  }

  List<MarketRecommendation> buildRecommendations(List<MarketSignal> signals) {
    if (signals.length < 2) return const [];

    final latest = signals.last;
    final prev = signals[signals.length - 2];
    final momPct = ((latest.index - prev.index) / prev.index) * 100;

    final sixWindow = signals.length >= 6
        ? signals.sublist(signals.length - 6)
        : signals;
    final sixAvg =
        sixWindow.map((s) => s.index).reduce((a, b) => a + b) / sixWindow.length;
    final vsAvgPct = ((latest.index - sixAvg) / sixAvg) * 100;

    final recs = <MarketRecommendation>[];

    if (momPct > 0.3) {
      recs.add(MarketRecommendation(
        tag: 'RESTOCK',
        tone: RecommendationTone.up,
        action: 'Restock structural steel & fasteners',
        body:
        'Manufacturing output rose ${momPct.toStringAsFixed(1)}% month-on-month. '
            'Rising factory activity usually feeds through to construction and '
            'fit-out demand within a quarter — a good window to top up '
            'fast-moving steel SKUs.',
      ));
    } else if (momPct < -0.3) {
      recs.add(MarketRecommendation(
        tag: 'HOLD',
        tone: RecommendationTone.down,
        action: 'Hold on bulk steel reorders',
        body:
        'Output slipped ${momPct.abs().toStringAsFixed(1)}% from last month. '
            'Consider trimming incoming steel stock orders and running a '
            'clearance push on slower furniture lines instead.',
      ));
    } else {
      recs.add(MarketRecommendation(
        tag: 'MAINTAIN',
        tone: RecommendationTone.flat,
        action: 'Maintain current stock levels',
        body:
        "Manufacturing output is roughly flat month-on-month. No strong "
            "signal to expand or cut inventory — keep an eye on next month's "
            "release.",
      ));
    }

    if (vsAvgPct > 1) {
      recs.add(MarketRecommendation(
        tag: 'TREND',
        tone: RecommendationTone.up,
        action: 'Lean into fit-out & renovation categories',
        body:
        'Current output is running ${vsAvgPct.toStringAsFixed(1)}% above its '
            '6-month average, suggesting a sustained upswing. Featuring '
            'furniture and fit-out bundles could catch this wave of building '
            'activity.',
      ));
    } else if (vsAvgPct < -1) {
      recs.add(MarketRecommendation(
        tag: 'TREND',
        tone: RecommendationTone.down,
        action: 'Diversify away from bulk materials',
        body:
        'Output is ${vsAvgPct.abs().toStringAsFixed(1)}% below its 6-month '
            'average. Shifting promo spend toward smaller hardware and '
            'maintenance items may be steadier than betting on bulk materials '
            'right now.',
      ));
    }

    return recs;
  }

  static final List<MarketSignal> _fallbackSignals = [
    MarketSignal(date: DateTime(2025, 9, 1), index: 112.4),
    MarketSignal(date: DateTime(2025, 10, 1), index: 113.1),
    MarketSignal(date: DateTime(2025, 11, 1), index: 111.8),
    MarketSignal(date: DateTime(2025, 12, 1), index: 114.6),
    MarketSignal(date: DateTime(2026, 1, 1), index: 110.2),
    MarketSignal(date: DateTime(2026, 2, 1), index: 112.9),
    MarketSignal(date: DateTime(2026, 3, 1), index: 115.3),
    MarketSignal(date: DateTime(2026, 4, 1), index: 116.0),
    MarketSignal(date: DateTime(2026, 5, 1), index: 114.8),
    MarketSignal(date: DateTime(2026, 6, 1), index: 117.2),
    MarketSignal(date: DateTime(2026, 7, 1), index: 118.5),
    MarketSignal(date: DateTime(2026, 8, 1), index: 117.9),
  ];
}