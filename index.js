const axios = require('axios');
const csv = require('csv-parser');
const fs = require('fs');

// Inserisci i link diretti ai CSV del Ministero
const URL_IMPIANTI = 'https://www.mimit.gov.it/images/exportCSV/anagrafica_impianti_attivi.csv'; 
const URL_PREZZI = 'https://www.mimit.gov.it/images/exportCSV/prezzo_alle_8.csv';

async function scaricaEProcessa(url) {
    const risultati = [];
    const response = await axios({
        method: 'get',
        url: url,
        responseType: 'stream',
        headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0 Safari/537.36',
            'Accept': 'text/csv,application/csv,text/plain,*/*'
        }
    });

    return new Promise((resolve, reject) => {
        // Abbiamo cambiato il separatore da ';' a '|'
        response.data.pipe(csv({ separator: '|', skipLines: 1 }))
            .on('data', (data) => risultati.push(data))
            .on('end', () => resolve(risultati))
            .on('error', reject);
    });
}

async function generaAPI() {
    try {
        console.log("Scaricando anagrafica impianti dal Ministero...");
        const impianti = await scaricaEProcessa(URL_IMPIANTI);
        
        console.log("Scaricando prezzi praticati dal Ministero...");
        const prezzi = await scaricaEProcessa(URL_PREZZI);

        console.log("Elaborazione dati in corso...");
        const mappaImpianti = {};
        
        impianti.forEach(imp => {
            if(imp.idImpianto) {
                mappaImpianti[imp.idImpianto] = {
                    nome: imp.Bandiera,
                    indirizzo: imp.Indirizzo,
                    lat: imp.Latitudine,
                    lng: imp.Longitudine,
                    prezzi: []
                };
            }
        });

        prezzi.forEach(prezzo => {
            if (prezzo.idImpianto && mappaImpianti[prezzo.idImpianto]) {
                mappaImpianti[prezzo.idImpianto].prezzi.push({
                    tipo: prezzo.descCarburante,
                    prezzo: parseFloat(prezzo.prezzo),
                    modalita: prezzo.isSelf === '1' ? 'Self' : 'Servito'
                });
            }
        });

        const risultatoFinale = Object.values(mappaImpianti).filter(imp => imp.prezzi.length > 0);

        fs.writeFileSync('prezzi-italia.json', JSON.stringify(risultatoFinale, null, 2));
        console.log(`Successo! JSON generato con ${risultatoFinale.length} distributori.`);

    } catch (error) {
        console.error("Errore durante il download o l'elaborazione:", error.message);
    }
}

generaAPI();