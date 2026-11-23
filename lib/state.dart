import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api.dart';
import 'data.dart';

class AppState extends ChangeNotifier {
  final SharedPreferences prefs;
  final Api api;
  AppState(this.prefs, {Api? api}) : api = api ?? Api() {
    this.api.token = prefs.getString('token');
    logged = this.api.token != null;
    userName = prefs.getString('userName') ?? '';
    userEmail = prefs.getString('userEmail') ?? '';
    theme = prefs.getString('theme') ?? 'padrao';
    fontSize = prefs.getDouble('fontSize') ?? 16;
    descImg = prefs.getBool('descImg') ?? false;
    feedback = prefs.getBool('feedback') ?? false;
    final raw = prefs.getString('meusPets');
    if (raw != null) {
      try {
        meusPets = Pet.decodeList(raw);
      } catch (_) {}
    }
  }

  bool logged = false;
  String userName = '', userEmail = '';
  String theme = 'padrao';
  double fontSize = 16;
  bool descImg = false, feedback = false;
  Set<String> favoritos = {};
  List<Pet> meusPets = []; // usado pelas telas em lib/futuro (anúncio local)

  List<Pet> pets = [];
  bool carregandoPets = false;
  String? erroPets;

  List<Pet> get todos => [...meusPets, ...pets];
  String get primeiroNome => userName.trim().isEmpty ? 'visitante' : userName.trim().split(' ').first;
  String get inicial => userName.trim().isEmpty ? 'P' : userName.trim()[0].toUpperCase();

  /// Ao abrir o app: valida a sessão guardada e carrega os pets.
  Future<void> iniciar() async {
    if (!logged) return;
    try {
      final u = (await api.eu())['usuario'] as Map<String, dynamic>;
      await _guardarUsuario(u);
    } on ApiException catch (e) {
      if (e.status == 401) {
        await logout();
        return;
      }
    }
    await carregarPets();
  }

  Future<void> _guardarUsuario(Map<String, dynamic> u) async {
    userName = u['nome'] as String;
    userEmail = u['email'] as String;
    await prefs.setString('userName', userName);
    await prefs.setString('userEmail', userEmail);
  }

  Future<void> _entrar(Map<String, dynamic> resp) async {
    api.token = resp['token'] as String;
    await prefs.setString('token', api.token!);
    await _guardarUsuario(resp['usuario'] as Map<String, dynamic>);
    logged = true;
    notifyListeners();
    carregarPets();
  }

  /// Lançam [ApiException] com a mensagem para mostrar ao usuário.
  Future<void> login(String email, String senha) async => _entrar(await api.login(email, senha));
  Future<void> cadastrar(String nome, String email, String senha) async => _entrar(await api.cadastro(nome, email, senha));

  Future<void> logout() async {
    logged = false;
    api.token = null;
    pets = [];
    favoritos = {};
    await prefs.remove('token');
    notifyListeners();
  }

  Future<void> carregarPets() async {
    carregandoPets = true;
    erroPets = null;
    notifyListeners();
    try {
      final lista = (await api.pets()).map(Pet.fromApi).toList();
      pets = lista;
      favoritos = {
        for (final p in lista) if (p.favorito) p.id,
      };
    } on ApiException catch (e) {
      if (e.status == 401) {
        await logout();
        return;
      }
      erroPets = e.mensagem;
    }
    carregandoPets = false;
    notifyListeners();
  }

  void setTheme(String t) {
    theme = t;
    prefs.setString('theme', t);
    notifyListeners();
  }

  void setFont(double v) {
    fontSize = v;
    prefs.setDouble('fontSize', v);
    notifyListeners();
  }

  void setDescImg(bool v) {
    descImg = v;
    prefs.setBool('descImg', v);
    notifyListeners();
  }

  void setFeedback(bool v) {
    feedback = v;
    prefs.setBool('feedback', v);
    notifyListeners();
  }

  /// Feedback sonoro/tátil (ligado em Acessibilidade).
  void tap() {
    if (!feedback) return;
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
  }

  /// Favorita/desfavorita na hora e confirma na API. Devolve mensagem de erro (ou null).
  Future<String?> toggleFav(String id) async {
    final virar = !favoritos.contains(id);
    virar ? favoritos.add(id) : favoritos.remove(id);
    tap();
    notifyListeners();
    if (meusPets.any((p) => p.id == id)) return null; // anúncio local
    try {
      await api.favoritar(id, virar);
      return null;
    } on ApiException catch (e) {
      virar ? favoritos.remove(id) : favoritos.add(id); // desfaz
      notifyListeners();
      return e.mensagem;
    }
  }

  Future<void> enviarAdocao(String petId, Map<String, dynamic> dados) => api.adocao(petId, dados);

  Future<void> addPet(Pet p) async {
    meusPets = [p, ...meusPets];
    await prefs.setString('meusPets', Pet.encodeList(meusPets));
    notifyListeners();
  }

  Future<void> removePet(String id) async {
    meusPets = meusPets.where((e) => e.id != id).toList();
    favoritos.remove(id);
    await prefs.setString('meusPets', Pet.encodeList(meusPets));
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child}) : super(notifier: state);
  static AppState of(BuildContext c) => c.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

extension AppCtx on BuildContext {
  AppState get app => AppScope.of(this);
  void toast(String msg) {
    final m = ScaffoldMessenger.of(this);
    m.hideCurrentSnackBar();
    m.showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center), duration: const Duration(seconds: 2)));
  }
}
