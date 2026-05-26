import 'package:flutter/material.dart';
import '../models/station.dart';
import '../theme/app_theme.dart';

// ── FuelTypeChip ──────────────────────────────────────────────────────────

class FuelTypeChip extends StatelessWidget {
  final FuelType type;
  final bool selected;
  final VoidCallback onTap;

  const FuelTypeChip({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? type.color.withValues(alpha: 0.18) : AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: selected ? type.color : AppTheme.cardBorder,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: type.color.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 3))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icon, size: 14, color: selected ? type.color : AppTheme.textMuted),
            const SizedBox(width: 6),
            Text(
              type.shortLabel,
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? type.color : AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── PriceTag ──────────────────────────────────────────────────────────────

class PriceTag extends StatelessWidget {
  final double price;
  final FuelType type;
  final bool isCheapest;
  final bool isSelf;
  final bool large;

  const PriceTag({
    super.key,
    required this.price,
    required this.type,
    this.isCheapest = false,
    this.isSelf = false,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final formattedPrice = price.toStringAsFixed(3);
    final parts = formattedPrice.split('.');

    return Container(
      padding: large
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isCheapest
            ? AppTheme.green.withValues(alpha: 0.12)
            : AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(large ? 14 : 10),
        border: Border.all(
          color: isCheapest ? AppTheme.green.withValues(alpha: 0.4) : AppTheme.cardBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${parts[0]}.',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: large ? 26 : 18,
                    fontWeight: FontWeight.w800,
                    color: isCheapest ? AppTheme.green : AppTheme.textPrimary,
                  ),
                ),
                TextSpan(
                  text: parts[1],
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: large ? 15 : 11,
                    fontWeight: FontWeight.w600,
                    color: (isCheapest ? AppTheme.green : AppTheme.textPrimary)
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelf) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppTheme.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'SELF',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.cyan,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                type.unit,
                style: const TextStyle(
                  fontSize: 9,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── StationCard ───────────────────────────────────────────────────────────

class StationCard extends StatelessWidget {
  final Station station;
  final FuelType activeFuel;
  final bool isCheapest;
  final double? avgPrice;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final String distanceLabel;

  const StationCard({
    super.key,
    required this.station,
    required this.activeFuel,
    required this.onTap,
    required this.onFavorite,
    required this.distanceLabel,
    this.isCheapest = false,
    this.avgPrice,
  });

  @override
  Widget build(BuildContext context) {
    final price = station.priceFor(activeFuel);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1E2E), Color(0xFF13161F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCheapest
                ? AppTheme.green.withValues(alpha: 0.4)
                : AppTheme.cardBorder,
            width: isCheapest ? 1.5 : 1,
          ),
          boxShadow: isCheapest
              ? [BoxShadow(color: AppTheme.green.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildPrices(),
              const SizedBox(height: 10),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Brand badge
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: station.brand.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: station.brand.color.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              station.brand.name.substring(0, 2).toUpperCase(),
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: station.brand.color,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      station.brand.name,
                      style: const TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCheapest) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '🏆 BEST',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.green,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                station.address,
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onFavorite,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Icon(
              station.isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              key: ValueKey(station.isFavorite),
              color: station.isFavorite ? AppTheme.amber : AppTheme.textMuted,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrices() {
    final fuelPrices = station.prices
        .where((p) => !p.isSelf)
        .take(4)
        .toList();

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: fuelPrices.map((p) {
        final isActive = p.type == activeFuel;
        final isBest   = isActive && isCheapest;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isActive
                ? p.type.color.withValues(alpha: 0.12)
                : AppTheme.surfaceAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? p.type.color.withValues(alpha: 0.4)
                  : AppTheme.cardBorder,
            ),
          ),
          child: Column(
            children: [
              Text(
                p.type.shortLabel,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isActive ? p.type.color : AppTheme.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                p.price.toStringAsFixed(3),
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isBest
                      ? AppTheme.green
                      : isActive
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Icon(
          station.isOpen ? Icons.circle : Icons.circle,
          size: 7,
          color: station.isOpen ? AppTheme.green : AppTheme.red,
        ),
        const SizedBox(width: 5),
        Text(
          station.isOpen ? 'Aperto' : 'Chiuso',
          style: TextStyle(
            fontSize: 11,
            color: station.isOpen ? AppTheme.green : AppTheme.red,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.near_me_rounded, size: 12, color: AppTheme.textMuted),
        const SizedBox(width: 4),
        Text(
          distanceLabel,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
        const Spacer(),
        if (station.hasCarWash)
          _amenity(Icons.local_car_wash_rounded),
        if (station.hasShop)
          _amenity(Icons.shopping_bag_outlined),
        if (station.hasAir)
          _amenity(Icons.air_rounded),
        const SizedBox(width: 8),
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 12, color: AppTheme.amber),
            const SizedBox(width: 3),
            Text(
              station.rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _amenity(IconData icon) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: Icon(icon, size: 13, color: AppTheme.textMuted),
  );
}

// ── SavingsCard ───────────────────────────────────────────────────────────

class SavingsCard extends StatelessWidget {
  final double cheapestPrice;
  final double avgPrice;
  final FuelType fuelType;

  const SavingsCard({
    super.key,
    required this.cheapestPrice,
    required this.avgPrice,
    required this.fuelType,
  });

  @override
  Widget build(BuildContext context) {
    final saving = avgPrice - cheapestPrice;
    final savingPercent = (saving / avgPrice * 100);
    final isGood = saving > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.green.withValues(alpha: 0.12),
            AppTheme.green.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.green.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.savings_rounded, color: AppTheme.green, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGood ? 'Risparmio potenziale' : 'Prezzo nella media',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                if (isGood)
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '−€${saving.toStringAsFixed(3)}/L ',
                          style: const TextStyle(
                            fontFamily: 'Syne',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.green,
                          ),
                        ),
                        TextSpan(
                          text: '(${savingPercent.toStringAsFixed(1)}% in meno)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    '${fuelType.label}: €${cheapestPrice.toStringAsFixed(3)}',
                    style: const TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
