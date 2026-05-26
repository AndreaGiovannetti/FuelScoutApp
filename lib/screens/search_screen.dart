import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/stations_provider.dart';
import '../providers/preferences_provider.dart';
import '../services/fuel_data_service.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _ctrl;
  late FocusNode _focus;
  late AnimationController _anim;
  late Animation<double> _fadeAnim;

  List<Map<String, dynamic>> _results = [];
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _ctrl  = TextEditingController();
    _focus = FocusNode();
    _anim  = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _anim, curve: Curves.easeOut);

    _ctrl.addListener(_onQueryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focus.requestFocus();
      _anim.forward();
    });

    _results = FuelDataService.italianCities.take(10).toList();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    final q = _ctrl.text;
    setState(() {
      _results = FuelDataService.searchCities(q);
      _searching = q.isNotEmpty;
    });
  }

  Future<void> _selectCity(Map<String, dynamic> city) async {
    final sp   = context.read<StationsProvider>();
    final pref = context.read<PreferencesProvider>();

    final center = LatLng(city['lat'] as double, city['lng'] as double);
    final name   = city['name'] as String;

    await pref.addRecentCity(name);
    await pref.saveMapState(center.latitude, center.longitude, 13.0, name);
    sp.setMapCenter(center, zoom: 13.0);
    await sp.loadStations(center);

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final pref = context.watch<PreferencesProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(context),
              if (!_searching && pref.recentCities.isNotEmpty)
                _buildRecentSection(pref),
              Expanded(child: _buildResults()),
            ],
          ),
        ),
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.amber.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.amber.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                style: const TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Cerca una città…',
                  hintStyle: const TextStyle(
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Syne',
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.amber,
                    size: 22,
                  ),
                  suffixIcon: _ctrl.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _ctrl.clear();
                            setState(() => _searching = false);
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            color: AppTheme.textMuted,
                            size: 18,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: const Center(
                child: Text(
                  'Annulla',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent ────────────────────────────────────────────────────────────────
  Widget _buildRecentSection(PreferencesProvider pref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Recenti',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: pref.clearRecentCities,
                child: const Text(
                  'Cancella',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.amber,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: pref.recentCities.map((city) {
              final found = FuelDataService.italianCities
                  .where((c) => c['name'] == city)
                  .firstOrNull;

              return GestureDetector(
                onTap: found != null ? () => _selectCity(found) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceAlt,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history_rounded, size: 13, color: AppTheme.textMuted),
                      const SizedBox(width: 5),
                      Text(
                        city,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppTheme.cardBorder),
        ],
      ),
    );
  }

  // ── Results ───────────────────────────────────────────────────────────────
  Widget _buildResults() {
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 12),
            Text(
              'Nessuna città trovata per "${_ctrl.text}"',
              style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _results.length,
      itemBuilder: (context, i) {
        final city = _results[i];
        return _CityTile(
          city: city,
          query: _ctrl.text,
          onTap: () => _selectCity(city),
        );
      },
    );
  }
}

// ── City Tile ─────────────────────────────────────────────────────────────

class _CityTile extends StatelessWidget {
  final Map<String, dynamic> city;
  final String query;
  final VoidCallback onTap;

  const _CityTile({
    required this.city,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = city['name'] as String;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppTheme.amberGlow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_city_rounded,
                size: 18,
                color: AppTheme.amber,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HighlightedText(text: name, query: query),
                  const SizedBox(height: 2),
                  const Text(
                    'Italia',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

// ── Highlighted text ──────────────────────────────────────────────────────

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;

  const _HighlightedText({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(
        text,
        style: const TextStyle(
          fontFamily: 'Syne',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      );
    }

    final q = query.toLowerCase();
    final t = text.toLowerCase();
    final idx = t.indexOf(q);

    if (idx < 0) {
      return Text(
        text,
        style: const TextStyle(
          fontFamily: 'Syne',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: text.substring(0, idx),
            style: const TextStyle(
              fontFamily: 'Syne',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          TextSpan(
            text: text.substring(idx, idx + query.length),
            style: const TextStyle(
              fontFamily: 'Syne',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.amber,
            ),
          ),
          TextSpan(
            text: text.substring(idx + query.length),
            style: const TextStyle(
              fontFamily: 'Syne',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
