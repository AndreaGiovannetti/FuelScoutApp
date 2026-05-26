import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/station.dart';

class PreferencesProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  // Defaults
  FuelType _defaultFuel    = FuelType.gasoline95;
  bool     _preferSelf     = false;
  bool     _showOpenOnly   = false;
  double   _defaultRadius  = 5.0;
  double   _savedLat       = 41.9028;
  double   _savedLng       = 12.4964;
  double   _savedZoom      = 13.0;
  String   _savedCity      = 'Roma';
  bool     _priceAlerts    = true;
  bool     _useDarkTheme   = true;
  String   _distanceUnit   = 'km';
  List<String> _recentCities = [];
  List<String> _favoriteIds  = [];

  // ── Getters ───────────────────────────────────────────────────────────────
  FuelType      get defaultFuel    => _defaultFuel;
  bool          get preferSelf     => _preferSelf;
  bool          get showOpenOnly   => _showOpenOnly;
  double        get defaultRadius  => _defaultRadius;
  double        get savedLat       => _savedLat;
  double        get savedLng       => _savedLng;
  double        get savedZoom      => _savedZoom;
  String        get savedCity      => _savedCity;
  bool          get priceAlerts    => _priceAlerts;
  bool          get useDarkTheme   => _useDarkTheme;
  String        get distanceUnit   => _distanceUnit;
  List<String>  get recentCities   => List.unmodifiable(_recentCities);
  List<String>  get favoriteIds    => List.unmodifiable(_favoriteIds);

  // ── Init ──────────────────────────────────────────────────────────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _load();
  }

  void _load() {
    if (_prefs == null) return;

    final fuelName = _prefs!.getString('defaultFuel');
    if (fuelName != null) {
      _defaultFuel = FuelType.values.firstWhere(
        (e) => e.name == fuelName,
        orElse: () => FuelType.gasoline95,
      );
    }

    _preferSelf    = _prefs!.getBool('preferSelf')   ?? false;
    _showOpenOnly  = _prefs!.getBool('showOpenOnly')  ?? false;
    _defaultRadius = _prefs!.getDouble('defaultRadius') ?? 5.0;
    _savedLat      = _prefs!.getDouble('savedLat')    ?? 41.9028;
    _savedLng      = _prefs!.getDouble('savedLng')    ?? 12.4964;
    _savedZoom     = _prefs!.getDouble('savedZoom')   ?? 13.0;
    _savedCity     = _prefs!.getString('savedCity')   ?? 'Roma';
    _priceAlerts   = _prefs!.getBool('priceAlerts')   ?? true;
    _useDarkTheme  = _prefs!.getBool('useDarkTheme')  ?? true;
    _distanceUnit  = _prefs!.getString('distanceUnit') ?? 'km';
    _recentCities  = _prefs!.getStringList('recentCities') ?? [];
    _favoriteIds   = _prefs!.getStringList('favoriteIds')  ?? [];

    notifyListeners();
  }

  // ── Setters ───────────────────────────────────────────────────────────────
  Future<void> setDefaultFuel(FuelType t) async {
    _defaultFuel = t;
    await _prefs?.setString('defaultFuel', t.name);
    notifyListeners();
  }

  Future<void> setPreferSelf(bool v) async {
    _preferSelf = v;
    await _prefs?.setBool('preferSelf', v);
    notifyListeners();
  }

  Future<void> setShowOpenOnly(bool v) async {
    _showOpenOnly = v;
    await _prefs?.setBool('showOpenOnly', v);
    notifyListeners();
  }

  Future<void> setDefaultRadius(double v) async {
    _defaultRadius = v;
    await _prefs?.setDouble('defaultRadius', v);
    notifyListeners();
  }

  Future<void> saveMapState(double lat, double lng, double zoom, String city) async {
    _savedLat  = lat;
    _savedLng  = lng;
    _savedZoom = zoom;
    _savedCity = city;
    await _prefs?.setDouble('savedLat', lat);
    await _prefs?.setDouble('savedLng', lng);
    await _prefs?.setDouble('savedZoom', zoom);
    await _prefs?.setString('savedCity', city);
    notifyListeners();
  }

  Future<void> setPriceAlerts(bool v) async {
    _priceAlerts = v;
    await _prefs?.setBool('priceAlerts', v);
    notifyListeners();
  }

  Future<void> setDistanceUnit(String u) async {
    _distanceUnit = u;
    await _prefs?.setString('distanceUnit', u);
    notifyListeners();
  }

  Future<void> addRecentCity(String city) async {
    _recentCities.remove(city);
    _recentCities.insert(0, city);
    if (_recentCities.length > 5) _recentCities = _recentCities.take(5).toList();
    await _prefs?.setStringList('recentCities', _recentCities);
    notifyListeners();
  }

  Future<void> clearRecentCities() async {
    _recentCities = [];
    await _prefs?.setStringList('recentCities', []);
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    await _prefs?.setStringList('favoriteIds', _favoriteIds);
    notifyListeners();
  }

  String formatDistance(double km) {
    if (_distanceUnit == 'mi') {
      final mi = km * 0.621371;
      return mi < 1
          ? '${(mi * 1760).toStringAsFixed(0)} yd'
          : '${mi.toStringAsFixed(1)} mi';
    }
    return km < 1
        ? '${(km * 1000).toStringAsFixed(0)} m'
        : '${km.toStringAsFixed(1)} km';
  }
}
