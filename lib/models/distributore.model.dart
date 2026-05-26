class Distributore {
  final String nome;
  final String indirizzo;
  final double lat;
  final double lng;
  final List<Prezzo> prezzi;

  Distributore({
    required this.nome,
    required this.indirizzo,
    required this.lat,
    required this.lng,
    required this.prezzi,
  });

  // Funzione factory per trasformare il JSON in un oggetto Dart
  factory Distributore.fromJson(Map<String, dynamic> json) {
    var listaPrezzi = json['prezzi'] as List;
    List<Prezzo> prezziList = listaPrezzi.map((i) => Prezzo.fromJson(i)).toList();

    return Distributore(
      nome: json['nome'] ?? 'Sconosciuto',
      indirizzo: json['indirizzo'] ?? '',
      lat: double.tryParse(json['lat'].toString()) ?? 0.0,
      lng: double.tryParse(json['lng'].toString()) ?? 0.0,
      prezzi: prezziList,
    );
  }
}

class Prezzo {
  final String tipo;
  final double prezzo;
  final String modalita;

  Prezzo({
    required this.tipo,
    required this.prezzo,
    required this.modalita,
  });

  factory Prezzo.fromJson(Map<String, dynamic> json) {
    return Prezzo(
      tipo: json['tipo'] ?? '',
      prezzo: double.tryParse(json['prezzo'].toString()) ?? 0.0,
      modalita: json['modalita'] ?? 'Self',
    );
  }
}