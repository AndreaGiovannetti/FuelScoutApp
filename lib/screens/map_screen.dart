import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import '../providers/stations_provider.dart';
import '../providers/preferences_provider.dart';
import '../models/station.dart';
import '../theme/app_theme.dart';
import '../widgets/station_card.dart';
import 'station_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  late MapController _mapController;
  late AnimationController _panelAnim;
  bool _panelExpanded = false;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _panelAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    _panelAnim.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() => _panelExpanded = !_panelExpanded);
    if (_panelExpanded) {
      _panelAnim.forward();
    } else {
      _panelAnim.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sp   = context.watch<StationsProvider>();
    final pref = context.watch<PreferencesProvider>();
    final h    = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // ── Map ─────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: sp.mapCenter,
              initialZoom: sp.mapZoom,
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  // Save map position to prefs
                  context.read<PreferencesProvider>().saveMapState(
                    event.camera.center.latitude,
                    event.camera.center.longitude,
                    event.camera.zoom,
                    pref.savedCity,
                  );
                }
              },
              onTap: (_, __) {
                if (_panelExpanded) _togglePanel();
                sp.selectStation(null);
              },
            ),
            children: [
              // Dark tile layer (CartoDB dark matter)
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.fuelscout.app',
                retinaMode: true,
              ),

              // Station markers
              MarkerLayer(
                markers: sp.stations.map((station) {
                  final price = station.priceFor(sp.activeFuel);
                  final isCheapest = sp.cheapestSelected?.id == station.id;
                  final isSelected = sp.selected?.id == station.id;

                  return Marker(
                    point: station.location,
                    width: isSelected ? 72 : 60,
                    height: isSelected ? 72 : 60,
                    child: GestureDetector(
                      onTap: () {
                        sp.selectStation(station);
                        if (!_panelExpanded) _togglePanel();
                        _mapController.move(station.location, 15);
                      },
                      child: _StationMarker(
                        station: station,
                        price: price?.price,
                        isCheapest: isCheapest,
                        isSelected: isSelected,
                        fuelColor: sp.activeFuel.color,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // ── Top gradient fade ────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: 140,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.bg, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          // ── Fuel type bar ────────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16, right: 16,
            child: _FuelFilterBar(
              activeFuel: sp.activeFuel,
              onFuelChanged: sp.setActiveFuel,
              onFilterTap: () => setState(() => _showFilters = !_showFilters),
              showFilters: _showFilters,
              stationCount: sp.stations.length,
            ),
          ),

          // ── Filter sheet ─────────────────────────────────────────────────
          if (_showFilters)
            Positioned(
              top: MediaQuery.of(context).padding.top + 110,
              left: 16, right: 16,
              child: _FilterSheet(
                onClose: () => setState(() => _showFilters = false),
              ),
            ),

          // ── Locate me button ─────────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: _panelExpanded ? h * 0.42 + 16 : 120,
            child: _MapFab(
              icon: Icons.my_location_rounded,
              onTap: () async {
                final prov = context.read<StationsProvider>();
                _mapController.move(prov.mapCenter, 14);
              },
            ),
          ),

          // ── Refresh button ───────────────────────────────────────────────
          Positioned(
            right: 16,
            bottom: _panelExpanded ? h * 0.42 + 72 : 176,
            child: _MapFab(
              icon: Icons.refresh_rounded,
              onTap: () => sp.refresh(),
            ),
          ),

          // ── Stats chip ───────────────────────────────────────────────────
          if (!_panelExpanded && sp.loadState == LoadState.loaded)
            Positioned(
              bottom: 100,
              left: 16,
              child: _StatsChip(sp: sp),
            ),

          // ── Bottom panel ─────────────────────────────────────────────────
          _BottomPanel(
            expanded: _panelExpanded,
            onToggle: _togglePanel,
          ),

          // ── Loading overlay ──────────────────────────────────────────────
          if (sp.isLoading)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: const Center(
                    child: _LoadingIndicator(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Station Marker ────────────────────────────────────────────────────────

class _StationMarker extends StatelessWidget {
  final Station station;
  final double? price;
  final bool isCheapest;
  final bool isSelected;
  final Color fuelColor;

  const _StationMarker({
    required this.station,
    this.price,
    required this.isCheapest,
    required this.isSelected,
    required this.fuelColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCheapest
        ? AppTheme.green
        : isSelected
            ? AppTheme.amber
            : station.isOpen
                ? fuelColor
                : AppTheme.textMuted;

    return AnimatedScale(
      scale: isSelected ? 1.15 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color, width: isSelected ? 2 : 1.5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: isSelected ? 16 : 8,
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
            child: price != null
                ? Text(
                    '€${price!.toStringAsFixed(3)}',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  )
                : Icon(Icons.local_gas_station_rounded, size: 14, color: color),
          ),
          // Pointer
          CustomPaint(
            size: const Size(10, 5),
            painter: _PointerPainter(color: color),
          ),
        ],
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  final Color color;
  const _PointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Fuel Filter Bar ───────────────────────────────────────────────────────

class _FuelFilterBar extends StatelessWidget {
  final FuelType activeFuel;
  final ValueChanged<FuelType> onFuelChanged;
  final VoidCallback onFilterTap;
  final bool showFilters;
  final int stationCount;

  const _FuelFilterBar({
    required this.activeFuel,
    required this.onFuelChanged,
    required this.onFilterTap,
    required this.showFilters,
    required this.stationCount,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: FuelType.values
                      .where((t) => t != FuelType.hydrogen)
                      .map((t) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FuelTypeChip(
                              type: t,
                              selected: activeFuel == t,
                              onTap: () => onFuelChanged(t),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            Container(
              width: 1, height: 28,
              color: AppTheme.cardBorder,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: showFilters
                      ? AppTheme.amber.withValues(alpha: 0.15)
                      : AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: showFilters ? AppTheme.amber : AppTheme.cardBorder,
                  ),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: showFilters ? AppTheme.amber : AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter Sheet ──────────────────────────────────────────────────────────

class _FilterSheet extends StatelessWidget {
  final VoidCallback onClose;

  const _FilterSheet({required this.onClose});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<StationsProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 24),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Filtri',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close_rounded, color: AppTheme.textMuted, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Self service toggle
          _FilterRow(
            label: 'Solo Self-Service',
            icon: Icons.person_rounded,
            value: sp.selfOnly,
            onChanged: sp.setSelfOnly,
          ),
          const SizedBox(height: 8),

          // Open only toggle
          _FilterRow(
            label: 'Solo Aperti',
            icon: Icons.access_time_rounded,
            value: sp.openOnly,
            onChanged: sp.setOpenOnly,
          ),
          const SizedBox(height: 14),

          // Radius slider
          Row(
            children: [
              const Icon(Icons.radar_rounded, size: 16, color: AppTheme.textMuted),
              const SizedBox(width: 8),
              Text(
                'Raggio: ${sp.maxRadiusKm.toStringAsFixed(0)} km',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.amber,
              inactiveTrackColor: AppTheme.cardBorder,
              thumbColor: AppTheme.amber,
              overlayColor: AppTheme.amberGlow,
              trackHeight: 3,
            ),
            child: Slider(
              value: sp.maxRadiusKm,
              min: 1,
              max: 20,
              divisions: 19,
              onChanged: sp.setMaxRadius,
            ),
          ),

          // Sort by
          const Text(
            'Ordina per',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _SortChip(label: '💰 Prezzo',  value: 'price',    current: sp.sortBy, onTap: sp.setSortBy),
              const SizedBox(width: 8),
              _SortChip(label: '📍 Distanza', value: 'distance', current: sp.sortBy, onTap: sp.setSortBy),
              const SizedBox(width: 8),
              _SortChip(label: '⭐ Rating',  value: 'rating',   current: sp.sortBy, onTap: sp.setSortBy),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FilterRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textMuted),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppTheme.amber,
          inactiveTrackColor: AppTheme.cardBorder,
        ),
      ],
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final ValueChanged<String> onTap;

  const _SortChip({
    required this.label, required this.value,
    required this.current, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = value == current;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.amberGlow : AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? AppTheme.amber : AppTheme.cardBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: active ? AppTheme.amber : AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Stats Chip ────────────────────────────────────────────────────────────

class _StatsChip extends StatelessWidget {
  final StationsProvider sp;
  const _StatsChip({required this.sp});

  @override
  Widget build(BuildContext context) {
    final cheapest = sp.cheapestSelected;
    if (cheapest == null) return const SizedBox.shrink();

    final price = cheapest.priceFor(sp.activeFuel)?.price;
    if (price == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppTheme.green.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: AppTheme.green.withValues(alpha: 0.2), blurRadius: 12),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_downward_rounded, size: 14, color: AppTheme.green),
          const SizedBox(width: 6),
          Text(
            'Migliore: €${price.toStringAsFixed(3)} — ${sp.activeFuel.shortLabel}',
            style: const TextStyle(
              fontFamily: 'Syne',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.green,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Panel ──────────────────────────────────────────────────────────

class _BottomPanel extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;

  const _BottomPanel({required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final sp   = context.watch<StationsProvider>();
    final pref = context.watch<PreferencesProvider>();
    final h    = MediaQuery.of(context).size.height;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
      bottom: 0, left: 0, right: 0,
      height: expanded ? h * 0.52 : 80,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: const Border(
            top: BorderSide(color: AppTheme.cardBorder),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle
            GestureDetector(
              onTap: onToggle,
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity! < -300 && !expanded) onToggle();
                if (details.primaryVelocity! >  300 &&  expanded) onToggle();
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  children: [
                    Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    if (!expanded) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.local_gas_station_rounded,
                              size: 14, color: AppTheme.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            '${sp.stations.length} stazioni nelle vicinanze',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (sp.cheapestSelected != null) ...[
                            const Text('·', style: TextStyle(color: AppTheme.textMuted)),
                            const SizedBox(width: 8),
                            Text(
                              'Migliore: €${sp.cheapestSelected!.priceFor(sp.activeFuel)?.price.toStringAsFixed(3) ?? '--'}',
                              style: const TextStyle(
                                fontFamily: 'Syne',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.green,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (expanded)
              Expanded(
                child: _StationList(sp: sp, pref: pref),
              ),
          ],
        ),
      ),
    );
  }
}

class _StationList extends StatelessWidget {
  final StationsProvider sp;
  final PreferencesProvider pref;

  const _StationList({required this.sp, required this.pref});

  @override
  Widget build(BuildContext context) {
    if (sp.loadState == LoadState.loading) {
      return const Center(child: _LoadingIndicator());
    }

    if (sp.stations.isEmpty) {
      return const Center(
        child: Text(
          'Nessuna stazione trovata\nProva ad allargare il raggio',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
        ),
      );
    }

    final cheapest = sp.cheapestSelected;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: sp.stations.length,
      itemBuilder: (context, i) {
        final station = sp.stations[i];
        return StationCard(
          station: station,
          activeFuel: sp.activeFuel,
          isCheapest: cheapest?.id == station.id,
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, anim, __) =>
                    StationDetailScreen(station: station),
                transitionsBuilder: (_, anim, __, child) =>
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: anim,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
              ),
            );
          },
          onFavorite: () => sp.toggleFavorite(station.id),
          distanceLabel: pref.formatDistance(station.distanceKm ?? 0),
        );
      },
    );
  }
}

// ── FAB ───────────────────────────────────────────────────────────────────

class _MapFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapFab({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppTheme.textSecondary),
      ),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppTheme.amber),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Caricamento stazioni…',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
