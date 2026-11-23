import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Endereço da API. Troque ao rodar/compilar:
///   flutter run --dart-define=API_URL=http://192.168.0.10:3000
const apiUrlPadrao = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3000');

class ApiException implements Exception {
  final String mensagem;
  final int? status;
  ApiException(this.mensagem, [this.status]);
  @override
  String toString() => mensagem;
}

/// Cliente HTTP da API do Petfy (backend/).
class Api {
  final String base;
  String? token;
  Api({this.base = apiUrlPadrao, this.token});

  Future<Map<String, dynamic>> _chamar(String metodo, String caminho, {Map<String, dynamic>? corpo}) async {
    final req = http.Request(metodo, Uri.parse('$base$caminho'))
      ..headers['content-type'] = 'application/json'
      ..headers['accept'] = 'application/json';
    if (token != null) req.headers['authorization'] = 'Bearer $token';
    if (corpo != null) req.body = jsonEncode(corpo);
    http.Response r;
    try {
      r = await http.Response.fromStream(await http.Client().send(req).timeout(const Duration(seconds: 15)));
    } on TimeoutException {
      throw ApiException('O servidor demorou para responder. Tente novamente.');
    } catch (_) {
      throw ApiException('Não foi possível conectar ao servidor. Verifique sua internet.');
    }
    Map<String, dynamic> json = {};
    try {
      json = jsonDecode(utf8.decode(r.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {}
    if (r.statusCode >= 400) throw ApiException((json['erro'] as String?) ?? 'Erro inesperado (${r.statusCode}).', r.statusCode);
    return json;
  }

  Future<Map<String, dynamic>> cadastro(String nome, String email, String senha) => _chamar('POST', '/auth/cadastro', corpo: {'nome': nome, 'email': email, 'senha': senha});
  Future<Map<String, dynamic>> login(String email, String senha) => _chamar('POST', '/auth/login', corpo: {'email': email, 'senha': senha});
  Future<Map<String, dynamic>> eu() => _chamar('GET', '/auth/eu');
  Future<List<Map<String, dynamic>>> pets() async => ((await _chamar('GET', '/pets'))['pets'] as List).cast<Map<String, dynamic>>();
  Future<void> favoritar(String id, bool on) => _chamar(on ? 'PUT' : 'DELETE', '/pets/$id/favorito');
  Future<void> adocao(String petId, Map<String, dynamic> dados) => _chamar('POST', '/pets/$petId/adocao', corpo: dados);
}
