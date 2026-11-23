import 'dart:convert';

class Pet {
  final String id;
  final String nome;
  final String tipo; // cachorro | gato | outros
  final String porte; // pequeno | medio | grande
  final String faixa; // filhote | adulto | idoso
  final String sexo; // macho | femea
  final bool castrado;
  final bool vacinado;
  final String raca;
  final String anos;
  final String descricao;
  final String local;
  final String temperamento; // docil | calma | brincalhao | carinhoso | energico
  final String? asset; // imagem do app
  final String? foto; // imagem enviada pelo usuário (base64)
  final bool meu;
  final bool favorito; // vindo da API

  const Pet({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.porte,
    required this.faixa,
    required this.sexo,
    required this.castrado,
    required this.vacinado,
    required this.raca,
    required this.anos,
    required this.descricao,
    required this.local,
    required this.temperamento,
    this.asset,
    this.foto,
    this.meu = false,
    this.favorito = false,
  });

  /// Pet vindo da API. As fotos dos pets cadastrados ficam em assets/.
  factory Pet.fromApi(Map<String, dynamic> j) => Pet(
        id: '${j['id']}',
        nome: j['nome'],
        tipo: j['tipo'],
        porte: j['porte'],
        faixa: j['faixa'],
        sexo: j['sexo'],
        castrado: j['castrado'],
        vacinado: j['vacinado'],
        raca: j['raca'],
        anos: j['anos'],
        descricao: j['descricao'],
        local: j['local'],
        temperamento: j['temperamento'],
        asset: j['imagem'] == null ? null : 'assets/${j['imagem']}',
        favorito: j['favorito'] == true,
      );

  String get sexoLabel => sexo == 'macho' ? 'Macho' : 'Fêmea';
  String get porteLabel => const {'pequeno': 'Pequeno', 'medio': 'Médio', 'grande': 'Grande'}[porte] ?? porte;
  String get faixaLabel => const {'filhote': 'Filhote', 'adulto': 'Adulto', 'idoso': 'Idoso'}[faixa] ?? faixa;
  String get tempLabel => const {
        'docil': 'Dócil',
        'calma': 'Calmo',
        'brincalhao': 'Brincalhão',
        'carinhoso': 'Carinhoso',
        'energico': 'Enérgico',
      }[temperamento] ??
      temperamento;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'tipo': tipo,
        'porte': porte,
        'faixa': faixa,
        'sexo': sexo,
        'castrado': castrado,
        'vacinado': vacinado,
        'raca': raca,
        'anos': anos,
        'descricao': descricao,
        'local': local,
        'temperamento': temperamento,
        'foto': foto,
      };

  factory Pet.fromJson(Map<String, dynamic> j) => Pet(
        id: j['id'],
        nome: j['nome'],
        tipo: j['tipo'],
        porte: j['porte'],
        faixa: j['faixa'],
        sexo: j['sexo'],
        castrado: j['castrado'],
        vacinado: j['vacinado'],
        raca: j['raca'],
        anos: j['anos'],
        descricao: j['descricao'],
        local: j['local'],
        temperamento: j['temperamento'],
        foto: j['foto'],
        meu: true,
      );

  static String encodeList(List<Pet> l) => jsonEncode(l.map((e) => e.toJson()).toList());
  static List<Pet> decodeList(String s) => (jsonDecode(s) as List).map((e) => Pet.fromJson(e)).toList();
}

class Story {
  final String nome, pet, texto, asset;
  final int nota;
  const Story(this.nome, this.pet, this.texto, this.asset, this.nota);
}

const stories = <Story>[
  Story('Ana Carolina', 'Thor', 'Adotar o Thor foi a melhor decisão da minha vida. Ele trouxe alegria e amor para nossa casa todos os dias.', 'assets/thor.jpg', 5),
  Story('Carlos Eduardo', 'Mel', 'Depois que a Mel chegou trouxe alegria pra casa. Ela é nossa companheira fiel e cheia de energia.', 'assets/vitalata.jpg', 4),
  Story('Família Silva', 'Luna', 'A Luna se tornou parte da nossa família. Nossos filhos adoram brincar com ela e ela é muito carinhosa.', 'assets/siames.jpg', 5),
];
