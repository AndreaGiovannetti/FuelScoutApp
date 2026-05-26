import 'package:flutter/material.dart';
// ATTENZIONE: Controlla che i nomi di questi file corrispondano a quelli che hai creato
import 'models/distributore.model.dart';
import 'services/api_service.dart';

void main() {
  runApp(const FuelScoutApp());
}

class FuelScoutApp extends StatelessWidget {
  const FuelScoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FuelScout',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const SchermataMappa(), 
    );
  }
}

class SchermataMappa extends StatefulWidget {
  const SchermataMappa({super.key});

  @override
  State<SchermataMappa> createState() => _SchermataMappaState();
}

class _SchermataMappaState extends State<SchermataMappa> {
  // Inizializziamo il nostro servizio API
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prezzi in Tempo Reale'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<Distributore>>(
        // Chiamiamo la funzione che va su internet a scaricare il JSON
        future: _apiService.fetchDistributori(),
        builder: (context, snapshot) {
          // 1. STATO: In caricamento (Mostra la rotellina)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Scaricando 12.000+ distributori..."),
                ],
              ),
            );
          } 
          // 2. STATO: Errore
          else if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          } 
          // 3. STATO: Dati vuoti
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nessun distributore trovato.'));
          }

          // 4. STATO: Dati scaricati con successo (Costruisce la lista)
          final distributori = snapshot.data!;
          
          return ListView.builder(
            itemCount: distributori.length,
            itemBuilder: (context, index) {
              final dist = distributori[index];
              
              // Prende il primo prezzo dell'elenco per mostrarlo nella scheda
              final primoPrezzo = dist.prezzi.isNotEmpty ? dist.prezzi.first : null;
              final testoPrezzo = primoPrezzo != null 
                  ? '${primoPrezzo.tipo}: €${primoPrezzo.prezzo.toStringAsFixed(3)} (${primoPrezzo.modalita})'
                  : 'Prezzo non disponibile';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.local_gas_station, color: Colors.blue),
                  title: Text(dist.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${dist.indirizzo}\n$testoPrezzo'),
                  isThreeLine: true,
                  onTap: () {
                    print("Hai cliccato: ${dist.nome}");
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}