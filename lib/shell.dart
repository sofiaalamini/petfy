import 'package:flutter/material.dart';

import 'home.dart';
import 'pets.dart';
import 'state.dart';
import 'theme.dart';
import 'widgets.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => ShellState();
}

class ShellState extends State<Shell> {
  int tab = 0;

  /// Troca de aba a partir de qualquer tela filha (`ShellState.of(context).goTab(1)`).
  static ShellState of(BuildContext c) => c.findAncestorStateOfType<ShellState>()!;
  void goTab(int i) {
    context.app.tap();
    setState(() => tab = i);
  }

  void _perfil() {
    final app = context.app;
    final c = context.pal;
    showModalBottomSheet(
      context: context,
      constraints: const BoxConstraints(maxWidth: 520),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircleAvatar(radius: 32, backgroundColor: c.accent, child: Text(app.inicial, style: TextStyle(color: c.onAccent, fontSize: 26, fontWeight: FontWeight.w900))),
            const SizedBox(height: 10),
            Text(app.userName.isEmpty ? 'Visitante' : app.userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            if (app.userEmail.isNotEmpty) Text(app.userEmail, style: TextStyle(color: c.muted)),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlineBtn(
                label: 'Sair',
                color: c.danger,
                onPressed: () {
                  Navigator.pop(ctx);
                  app.logout();
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pal;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: const Align(alignment: Alignment.centerLeft, child: PetfyLogo(size: 30)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Semantics(
              button: true,
              label: 'Perfil',
              child: GestureDetector(
                onTap: _perfil,
                child: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(gradient: c.grad, shape: BoxShape.circle, boxShadow: [BoxShadow(color: c.accent.withValues(alpha: .3), blurRadius: 8, offset: const Offset(0, 2))]),
                  child: Text(context.app.inicial, style: TextStyle(color: c.onAccent, fontWeight: FontWeight.w900, fontSize: 17)),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Divider(height: 1, color: c.line)),
      ),
      body: IndexedStack(index: tab, children: const [HomeTab(), PetsTab()]),
      bottomNavigationBar: _TabBar(index: tab, onTap: goTab),
    );
  }
}

class _TabBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _TabBar({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.pal;
    Widget item(int i, IconData off, IconData on, String label) {
      final sel = index == i;
      return Expanded(
        child: Semantics(
          button: true,
          selected: sel,
          label: label,
          child: InkWell(
            onTap: () => onTap(i),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
                    decoration: BoxDecoration(color: sel ? c.accentSoft : Colors.transparent, borderRadius: BorderRadius.circular(99)),
                    child: Icon(sel ? on : off, size: 24, color: sel ? c.accent : c.muted),
                  ),
                  const SizedBox(height: 2),
                  Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: sel ? c.accent : c.muted)),
                ]),
              ),
            ),
          ),
        ),
      );
    }

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.1)),
      child: Container(
        decoration: BoxDecoration(color: c.surface, border: Border(top: BorderSide(color: c.line)), boxShadow: [BoxShadow(color: c.accent.withValues(alpha: .08), blurRadius: 20, offset: const Offset(0, -6))]),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 70,
            child: Row(children: [
              item(0, Icons.home_outlined, Icons.home_rounded, 'Início'),
              item(1, Icons.pets_outlined, Icons.pets, 'Pets'),
            ]),
          ),
        ),
      ),
    );
  }
}
