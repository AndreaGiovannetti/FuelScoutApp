import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stations_provider.dart';
import '../providers/preferences_provider.dart';
import '../models/station.dart';
import '../theme/app_theme.dart';
import '../widgets/station_card.dart';
import 'station_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<StationsProvider>();
    final pref = context.watch<PreferencesProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, pref),
          if (sp.isLoading)
            const SliverFillRemaining(child: _ShimmerHome())
          else ...[
            _buildHeroStats(sp, pref),
            _buildFuelTabs(sp),
            _buildTopCheap(context, sp, pref),
            _buildAverages(sp),
            _buildFavorites(context, sp, pref),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  SliverAppBar _buildAppBar(BuildContext context, PreferencesProvider pref) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: AppTheme.bg,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.bg, Color(0xFF0E1018)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 20,
            bottom: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  // Flame logo
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppTheme.amberGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FuelScout',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // City indicator
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceAlt,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            size: 13, color: AppTheme.amber),
                        const SizedBox(width: 4),
                        Text(
                          pref.savedCity,
                          style: const TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero stats ────────────────────────────────────────────────────────────
  SliverToBoxAdapter _buildHeroStats(
      StationsProvider sp, PreferencesProvider pref) {
    final cheapest = sp.cheapestSelected;
    final avgPrices = sp.avgPrices;
    final avgForFuel = avgPrices[sp.activeFuel];
    final cheapestPrice = cheapest?.priceFor(sp.activeFuel)?.price;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          children: [
            // Main hero card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1E2E), Color(0xFF13161F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.cardBorder),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Miglior prezzo ${sp.activeFuel.label}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${sp.stations.length} stazioni',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (cheapest != null && cheapestPrice != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '€${cheapestPrice.toStringAsFixed(3)}',
                          style: const TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            sp.activeFuel.unit,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (avgForFuel != null && cheapestPrice < avgForFuel)
                          _SavingsBadge(
                            saving: avgForFuel - cheapestPrice,
                            percent:
                                (avgForFuel - cheapestPrice) / avgForFuel * 100,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: cheapest.brand.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              cheapest.brand.name.substring(0, 2),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: cheapest.brand.color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cheapest.brand.name,
                                style: const TextStyle(
                                  fontFamily: 'Syne',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                cheapest.address,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          pref.formatDistance(cheapest.distanceKm ?? 0),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const Text(
                      'Nessun dato disponibile',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 20,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Quick stats row
            Row(
              children: [
                _QuickStat(
                  label: 'Media zona',
                  value: avgForFuel != null
                      ? '€${avgForFuel.toStringAsFixed(3)}'
                      : '--',
                  icon: Icons.bar_chart_rounded,
                  color: AppTheme.cyan,
                ),
                const SizedBox(width: 10),
                _QuickStat(
                  label: 'Stazioni aperte',
                  value: sp.stations.where((s) => s.isOpen).length.toString(),
                  icon: Icons.check_circle_outline_rounded,
                  color: AppTheme.green,
                ),
                const SizedBox(width: 10),
                _QuickStat(
                  label: 'Con GPL',
                  value: sp.stations
                      .where((s) => s.priceFor(FuelType.lpg) != null)
                      .length
                      .toString(),
                  icon: Icons.local_fire_department_rounded,
                  color: FuelType.lpg.color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Fuel tabs ─────────────────────────────────────────────────────────────
  SliverToBoxAdapter _buildFuelTabs(StationsProvider sp) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 48,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: FuelType.values
              .map((t) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FuelTypeChip(
                      type: t,
                      selected: sp.activeFuel == t,
                      onTap: () => sp.setActiveFuel(t),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  // ── Top cheap stations ────────────────────────────────────────────────────
  SliverToBoxAdapter _buildTopCheap(
      BuildContext ctx, StationsProvider sp, PreferencesProvider pref) {
    final top = sp.topCheapest;
    if (top.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'Più Convenienti',
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: top.length,
            itemBuilder: (context, i) {
              final s = top[i];
              return StationCard(
                station: s,
                activeFuel: sp.activeFuel,
                isCheapest: i == 0,
                onTap: () => Navigator.of(ctx).push(
                  MaterialPageRoute(
                    builder: (_) => StationDetailScreen(station: s),
                  ),
                ),
                onFavorite: () => sp.toggleFavorite(s.id),
                distanceLabel: pref.formatDistance(s.distanceKm ?? 0),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Average prices grid ───────────────────────────────────────────────────
  SliverToBoxAdapter _buildAverages(StationsProvider sp) {
    final avgs = sp.avgPrices;
    if (avgs.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prezzi Medi in Zona',
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.4,
              ),
              itemCount: avgs.length,
              itemBuilder: (context, i) {
                final entry = avgs.entries.toList()[i];
                return _AvgPriceCell(type: entry.key, price: entry.value);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Favorites ─────────────────────────────────────────────────────────────
  SliverToBoxAdapter _buildFavorites(
      BuildContext ctx, StationsProvider sp, PreferencesProvider pref) {
    final favs = sp.favorites;
    if (favs.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.bookmark_rounded, size: 16, color: AppTheme.amber),
                SizedBox(width: 8),
                Text(
                  'Preferiti',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...favs.map((s) => StationCard(
                  station: s,
                  activeFuel: sp.activeFuel,
                  onTap: () => Navigator.of(ctx).push(
                    MaterialPageRoute(
                      builder: (_) => StationDetailScreen(station: s),
                    ),
                  ),
                  onFavorite: () => sp.toggleFavorite(s.id),
                  distanceLabel: pref.formatDistance(s.distanceKm ?? 0),
                )),
          ],
        ),
      ),
    );
  }
}

// ── Support Widgets ───────────────────────────────────────────────────────

class _SavingsBadge extends StatelessWidget {
  final double saving;
  final double percent;
  const _SavingsBadge({required this.saving, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '−${percent.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontFamily: 'Syne',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.green,
            ),
          ),
          Text(
            'vs media',
            style: TextStyle(
              fontSize: 9,
              color: AppTheme.green.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AvgPriceCell extends StatelessWidget {
  final FuelType type;
  final double price;
  const _AvgPriceCell({required this.type, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: type.color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(type.icon, size: 16, color: type.color),
          const SizedBox(height: 4),
          Text(
            type.shortLabel,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: type.color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '€${price.toStringAsFixed(3)}',
            style: const TextStyle(
              fontFamily: 'Syne',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerHome extends StatelessWidget {
  const _ShimmerHome();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _shimmerBox(height: 160, radius: 24),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _shimmerBox(height: 80, radius: 14)),
              const SizedBox(width: 10),
              Expanded(child: _shimmerBox(height: 80, radius: 14)),
              const SizedBox(width: 10),
              Expanded(child: _shimmerBox(height: 80, radius: 14)),
            ],
          ),
          const SizedBox(height: 24),
          _shimmerBox(height: 120, radius: 20),
          const SizedBox(height: 10),
          _shimmerBox(height: 120, radius: 20),
        ],
      ),
    );
  }

  Widget _shimmerBox({required double height, double radius = 12}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
