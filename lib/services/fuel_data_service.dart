import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../models/station.dart';

class FuelDataService {
  static final _rng = Random();

  // ── Mock data generator ────────────────────────────────────────────────

  static List<Station> generateStationsNear(LatLng center, {int count = 25}) {
    final stations = <Station>[];
    const brands = StationBrand.values;
    final names = [
      'FuelScout Station',
      'Centro Carburanti',
      'Distributore Rapido',
      'PriceStop',
      'EcoFuel',
      'SuperPetrol',
      'City Gas',
      'AutoFuel',
      'QuickStop',
      'GreenDrive',
      'MaxFuel',
      'SpeedFuel',
    ];
    final streets = [
      'Via Roma',
      'Corso Italia',
      'Via Mazzini',
      'Via Garibaldi',
      'Via Nazionale',
      'Via Vittorio Emanuele',
      'Via XX Settembre',
      'Viale della Repubblica',
      'Via del Commercio',
      'Corso Matteotti',
    ];

    for (int i = 0; i < count; i++) {
      final lat = center.latitude + (_rng.nextDouble() - 0.5) * 0.12;
      final lng = center.longitude + (_rng.nextDouble() - 0.5) * 0.16;
      final brand = brands[_rng.nextInt(brands.length)];
      final now = DateTime.now();

      // Realistic Italian prices (€/L) with slight random variance
      final baseGas95 = 1.72 + (_rng.nextDouble() - 0.5) * 0.18;
      final baseGas98 = baseGas95 + 0.12 + _rng.nextDouble() * 0.06;
      final baseDsl = 1.65 + (_rng.nextDouble() - 0.5) * 0.16;
      final baseDslP = baseDsl + 0.08 + _rng.nextDouble() * 0.04;
      final baseLpg = 0.78 + (_rng.nextDouble() - 0.5) * 0.08;
      final selfDisc = 0.02 + _rng.nextDouble() * 0.04; // self-service discount

      final hasSelf = _rng.nextBool();

      final prices = <FuelPrice>[
        FuelPrice(
          type: FuelType.gasoline95,
          price: double.parse(baseGas95.toStringAsFixed(3)),
          isSelf: false,
          updatedAt: now.subtract(Duration(minutes: _rng.nextInt(180))),
        ),
        if (hasSelf)
          FuelPrice(
            type: FuelType.gasoline95,
            price: double.parse((baseGas95 - selfDisc).toStringAsFixed(3)),
            isSelf: true,
            updatedAt: now.subtract(Duration(minutes: _rng.nextInt(180))),
          ),
        FuelPrice(
          type: FuelType.gasoline98,
          price: double.parse(baseGas98.toStringAsFixed(3)),
          isSelf: false,
          updatedAt: now.subtract(Duration(minutes: _rng.nextInt(180))),
        ),
        FuelPrice(
          type: FuelType.diesel,
          price: double.parse(baseDsl.toStringAsFixed(3)),
          isSelf: false,
          updatedAt: now.subtract(Duration(minutes: _rng.nextInt(180))),
        ),
        if (hasSelf)
          FuelPrice(
            type: FuelType.diesel,
            price: double.parse((baseDsl - selfDisc).toStringAsFixed(3)),
            isSelf: true,
            updatedAt: now.subtract(Duration(minutes: _rng.nextInt(180))),
          ),
        if (_rng.nextBool())
          FuelPrice(
            type: FuelType.dieselPlus,
            price: double.parse(baseDslP.toStringAsFixed(3)),
            isSelf: false,
            updatedAt: now.subtract(Duration(minutes: _rng.nextInt(180))),
          ),
        if (_rng.nextDouble() > 0.4)
          FuelPrice(
            type: FuelType.lpg,
            price: double.parse(baseLpg.toStringAsFixed(3)),
            isSelf: false,
            updatedAt: now.subtract(Duration(minutes: _rng.nextInt(180))),
          ),
      ];

      final dist = _distance(center, LatLng(lat, lng));

      stations.add(Station(
        id: 'st_$i',
        name: '${brand.name} — ${names[_rng.nextInt(names.length)]}',
        brand: brand,
        location: LatLng(lat, lng),
        address:
            '${streets[_rng.nextInt(streets.length)]} ${_rng.nextInt(150) + 1}',
        city: _cityFromCenter(center),
        prices: prices,
        rating: 3.5 + _rng.nextDouble() * 1.5,
        reviewCount: _rng.nextInt(350) + 5,
        isOpen: _rng.nextDouble() > 0.12,
        hasCarWash: _rng.nextDouble() > 0.5,
        hasShop: _rng.nextDouble() > 0.4,
        hasRestroom: _rng.nextDouble() > 0.3,
        hasAir: true,
        distanceKm: dist,
      ));
    }

    stations.sort((a, b) => (a.distanceKm ?? 99).compareTo(b.distanceKm ?? 99));

    return stations;
  }

