import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth.dart';
import 'shell.dart';
import 'state.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final state = AppState(prefs);
  await state.iniciar();
  runApp(PetfyApp(state: state));
}

class PetfyApp extends StatelessWidget {
  final AppState state;
  const PetfyApp({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
          title: 'Petfy',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(state.theme),
          // Tamanho da fonte escolhido em Acessibilidade (14–24, padrão 16).
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(state.fontSize / 16)),
            // Em telas largas (desktop) centraliza como um "celular".
            child: ColoredBox(
              color: context.pal.surface2,
              child: Center(
                child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: ClipRect(child: child)),
              ),
            ),
          ),
          home: state.logged ? const Shell() : const AuthFlow(),
        ),
      ),
    );
  }
}
