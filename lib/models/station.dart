import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum FuelType {
  gasoline95,
  gasoline98,
  diesel,
  dieselPlus,
  lpg,
  electric,
  hydrogen,
}

extension FuelTypeExt on FuelType {
  String get label {
    switch (this) {
      case FuelType.gasoline95: return 'Benzina 95';
      case FuelType.gasoline98: return 'Benzina 98';
      case FuelType.diesel:     return 'Gasolio';
      case FuelType.dieselPlus: return 'Gasolio+';
      case FuelType.lpg:        return 'GPL';
      case FuelType.electric:   return 'Elettrico';
      case FuelType.hydrogen:   return 'Idrogeno';
    }
  }

  String get shortLabel {
    switch (this) {
      case FuelType.gasoline95: return '95';
      case FuelType.gasoline98: return '98';
      case FuelType.diesel:     return 'DSL';
      case FuelType.dieselPlus: return 'DSL+';
      case FuelType.lpg:        return 'GPL';
      case FuelType.electric:   return 'EV';
      case FuelType.hydrogen:   return 'H2';
    }
  }

  String get unit {
    if (this == FuelType.electric) return 'EUR/kWh';
    return 'EUR/L';
  }

  Color get color {
    switch (this) {
      case FuelType.gasoline95: return const Color(0xFFFFD54F);
      case FuelType.gasoline98: return const Color(0xFFFF8F00);
      case FuelType.diesel:     return const Color(0xFF4FC3F7);
      case FuelType.dieselPlus: return const Color(0xFF0288D1);
      case FuelType.lpg:        return const Color(0xFFAED581);
      case FuelType.electric:   return const Color(0xFF64FFDA);
      case FuelType.hydrogen:   return const Color(0xFFE040FB);
    }
  }

  IconData get icon {
    switch (this) {
      case FuelType.electric:   return Icons.bolt_rounded;
      case FuelType.lpg:        return Icons.local_fire_department_rounded;
      case FuelType.hydrogen:   return Icons.bubble_chart_rounded;
      default:                  return Icons.local_gas_station_rounded;
    }
  }
}

class FuelPrice {
  final FuelType type;
  final double price;
  final bool isSelf;
  final DateTime updatedAt;

  const FuelPrice({
    required this.type,
    required this.price,
    required this.isSelf,
    required this.updatedAt,
  });

  factory FuelPrice.fromJson(Map<String, dynamic> json) => FuelPrice(
    type: FuelType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => FuelType.gasoline95,
    ),
    price: (json['price'] as num).toDouble(),
    isSelf: json['isSelf'] as bool? ?? false,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

enum StationBrand {
  eni, q8, ip, tamoil, api, shell, totalenergies, beyfin, independent,
}

extension StationBrandExt on StationBrand {
  String get name {
    switch (this) {
      case StationBrand.eni:           return 'ENI';
      case StationBrand.q8:            return 'Q8';
      case StationBrand.ip:            return 'IP';
      case StationBrand.tamoil:        return 'Tamoil';
      case StationBrand.api:           return 'API';
      case StationBrand.shell:         return 'Shell';
      case StationBrand.totalenergies: return 'TotalEnergies';
      case StationBrand.beyfin:        return 'Beyfin';
      case StationBrand.independent:   return 'Indipendente';
    }
  }

  Color get color {
    switch (this) {
      case StationBrand.eni:           return const Color(0xFFFFCC00);
      case StationBrand.q8:            return const Color(0xFFFFC600);
      case StationBrand.ip:            return const Color(0xFF0057A8);
      case StationBrand.tamoil:        return const Color(0xFFE31E24);
      case StationBrand.api:           return const Color(0xFF0080C9);
      case StationBrand.shell:         return const Color(0xFFFFCC00);
      case StationBrand.totalenergies: return const Color(0xFFD32F2F);
      case StationBrand.beyfin:        return const Color(0xFF43A047);
      case StationBrand.independent:   return const Color(0xFF78909C);
    }
  }
}

class Station {
  final String id;
  final String name;
  final StationBrand brand;
  final LatLng location;
  final String address;
  final String city;
  final List<FuelPrice> prices;
  final double rating;
  final int reviewCount;
  final bool isOpen;
  final bool hasCarWash;
  final bool hasShop;
  final bool hasRestroom;
  final bool hasAir;
  final String? phone;
  final String? website;
  final Map<String, String> hours;
  final bool isFavorite;
  final double? distanceKm;

  const Station({
    required this.id,
    required this.name,
    required this.brand,
    required this.location,
    required this.address,
    required this.city,
    required this.prices,
    this.rating = 0,
    this.reviewCount = 0,
    this.isOpen = true,
    this.hasCarWash = false,
    this.hasShop = false,
    this.hasRestroom = false,
    this.hasAir = true,
    this.phone,
    this.website,
    this.hours = const {},
    this.isFavorite = false,
    this.distanceKm,
  });

  FuelPrice? priceFor(FuelType type) =>
      prices.where((p) => p.type == type).firstOrNull;

  double? lowestPrice() {
    if (prices.isEmpty) return null;
    return prices.map((p) => p.price).reduce((a, b) => a < b ? a : b);
  }

  Station copyWith({
    List<FuelPrice>? prices,
    bool? isFavorite,
    double? distanceKm,
  }) => Station(
    id: id,
    name: name,
    brand: brand,
    location: location,
    address: address,
    city: city,
    prices: prices ?? this.prices,
    rating: rating,
    reviewCount: reviewCount,
    isOpen: isOpen,
    hasCarWash: hasCarWash,
    hasShop: hasShop,
    hasRestroom: hasRestroom,
    hasAir: hasAir,
    phone: phone,
    website: website,
    hours: hours,
    isFavorite: isFavorite ?? this.isFavorite,
    distanceKm: distanceKm ?? this.distanceKm,
  );

  factory Station.fromJson(Map<String, dynamic> json) => Station(
    id: json['id'] as String,
    name: json['name'] as String,
    brand: StationBrand.values.firstWhere(
      (e) => e.name == json['brand'],
      orElse: () => StationBrand.independent,
    ),
    location: LatLng(
      (json['lat'] as num).toDouble(),
      (json['lng'] as num).toDouble(),
    ),
    address: json['address'] as String,
    city: json['city'] as String,
    prices: (json['prices'] as List<dynamic>)
        .map((p) => FuelPrice.fromJson(p as Map<String, dynamic>))
        .toList(),
    rating: (json['rating'] as num?)?.toDouble() ?? 0,
    reviewCount: json['reviewCount'] as int? ?? 0,
    isOpen: json['isOpen'] as bool? ?? true,
    hasCarWash: json['hasCarWash'] as bool? ?? false,
    hasShop: json['hasShop'] as bool? ?? false,
    hasRestroom: json['hasRestroom'] as bool? ?? false,
    hasAir: json['hasAir'] as bool? ?? true,
    phone: json['phone'] as String?,
    website: json['website'] as String?,
    hours: Map<String, String>.from(json['hours'] as Map? ?? {}),
  );
}