  static double _distance(LatLng a, LatLng b) {
    const earthR = 6371.0;
    final dLat = _toRad(b.latitude - a.latitude);
    final dLng = _toRad(b.longitude - a.longitude);
    final hav = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(a.latitude)) *
            cos(_toRad(b.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    return 2 * earthR * asin(sqrt(hav));
  }

  static double _toRad(double deg) => deg * pi / 180;

  static String _cityFromCenter(LatLng c) {
    // Map rough coordinates to Italian cities
    if (c.latitude > 45) return 'Milano';
    if (c.latitude > 44) return 'Bologna';
    if (c.latitude > 43.5) return 'Firenze';
    if (c.latitude > 41.8 && c.longitude > 12.3) return 'Roma';
    if (c.latitude < 41) return 'Napoli';
    return 'Roma';
  }

  // ── City search ───────────────────────────────────────────────────────────

  static final List<Map<String, dynamic>> italianCities = [
    {'name': 'Roma', 'lat': 41.9028, 'lng': 12.4964},
    {'name': 'Milano', 'lat': 45.4654, 'lng': 9.1859},
    {'name': 'Napoli', 'lat': 40.8518, 'lng': 14.2681},
    {'name': 'Torino', 'lat': 45.0703, 'lng': 7.6869},
    {'name': 'Palermo', 'lat': 38.1157, 'lng': 13.3615},
    {'name': 'Genova', 'lat': 44.4056, 'lng': 8.9463},
    {'name': 'Bologna', 'lat': 44.4949, 'lng': 11.3426},
    {'name': 'Firenze', 'lat': 43.7696, 'lng': 11.2558},
    {'name': 'Bari', 'lat': 41.1171, 'lng': 16.8719},
    {'name': 'Catania', 'lat': 37.5079, 'lng': 15.0830},
    {'name': 'Venezia', 'lat': 45.4408, 'lng': 12.3155},
    {'name': 'Verona', 'lat': 45.4384, 'lng': 10.9916},
    {'name': 'Messina', 'lat': 38.1938, 'lng': 15.5540},
    {'name': 'Padova', 'lat': 45.4064, 'lng': 11.8768},
    {'name': 'Trieste', 'lat': 45.6495, 'lng': 13.7768},
    {'name': 'Brescia', 'lat': 45.5416, 'lng': 10.2118},
    {'name': 'Taranto', 'lat': 40.4644, 'lng': 17.2470},
    {'name': 'Reggio Calabria', 'lat': 38.1113, 'lng': 15.6474},
    {'name': 'Modena', 'lat': 44.6479, 'lng': 10.9256},
    {'name': 'Prato', 'lat': 43.8802, 'lng': 11.0966},
    {'name': 'Cagliari', 'lat': 39.2238, 'lng': 9.1217},
    {'name': 'Livorno', 'lat': 43.5489, 'lng': 10.3114},
    {'name': 'Parma', 'lat': 44.8015, 'lng': 10.3279},
    {'name': 'Perugia', 'lat': 43.1107, 'lng': 12.3908},
    {'name': 'Reggio Emilia', 'lat': 44.6989, 'lng': 10.6297},
    {'name': 'Ravenna', 'lat': 44.4184, 'lng': 12.2035},
    {'name': 'Ferrara', 'lat': 44.8381, 'lng': 11.6197},
    {'name': 'Rimini', 'lat': 44.0678, 'lng': 12.5695},
    {'name': 'Salerno', 'lat': 40.6824, 'lng': 14.7681},
    {'name': 'Foggia', 'lat': 41.4623, 'lng': 15.5445},
  ];

  static List<Map<String, dynamic>> searchCities(String query) {
    if (query.trim().isEmpty) return italianCities.take(8).toList();
    final q = query.toLowerCase().trim();
    return italianCities
        .where((c) => (c['name'] as String).toLowerCase().startsWith(q))
        .toList();
  }

  // ── Price analytics ───────────────────────────────────────────────────────

  static Map<FuelType, double> averagePrices(List<Station> stations) {
    final totals = <FuelType, double>{};
    final counts = <FuelType, int>{};

    for (final s in stations) {
      for (final p in s.prices) {
        if (!p.isSelf) {
          totals[p.type] = (totals[p.type] ?? 0) + p.price;
          counts[p.type] = (counts[p.type] ?? 0) + 1;
        }
      }
    }

    return {for (final t in totals.keys) t: totals[t]! / counts[t]!};
  }

  static Station? cheapestFor(List<Station> stations, FuelType type) {
    final valid = stations.where((s) => s.priceFor(type) != null).toList();
    if (valid.isEmpty) return null;
    valid.sort(
        (a, b) => a.priceFor(type)!.price.compareTo(b.priceFor(type)!.price));
    return valid.first;
  }

  static List<Station> topCheapest(List<Station> stations, FuelType type,
      {int limit = 5}) {
    final valid = stations.where((s) => s.priceFor(type) != null).toList()
      ..sort(
          (a, b) => a.priceFor(type)!.price.compareTo(b.priceFor(type)!.price));
    return valid.take(limit).toList();
  }
}
