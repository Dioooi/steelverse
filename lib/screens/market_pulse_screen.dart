import 'package:flutter/material.dart';
import '../models/market_signal.dart';
import '../state/market_pulse_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/product_banner_header.dart';
import 'category_list_screen.dart';
import 'favorites_screen.dart';
import '../state/product_store.dart';
import '../main.dart';

class MarketPulseScreen extends StatefulWidget {
  final String username;

  const MarketPulseScreen({super.key, this.username = 'Guest'});

  @override
  State<MarketPulseScreen> createState() => _MarketPulseScreenState();
}

class _MarketPulseScreenState extends State<MarketPulseScreen> {
  final _repository = MarketPulseRepository();

  bool _loading = true;
  bool _isLive = false;
  List<MarketSignal> _signals = const [];
  List<MarketRecommendation> _recommendations = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await _repository.fetchRecent();
    final recs = _repository.buildRecommendations(result.signals);
    if (!mounted) return;
    setState(() {
      _signals = result.signals;
      _isLive = result.isLive;
      _recommendations = recs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ProductBannerHeader(
                  title: 'Market Pulse',
                  subtitle: 'Manufacturing output signal · Department of Statistics Malaysia',
                  onBack: () => Navigator.of(context).maybePop(),
                ),
              ),
              SliverToBoxAdapter(
                child: _loading
                    ? const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
                    : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusLine(isLive: _isLive),
                      const SizedBox(height: 12),
                      _HeroCard(signals: _signals),
                      const SizedBox(height: 24),
                      const Text(
                        'Recommended for your shelves',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._recommendations.map(
                            (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _RecommendationCard(recommendation: r),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _SourceNote(isLive: _isLive),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => HomeScreen(username: widget.username)),
                    (route) => false,
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryListScreen(
                    categoryTitle: 'Hardware Parts',
                    categorySubtitle: 'Full Inventory',
                    products: ProductStore.instance.products,
                    username: widget.username,
                  ),
                ),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FavoritesScreen(
                    favorites: ProductStore.instance.favorites,
                    username: widget.username,
                  ),
                ),
              );
              break;
            case 3:
              break;
          }
        },
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  final bool isLive;
  const _StatusLine({required this.isLive});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isLive ? AppColors.success : AppColors.textSecondary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isLive ? 'Live from data.gov.my' : 'Showing cached sample (offline)',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final List<MarketSignal> signals;
  const _HeroCard({required this.signals});

  @override
  Widget build(BuildContext context) {
    if (signals.length < 2) {
      return const Text('No data available.', style: TextStyle(color: AppColors.textSecondary));
    }
    final latest = signals.last;
    final prev = signals[signals.length - 2];
    final momPct = ((latest.index - prev.index) / prev.index) * 100;
    final up = momPct > 0.3;
    final down = momPct < -0.3;
    final chipColor = up ? AppColors.success : (down ? AppColors.danger : AppColors.textSecondary);
    final arrow = up ? '▲' : (down ? '▼' : '—');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Industrial Production Index',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          latest.index.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'index, 2015=100',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: chipColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$arrow ${momPct.abs().toStringAsFixed(1)}% MoM',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: chipColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: CustomPaint(
              size: Size.infinite,
              painter: _SparklinePainter(signals.map((s) => s.index).toList()),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Latest reading: ${latest.monthLabel} · Department of Statistics Malaysia',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  _SparklinePainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 0.001 ? 1 : (maxV - minV);

    final path = Path();
    final fillPath = Path();
    final dx = size.width / (values.length - 1);

    for (var i = 0; i < values.length; i++) {
      final x = dx * i;
      final normalized = (values[i] - minV) / range;
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.primary.withValues(alpha: 0.25), AppColors.primary.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => oldDelegate.values != values;
}

class _RecommendationCard extends StatelessWidget {
  final MarketRecommendation recommendation;
  const _RecommendationCard({required this.recommendation});

  Color get _accent {
    switch (recommendation.tone) {
      case RecommendationTone.up:
        return AppColors.success;
      case RecommendationTone.down:
        return AppColors.danger;
      case RecommendationTone.flat:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: _accent, width: 3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  recommendation.action,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  recommendation.tag,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            recommendation.body,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _SourceNote extends StatelessWidget {
  final bool isLive;
  const _SourceNote({required this.isLive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Signal built from the Industrial Production Index, published monthly by the '
            'Department of Statistics Malaysia via data.gov.my (CC BY 4.0). Rising manufacturing '
            'output tends to lead more construction, renovation and fit-out activity — supporting '
            'more resilient, data-driven industry (SDG 9).',
        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.5),
      ),
    );
  }
}