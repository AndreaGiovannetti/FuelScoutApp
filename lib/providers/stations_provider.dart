import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/station.dart';
import '../services/fuel_data_service.dart';

enum LoadState { idle, loading, loaded, error }

class StationsProvider extends ChangeNotifier {
  List<Station>     _stations    = [];
  List<Station>     _filtered    = [];
  Station?          _selected;
  LoadState         _loadState   = LoadState.idle;
  String?           _errorMsg;
  LatLng            _mapCenter   = const LatLng(41.9028, 12.4964); // Rome default
  double            _mapZoom     = 13.0;
  FuelType          _activeFuel  = FuelType.gasoline95;
  bool              _selfOnly    = false;
  bool              _openOnly    = false;
  double            _maxRadiusKm = 5.0;
  String            _sortBy      = 'price'; // 'price' | 'distance' | 'rating'
  String            _searchQuery = '';

  // ── Getters ───────────────────────────────────────────────────────────────
  List<Station>  get stations    => _filtered;
  List<Station>  get allStations => _stations;
  Station?       get selected    => _selected;
  LoadState      get loadState   => _loadState;
  String?        get errorMsg    => _errorMsg;
  LatLng         get mapCenter   => _mapCenter;
  double         get mapZoom     => _mapZoom;
  FuelType       get activeFuel  => _activeFuel;
  bool           get selfOnly    => _selfOnly;
  bool           get openOnly    => _openOnly;
  double         get maxRadiusKm => _maxRadiusKm;
  String         get sortBy      => _sortBy;
  String         get searchQuery => _searchQuery;

  bool get isLoading => _loadState == LoadState.loading;

  List<Station> get favorites => _stations.where((s) => s.isFavorite).toList();

  Map<FuelType, double> get avgPrices =>
      FuelDataService.averagePrices(_stations);

  Station? get cheapestSelected =>
      FuelDataService.cheapestFor(_stations, _activeFuel);

  List<Station> get topCheapest =>
      FuelDataService.topCheapest(_stations, _activeFuel, limit: 5);

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<void> loadStations(LatLng center) async {
    _loadState  = LoadState.loading;
    _mapCenter  = center;
    _errorMsg   = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      _stations = FuelDataService.generateStationsNear(center, count: 30);
      _loadState = LoadState.loaded;
      _applyFilters();
    } catch (e) {
      _loadState = LoadState.error;
      _errorMsg  = e.toString();
      notifyListeners();
    }
  }

  Future<void> refresh() => loadStations(_mapCenter);

  // ── Map state ─────────────────────────────────────────────────────────────
  void setMapCenter(LatLng c, {double? zoom}) {
    _mapCenter = c;
    if (zoom != null) _mapZoom = zoom;
    notifyListeners();
  }

  void setMapZoom(double z) {
    _mapZoom = z;
    notifyListeners();
  }

  // ── Filter & sort ─────────────────────────────────────────────────────────
  void setActiveFuel(FuelType type) {
    _activeFuel = type;
    _applyFilters();
  }

  void setSelfOnly(bool v) {
    _selfOnly = v;
    _applyFilters();
  }

  void setOpenOnly(bool v) {
    _openOnly = v;
    _applyFilters();
  }

  void setMaxRadius(double km) {
    _maxRadiusKm = km;
    _applyFilters();
  }

  void setSortBy(String s) {
    _sortBy = s;
    _applyFilters();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    _applyFilters();
  }

  void _applyFilters() {
    var result = [..._stations];

    // Search
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((s) =>
          s.name.toLowerCase().contains(q) ||
          s.address.toLowerCase().contains(q) ||
          s.brand.name.toLowerCase().contains(q)).toList();
    }

    // Open only
    if (_openOnly) result = result.where((s) => s.isOpen).toList();

    // Radius
    result = result
        .where((s) => (s.distanceKm ?? 99) <= _maxRadiusKm)
        .toList();

    // Has selected fuel
    result = result
        .where((s) => s.prices.any((p) =>
            p.type == _activeFuel && (!_selfOnly || p.isSelf)))
        .toList();

    // Sort
    switch (_sortBy) {
      case 'price':
        result.sort((a, b) {
          final pa = _bestPrice(a);
          final pb = _bestPrice(b);
          return (pa ?? 99).compareTo(pb ?? 99);
        });
        break;
      case 'distance':
        result.sort((a, b) =>
            (a.distanceKm ?? 99).compareTo(b.distanceKm ?? 99));
        break;
      case 'rating':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    _filtered = result;
    notifyListeners();
  }

  double? _bestPrice(Station s) {
    final relevant = s.prices.where((p) =>
        p.type == _activeFuel && (!_selfOnly || p.isSelf));
    if (relevant.isEmpty) return null;
    return relevant.map((p) => p.price).reduce((a, b) => a < b ? a : b);
  }

  // ── Selection ─────────────────────────────────────────────────────────────
  void selectStation(Station? s) {
    _selected = s;
    notifyListeners();
  }

  // ── Favorites ─────────────────────────────────────────────────────────────
  void toggleFavorite(String stationId) {
    final idx = _stations.indexWhere((s) => s.id == stationId);
    if (idx < 0) return;
    final s = _stations[idx];
    _stations[idx] = s.copyWith(isFavorite: !s.isFavorite);
    _applyFilters();
  }

  // ── Price color helper ────────────────────────────────────────────────────
  /// Returns a colour for a price relative to the city average.
  static PriceLevel priceLevel(double price, double avg) {
    final diff = price - avg;
    if (diff < -0.05) return PriceLevel.cheap;
    if (diff >  0.05) return PriceLevel.expensive;
    return PriceLevel.average;
  }
}

enum PriceLevel { cheap, average, expensive }

extension PriceLevelExt on PriceLevel {
  String get label {
    switch (this) {
      case PriceLevel.cheap:     return 'Conveniente';
      case PriceLevel.average:   return 'Nella media';
      case PriceLevel.expensive: return 'Caro';
    }
  }
}
