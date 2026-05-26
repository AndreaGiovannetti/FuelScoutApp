import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/station.dart';
import '../providers/stations_provider.dart';
import '../providers/preferences_provider.dart';
import '../theme/app_theme.dart';

class StationDetailScreen extends StatelessWidget {
  final Station station;

  const StationDetailScreen({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<StationsProvider>();
    final pref = context.watch<PreferencesProvider>();
    final avg = sp.avgPrices;
    final isFav = station.isFavorite;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, isFav, sp),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(pref),
                  const SizedBox(height: 20),
                  _buildStatusRow(pref),
                  const SizedBox(height: 20),
                  _buildPriceGrid(avg),
                  const SizedBox(height: 20),
                  _buildAmenities(),
                  const SizedBox(height: 20),
                  _buildHours(),
                  const SizedBox(height: 24),
                  _buildActions(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildNavBar(context),
    );
  }

  // ── App bar ───────────────────────────────────────────────────────────────
  SliverAppBar _buildAppBar(BuildContext ctx, bool isFav, StationsProvider sp) {
    return SliverAppBar(
      backgroundColor: AppTheme.bg,
      elevation: 0,
      pinned: true,
      leading: GestureDetector(
        onTap: () => Navigator.of(ctx).pop(),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 16, color: AppTheme.textSecondary),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => sp.toggleFavorite(station.id),
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isFav ? AppTheme.amberGlow : AppTheme.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isFav ? AppTheme.amber : AppTheme.cardBorder,
              ),
            ),
            child: Icon(
              isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              size: 16,
              color: isFav ? AppTheme.amber : AppTheme.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 6),
      ],
      title: Text(
        station.brand.name,
        style: const TextStyle(
          fontFamily: 'Syne',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(PreferencesProvider pref) {
    return Row(
      children: [
        // Brand logo placeholder
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                station.brand.color.withValues(alpha: 0.2),
                station.brand.color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: station.brand.color.withValues(alpha: 0.4)),
          ),
          child: Center(
            child: Text(
              station.brand.name.substring(0, 2).toUpperCase(),
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: station.brand.color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                station.brand.name,
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                station.address,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                station.city,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Status row ────────────────────────────────────────────────────────────
  Widget _buildStatusRow(PreferencesProvider pref) {
    return Row(
      children: [
        _StatusPill(
          label: station.isOpen ? 'Aperto' : 'Chiuso',
          color: station.isOpen ? AppTheme.green : AppTheme.red,
          icon: station.isOpen
              ? Icons.check_circle_rounded
              : Icons.cancel_rounded,
        ),
        const SizedBox(width: 8),
        _StatusPill(
          label: pref.formatDistance(station.distanceKm ?? 0),
          color: AppTheme.cyan,
          icon: Icons.near_me_rounded,
        ),
        const SizedBox(width: 8),
        _StatusPill(
          label: '${station.rating.toStringAsFixed(1)} ★',
          color: AppTheme.amber,
          icon: Icons.star_rounded,
        ),
        const SizedBox(width: 8),
        Text(
          '(${station.reviewCount} rec.)',
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  // ── Price grid ────────────────────────────────────────────────────────────
  Widget _buildPriceGrid(Map<FuelType, double> avg) {
    // Group by fuel type, show served and self separately
    final types = station.prices.map((p) => p.type).toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prezzi Carburanti',
          style: TextStyle(
            fontFamily: 'Syne',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...types.map((type) {
          final served = station.prices
              .where((p) => p.type == type && !p.isSelf)
              .firstOrNull;
          final self = station.prices
              .where((p) => p.type == type && p.isSelf)
              .firstOrNull;
          final avgPrice = avg[type];

          return _PriceRow(
            type: type,
            served: served,
            self: self,
            avgPrice: avgPrice,
          );
        }),
      ],
    );
  }

  // ── Amenities ─────────────────────────────────────────────────────────────
  Widget _buildAmenities() {
    final amenities = <_Amenity>[
      _Amenity('Officina', Icons.build_rounded, station.hasCarWash),
      _Amenity(
          'Autolavaggio', Icons.local_car_wash_rounded, station.hasCarWash),
      _Amenity('Negozio', Icons.shopping_bag_outlined, station.hasShop),
      _Amenity('Bagni', Icons.wc_rounded, station.hasRestroom),
      _Amenity('Gonfiaggio', Icons.air_rounded, station.hasAir),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Servizi',
          style: TextStyle(
            fontFamily: 'Syne',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: amenities.map((a) => _AmenityChip(amenity: a)).toList(),
        ),
      ],
    );
  }

  // ── Hours ─────────────────────────────────────────────────────────────────
  Widget _buildHours() {
    if (station.hours.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Orari',
          style: TextStyle(
            fontFamily: 'Syne',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Column(
            children: station.hours.entries
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Text(
                            e.key,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            e.value,
                            style: const TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Apertura navigazione…')),
              );
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: AppTheme.amberGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.amberShadow,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.navigation_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Naviga',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Condivisione…')),
              );
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share_rounded,
                      size: 18, color: AppTheme.textSecondary),
                  SizedBox(width: 6),
                  Text(
                    'Condividi',
                    style:
                        TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (station.phone != null)
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.cyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cyan.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.phone_rounded,
                  size: 20, color: AppTheme.cyan),
            ),
          ),
      ],
    );
  }

  // ── Nav bar ───────────────────────────────────────────────────────────────
  Widget _buildNavBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.cardBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lowest price call-out
          if (station.lowestPrice() != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded,
                      size: 16, color: AppTheme.amber),
                  const SizedBox(width: 6),
                  const Text(
                    'Prezzo più basso: ',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  Text(
                    '€${station.lowestPrice()!.toStringAsFixed(3)}',
                    style: const TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Navigazione verso ${station.brand.name}…'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.amber,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.near_me_rounded),
              label: const Text(
                'Portami qui',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Support Widgets ───────────────────────────────────────────────────────

class _PriceRow extends StatelessWidget {
  final FuelType type;
  final FuelPrice? served;
  final FuelPrice? self;
  final double? avgPrice;

  const _PriceRow({
    required this.type,
    this.served,
    this.self,
    this.avgPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: type.color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: type.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(type.icon, size: 16, color: type.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              type.label,
              style: const TextStyle(
                fontFamily: 'Syne',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          if (self != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppTheme.cyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'SELF',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.cyan,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '€${self!.price.toStringAsFixed(3)}',
                      style: const TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 12),
          ],
          if (served != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '€${served!.price.toStringAsFixed(3)}',
                  style: const TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (avgPrice != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    served!.price < avgPrice!
                        ? '▼ ${((avgPrice! - served!.price) / avgPrice! * 100).toStringAsFixed(1)}% vs media'
                        : '▲ ${((served!.price - avgPrice!) / avgPrice! * 100).toStringAsFixed(1)}% vs media',
                    style: TextStyle(
                      fontSize: 10,
                      color: served!.price < avgPrice!
                          ? AppTheme.green
                          : AppTheme.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusPill({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _Amenity {
  final String label;
  final IconData icon;
  final bool available;
  const _Amenity(this.label, this.icon, this.available);
}

class _AmenityChip extends StatelessWidget {
  final _Amenity amenity;
  const _AmenityChip({required this.amenity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: amenity.available ? AppTheme.surfaceAlt : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: amenity.available ? AppTheme.cardBorder : AppTheme.surface,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            amenity.icon,
            size: 13,
            color:
                amenity.available ? AppTheme.textSecondary : AppTheme.textMuted,
          ),
          const SizedBox(width: 5),
          Text(
            amenity.label,
            style: TextStyle(
              fontSize: 12,
              color: amenity.available
                  ? AppTheme.textSecondary
                  : AppTheme.textMuted,
              fontWeight: FontWeight.w500,
              decoration: amenity.available ? null : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }
}
