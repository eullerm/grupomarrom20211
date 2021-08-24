class Questions {
  final List _questions = [
    {
      "id": 0,
      "question": "Quais países fazem parte do G-20?",
      "cards": {
        "Brasil": true,
        "Angola": false,
        "Alemanha": true,
        "Rússia": true,
        "Egito": false,
      },
    },
    {
      "id": 1,
      "question": "Quais países não fazem parte do G7?",
      "cards": {
        "Alemanha": false,
        "Egito": true,
        "França": false,
        "Rússia": true,
        "Japão": false,
      },
    },
    {
      "id": 2,
      "question": "Qual país possui a maior extensão territorial?",
      "cards": {
        "Brasil": false,
        "EUA": false,
        "China": false,
        "Rússia": true,
        "Índia": false,
      },
    },
    {
      "id": 3,
      "question": "Qual país possui o maior produto interno bruto nominal?",
      "cards": {
        "Brasil": false,
        "EUA": true,
        "China": false,
        "Egito": false,
        "Nigéria": false,
      },
    },
    {
      "id": 4,
      "question": "Qual país possui uma muralha de 21196 Km de extensão?",
      "cards": {
        "Alemanha": false,
        "EUA": false,
        "China": true,
        "Índia": false,
        "Nigéria": false,
      },
    },
  ];
  List get questions {
    return _questions;
  }
}
