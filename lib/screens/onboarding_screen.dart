import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/stations_provider.dart';
import '../providers/preferences_provider.dart';
import '../services/location_service.dart';
import 'main_shell.dart';
import 'package:latlong2/latlong.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int _page = 0;
  bool _locating = false;
  late PageController _ctrl;
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl      = PageController();
    _fadeCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeCtrl.forward();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 2) {
      _ctrl.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish({bool useLocation = false}) async {
    setState(() => _locating = true);
    final sp   = context.read<StationsProvider>();
    final pref = context.read<PreferencesProvider>();

    LatLng center = LatLng(pref.savedLat, pref.savedLng);

    if (useLocation) {
      final loc = await LocationService.getCurrentLocation();
      if (loc != null) center = loc;
    }

    await sp.loadStations(center);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, anim, __) => const MainShell(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(
            opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -80, right: -80,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.amber.withValues(alpha: 0.12), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100, left: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppTheme.cyan.withValues(alpha: 0.08), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: AppTheme.amberGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.local_fire_department_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'FuelScout',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Il carburante più conveniente vicino a te',
                  style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                ),

                // Pages
                Expanded(
                  child: PageView(
                    controller: _ctrl,
                    onPageChanged: (i) => setState(() => _page = i),
                    children: const [
                      _OnboardPage(
                        emoji: '⛽',
                        title: 'Prezzi in Tempo Reale',
                        description:
                            'Monitoriamo oltre 30.000 stazioni su tutto il territorio italiano. '
                            'Prezzi aggiornati ogni ora grazie alla nostra community.',
                        accentColor: AppTheme.amber,
                      ),
                      _OnboardPage(
                        emoji: '🗺️',
                        title: 'Mappa Interattiva',
                        description:
                            'Visualizza le stazioni sulla mappa con i prezzi in overlay. '
                            'Filtra per carburante, distanza, orari e servizi disponibili.',
                        accentColor: AppTheme.cyan,
                      ),
                      _OnboardPage(
                        emoji: '💰',
                        title: 'Risparmia Ogni Volta',
                        description:
                            'Trova il risparmio reale rispetto alla media di zona. '
                            'Salva le tue stazioni preferite e confronta i prezzi self-service.',
                        accentColor: AppTheme.green,
                      ),
                    ],
                  ),
                ),

                // Page indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => _Dot(active: i == _page, index: i)),
                ),
                const SizedBox(height: 32),

                // Actions
                if (_page < 2)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _ctrl.animateToPage(
                            2,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOutCubic,
                          ),
                          child: const Text(
                            'Salta',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _PrimaryButton(
                          label: 'Avanti',
                          onTap: _next,
                          icon: Icons.arrow_forward_rounded,
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _FullButton(
                          label: _locating ? 'Localizzazione…' : 'Usa la mia posizione',
                          icon: Icons.my_location_rounded,
                          loading: _locating,
                          gradient: AppTheme.amberGradient,
                          onTap: () => _finish(useLocation: true),
                        ),
                        const SizedBox(height: 10),
                        _FullButton(
                          label: 'Inserisci città manualmente',
                          icon: Icons.search_rounded,
                          loading: false,
                          gradient: const LinearGradient(
                            colors: [AppTheme.surfaceAlt, AppTheme.surfaceAlt],
                          ),
                          onTap: () => _finish(useLocation: false),
                          outlined: true,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Onboard Page ──────────────────────────────────────────────────────────

class _OnboardPage extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final Color accentColor;

  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.description,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Big emoji circle
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.1),
              border: Border.all(color: accentColor.withValues(alpha: 0.25), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.2),
                  blurRadius: 40,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 52)),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Syne',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  final int index;
  const _Dot({required this.active, required this.index});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: active ? 20 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active ? AppTheme.amber : AppTheme.cardBorder,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: AppTheme.amberGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.amberShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Syne',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Icon(icon, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

class _FullButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final LinearGradient gradient;
  final VoidCallback onTap;
  final bool outlined;

  const _FullButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.gradient,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: outlined ? null : gradient,
          color: outlined ? AppTheme.surfaceAlt : null,
          borderRadius: BorderRadius.circular(16),
          border: outlined
              ? Border.all(color: AppTheme.cardBorder)
              : null,
          boxShadow: outlined ? null : AppTheme.amberShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            else
              Icon(icon, size: 18,
                  color: outlined ? AppTheme.textSecondary : Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: outlined ? AppTheme.textSecondary : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
