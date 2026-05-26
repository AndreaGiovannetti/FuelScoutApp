import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/preferences_provider.dart';
import '../providers/stations_provider.dart';
import '../models/station.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pref = context.watch<PreferencesProvider>();
    final sp = context.watch<StationsProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(pref),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'Carburante Predefinito',
                    icon: Icons.local_gas_station_rounded,
                    iconColor: AppTheme.amber,
                    child: _FuelDefaultPicker(pref: pref),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Filtri Predefiniti',
                    icon: Icons.tune_rounded,
                    iconColor: AppTheme.cyan,
                    child: Column(
                      children: [
                        _ToggleTile(
                          label: 'Preferisci Self-Service',
                          subtitle: 'Mostra prima i prezzi self',
                          value: pref.preferSelf,
                          onChanged: pref.setPreferSelf,
                        ),
                        const _Divider(),
                        _ToggleTile(
                          label: 'Solo Stazioni Aperte',
                          subtitle: 'Nascondi le stazioni chiuse',
                          value: pref.showOpenOnly,
                          onChanged: pref.setShowOpenOnly,
                        ),
                        const _Divider(),
                        _SliderTile(
                          label: 'Raggio di Ricerca',
                          subtitle:
                              '${pref.defaultRadius.toStringAsFixed(0)} km',
                          value: pref.defaultRadius,
                          min: 1,
                          max: 20,
                          onChanged: pref.setDefaultRadius,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Mappa',
                    icon: Icons.map_rounded,
                    iconColor: AppTheme.green,
                    child: Column(
                      children: [
                        _InfoTile(
                          label: 'Ultima Città',
                          value: pref.savedCity,
                          icon: Icons.location_city_rounded,
                        ),
                        const _Divider(),
                        _InfoTile(
                          label: 'Zoom Salvato',
                          value: pref.savedZoom.toStringAsFixed(1),
                          icon: Icons.zoom_in_rounded,
                        ),
                        const _Divider(),
                        _ActionTile(
                          label: 'Ricarica Stazioni',
                          subtitle: 'Aggiorna i prezzi nella zona',
                          icon: Icons.refresh_rounded,
                          onTap: () => sp.refresh(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Unità e Display',
                    icon: Icons.settings_rounded,
                    iconColor: AppTheme.textSecondary,
                    child: Column(
                      children: [
                        _SegmentedTile(
                          label: 'Unità Distanza',
                          options: const ['km', 'mi'],
                          selected: pref.distanceUnit,
                          onChanged: pref.setDistanceUnit,
                        ),
                        const _Divider(),
                        _ToggleTile(
                          label: 'Avvisi Prezzi',
                          subtitle: 'Notifiche quando i prezzi scendono',
                          value: pref.priceAlerts,
                          onChanged: pref.setPriceAlerts,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Ricerche Recenti',
                    icon: Icons.history_rounded,
                    iconColor: AppTheme.textMuted,
                    child: pref.recentCities.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'Nessuna ricerca recente',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              ...pref.recentCities.map((c) => _InfoTile(
                                    label: c,
                                    value: '',
                                    icon: Icons.location_on_rounded,
                                  )),
                              const _Divider(),
                              _ActionTile(
                                label: 'Cancella Cronologia',
                                subtitle: '',
                                icon: Icons.delete_outline_rounded,
                                destructive: true,
                                onTap: pref.clearRecentCities,
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),
                  _buildAbout(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return const SliverAppBar(
      pinned: true,
      backgroundColor: AppTheme.bg,
      elevation: 0,
      title: Text(
        'Impostazioni',
        style: TextStyle(
          fontFamily: 'Syne',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildProfileCard(PreferencesProvider pref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1A10), Color(0xFF13161F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.amber.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppTheme.amberGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FuelScout',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 12, color: AppTheme.amber),
                    const SizedBox(width: 4),
                    Text(
                      pref.savedCity,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.green.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'v1.0',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.green,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Icon(icon, size: 15, color: iconColor),
              const SizedBox(width: 7),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: iconColor,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildAbout() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppTheme.amberGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FuelScout',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    'Versione 1.0.0 · Dati aggiornati in tempo reale',
                    style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'FuelScout aggrega prezzi da stazioni di servizio verificate. '
            'I prezzi vengono aggiornati ogni ora grazie ai contributi della community.',
            style:
                TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ── Section tiles ─────────────────────────────────────────────────────────

class _FuelDefaultPicker extends StatelessWidget {
  final PreferencesProvider pref;
  const _FuelDefaultPicker({required this.pref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: FuelType.values.map((t) {
          final selected = pref.defaultFuel == t;
          return GestureDetector(
            onTap: () => pref.setDefaultFuel(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? t.color.withValues(alpha: 0.15)
                    : AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? t.color : AppTheme.cardBorder,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(t.icon,
                      size: 14, color: selected ? t.color : AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    t.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? t.color : AppTheme.textSecondary,
                    ),
                  ),
                  if (selected) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.check_circle_rounded, size: 12, color: t.color),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.amber,
            inactiveTrackColor: AppTheme.cardBorder,
          ),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.amberGlow,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.amber,
                  ),
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
              value: value,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Syne',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool destructive;

  const _ActionTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppTheme.red : AppTheme.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textMuted),
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 13, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}

class _SegmentedTile extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const _SegmentedTile({
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppTheme.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              children: options.map((o) {
                final active = o == selected;
                return GestureDetector(
                  onTap: () => onChanged(o),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: active ? AppTheme.amber : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      o,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: active ? AppTheme.bg : AppTheme.textMuted,
                        fontFamily: 'Syne',
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: AppTheme.cardBorder, height: 1),
    );
  }
}
