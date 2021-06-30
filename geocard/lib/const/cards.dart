final List CARDS = [
  {
    "id": 0,
    "name": "Alemanha",
    "location": "Europa",
    "area": "357.386 Km²",
    "population": "83,02 M",
    "capital": "Berlim",
    "language": "Alemão",
    "coin": "Euro",
    "government": "República democrática parlamentarista",
    "leader": "Angela Merkel (desde 2005)",
    "typeOfLeader": "Chanceler",
    "division": [
      'Baden-Wurttemberg',
      'Baixa Saxônia',
      'Baviera',
      'Berlim',
      'Brandemburgo',
      'Bremen',
      'Eslésvico-Holsácia',
      'Hamburgo',
      'Hesse',
      'Mecklemburgo-Pomerânia Ocidental',
      'Renânia do Norte-Vestfália',
      'Renânia-Palatinado',
      'Sarre',
      'Saxônia',
      'Saxônia-Anhalt',
      'Turíngia'
    ],
    "typeOfDivision": "Estados",
    "pib": "3,861 trilhões USD (2019)",
    "pibPerCapita": "46.445,25 USD ‎(2019)",
    "growthRate": "0,6% mudança anual ‎(2019)",
    "publicDebt": "59,8% do PIB ‎(2019)",
  },
  {
    "id": 1,
    "name": "Japão",
    "location": "Ásia",
    "area": "377.975 km²",
    "population": "126,3 M",
    "capital": "Tóquio",
    "language": "japonês",
    "coin": "Iene",
    "government": "Monarquia parlamentarista",
    "leader": "Imperador Akhito",
    "minister": "Shinzō Abe",
    "typeOfLeader": "Monarca",
    "division": [
      'Hokkaidō',
      'Tōhoku',
      'Kansai',
      'Kantō',
      'Chūgoku',
      'Shikoku',
      'Chūbu',
      'Kyūshū e Okinawa'
    ],
    "typeOfDivision": "Províncias ",
    "pib": "5,082 trilhões USD (2019)",
    "pibPerCapita": "40.246,88 USD ‎(2019)",
    "growthRate": "0,7% mudança anual ‎(2019)",
    "publicDebt": "",
  },
  {
    "id": 2,
    "name": "Brasil",
    "location": "Ámerica do Sul",
    "area": "8.516.000 km²",
    "population": "211 M",
    "capital": "Brasília",
  },
  {
    "id": 3,
    "name": "EUA",
    "location": "Ámerica do Norte",
    "area": "9.834.000 km²",
    "population": "328 M",
    "capital": "Washington, D.C.",
  }
];

/*
for (key, value) in CARDS{
  database
          .collection("cards")
          .document(key)
          .setData(value)
          .timeout(Duration(seconds: 10))
          .whenComplete(
            () => setState(() {
              send = true;
            }),
          )
          .catchError((error) => print("$error"));}


  dataBase.collection('cards').snapshot();*/