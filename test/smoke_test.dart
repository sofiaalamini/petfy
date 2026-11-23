import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petfy/api.dart';
import 'package:petfy/main.dart';
import 'package:petfy/state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeApi extends Api {
  final adocoes = <String>[];
  Map<String, dynamic> pet(int id, String nome, String tipo) => {
        'id': id, 'nome': nome, 'tipo': tipo, 'porte': 'medio', 'faixa': 'adulto', 'sexo': 'macho', 'castrado': true,
        'vacinado': true, 'raca': 'SRD', 'anos': '3 anos', 'descricao': 'Um amor.', 'local': 'Cascavel - PR',
        'temperamento': 'docil', 'imagem': 'chicle.jpg', 'favorito': false,
      };
  @override
  Future<Map<String, dynamic>> login(String email, String senha) async {
    if (senha != '1234') throw ApiException('E-mail ou senha incorretos.', 401);
    return {'token': 't', 'usuario': {'id': 1, 'nome': 'Sofia', 'email': email}};
  }

  @override
  Future<List<Map<String, dynamic>>> pets() async => [pet(1, 'Chicle', 'gato'), pet(2, 'Lolla', 'cachorro')];
  @override
  Future<void> adocao(String petId, Map<String, dynamic> dados) async => adocoes.add(petId);
}

void main() {
  testWidgets('login com API, abas, filtro e adoção', (t) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    t.view.physicalSize = const Size(1080, 2200);
    t.view.devicePixelRatio = 2.75;
    final api = FakeApi();
    final st = AppState(await SharedPreferences.getInstance(), api: api);
    await t.pumpWidget(PetfyApp(state: st));
    await t.pumpAndSettle();
    expect(find.text('PETFY'), findsOneWidget);

    await t.tap(find.text('Entrar'));
    await t.pumpAndSettle();
    // senha errada mostra o erro da API
    await t.enterText(find.byType(TextField).at(0), 'sofia@teste.com');
    await t.enterText(find.byType(TextField).at(1), 'errada');
    await t.tap(find.text('Entrar').last);
    await t.pumpAndSettle();
    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);

    await t.enterText(find.byType(TextField).at(1), '1234');
    await t.tap(find.text('Entrar').last);
    await t.pumpAndSettle();
    expect(find.textContaining('Olá, Sofia'), findsOneWidget);
    expect(st.pets.length, 2);

    for (final l in ['Pets', 'Início']) {
      await t.tap(find.text(l).last, warnIfMissed: false);
      await t.pumpAndSettle();
    }
    await t.tap(find.text('Pets').last);
    await t.pumpAndSettle();
    await t.tap(find.text('Gatos'));
    await t.pumpAndSettle();
    expect(find.text('Chicle'), findsOneWidget);
    expect(find.text('Lolla'), findsNothing);
    await t.ensureVisible(find.text('Quero adotar').first);
    await t.pumpAndSettle();
    await t.tap(find.text('Quero adotar').first);
    await t.pumpAndSettle();
    expect(find.text('Formulário de adoção'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
