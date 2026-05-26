import 'import_del_tuo_modello_qui/distributore.model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Il link ufficiale che abbiamo appena testato e che funziona
  static const String url = 'https://AndreaGiovannetti.github.io/FuelScoutApp/prezzi-italia.json';

  Future<List<Distributore>> fetchDistributori() async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Distributore> distributori = body
            .map((dynamic item) => Distributore.fromJson(item))
            .toList();
        return distributori;
      } else {
        throw Exception('Errore nel caricamento dei dati: ${response.statusCode}');
      }
    } catch (e) {
      print("Errore di connessione: $e");
      return [];
    }
  }
}