import 'package:flutter/material.dart';

import 'data.dart';
import 'shell.dart';
import 'state.dart';
import 'theme.dart';
import 'widgets.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.pal;
    final app = context.app;
    final dark = app.theme == 'escuro';
    final heroFg = dark ? const Color(0xFF1D140C) : Colors.white;
    final destaques = app.todos.take(6).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        // ---------- Hero ----------
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            decoration: BoxDecoration(gradient: c.grad, boxShadow: [BoxShadow(color: c.accent.withValues(alpha: .3), blurRadius: 24, offset: const Offset(0, 10))]),
            child: Stack(children: [
              Positioned(right: -18, top: -18, child: Transform.rotate(angle: .25, child: Icon(Icons.pets, size: 150, color: heroFg.withValues(alpha: .14)))),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Olá, ${app.primeiroNome} 👋', style: TextStyle(color: heroFg.withValues(alpha: .92), fontSize: 15)),
                  const SizedBox(height: 6),
                  Text('Dê um lar para um pet que precisa de amor', style: TextStyle(color: heroFg, fontSize: 28, fontWeight: FontWeight.w900, height: 1.12)),
                  const SizedBox(height: 10),
                  Text('Nossa missão é conectar animais abandonados a famílias amorosas. Junte-se a nós e mude uma vida!', style: TextStyle(color: heroFg.withValues(alpha: .94), height: 1.4)),
                  const SizedBox(height: 18),
                  Row(children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () => ShellState.of(context).goTab(1),
                        style: FilledButton.styleFrom(minimumSize: const Size(0, 48), backgroundColor: dark ? const Color(0xFF1D140C) : Colors.white, foregroundColor: dark ? c.accent2 : const Color(0xFF7A5130), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: const TextStyle(fontWeight: FontWeight.w700)),
                        child: const Text('Conheça os pets', textAlign: TextAlign.center),
                      ),
                    ),
                  ]),
                ]),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 14),

        // ---------- Estatísticas ----------
        Row(children: [
          Expanded(child: _Stat(3, 'Pets adotados')),
          const SizedBox(width: 10),
          Expanded(child: _Stat(app.todos.length, 'Pets disponíveis')),
          const SizedBox(width: 10),
          Expanded(child: _Stat(3, 'Famílias felizes')),
        ]),

        // ---------- Destaques ----------
        _SectionTitle('Pets em destaque', action: 'Ver todos', onAction: () => ShellState.of(context).goTab(1)),
        SizedBox(
          height: 206,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: destaques.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _MiniPet(destaques[i]),
          ),
        ),

        // ---------- Por que adotar ----------
        const _SectionTitle('Por que adotar?'),
        Text('Adotar um pet é um ato de amor que transforma vidas. Conheça os benefícios de dar um lar a um animal necessitado.', style: TextStyle(color: c.muted, height: 1.45)),
        const SizedBox(height: 12),
        const _Benefit(Icons.favorite_rounded, 'Você salva uma vida', 'Ao adotar, você dá uma segunda chance a um animal que precisa de um lar amoroso.'),
        const _Benefit(Icons.monitor_heart_rounded, 'Faz bem para a saúde', 'Estudos mostram que ter um pet reduz o estresse, a pressão arterial e aumenta o bem-estar.'),
        const _Benefit(Icons.savings_rounded, 'Economiza recursos', 'A adoção é mais acessível que a compra e ainda ajuda a reduzir o comércio ilegal de animais.'),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final String? action;
  final VoidCallback? onAction;
  const _SectionTitle(this.text, {this.action, this.onAction});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 26, bottom: 12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
          if (action != null) GestureDetector(onTap: onAction, child: Text(action!, style: TextStyle(color: context.pal.accent, fontWeight: FontWeight.w700))),
        ]),
      );
}

class _Stat extends StatelessWidget {
  final int value;
  final String label;
  const _Stat(this.value, this.label);
  @override
  Widget build(BuildContext context) {
    final c = context.pal;
    return Panel(
      radius: 18,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      child: Column(children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.toDouble()),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => Text('${v.round()}', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: c.accent, height: 1.1)),
        ),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: c.muted, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _MiniPet extends StatelessWidget {
  final Pet pet;
  const _MiniPet(this.pet);
  @override
  Widget build(BuildContext context) {
    final c = context.pal;
    return GestureDetector(
      onTap: () => showPetSheet(context, pet),
      child: Container(
        width: 152,
        decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: c.line), boxShadow: [BoxShadow(color: c.accent.withValues(alpha: .1), blurRadius: 12, offset: const Offset(0, 4))]),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 134, width: double.infinity, child: PetImage(pet)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(pet.nome, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              Text(pet.local, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: c.muted, fontSize: 12)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String title, text;
  const _Benefit(this.icon, this.title, this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Panel(
          radius: 18,
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconBubble(icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                const SizedBox(height: 2),
                Text(text, style: TextStyle(color: context.pal.muted, fontSize: 14, height: 1.4)),
              ]),
            ),
          ]),
        ),
      );
}
