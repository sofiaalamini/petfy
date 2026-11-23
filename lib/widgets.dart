import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'api.dart';
import 'data.dart';
import 'state.dart';
import 'theme.dart';

/// Logo PETFY (texto com degradê marrom — mantida igual à original).
class PetfyLogo extends StatelessWidget {
  final double size;
  final TextAlign align;
  const PetfyLogo({super.key, this.size = 52, this.align = TextAlign.center});
  @override
  Widget build(BuildContext context) {
    return Text('PETFY', textAlign: align, style: GoogleFonts.lato(fontSize: size, fontWeight: FontWeight.w700, letterSpacing: 1, color: context.pal.accent));
  }
}

class GradButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  const GradButton({super.key, required this.label, this.icon, this.onPressed});
  @override
  Widget build(BuildContext context) {
    final c = context.pal;
    return Opacity(
      opacity: onPressed == null ? .6 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: c.grad, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: c.accent.withValues(alpha: .32), blurRadius: 16, offset: const Offset(0, 6))]),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onPressed == null
                ? null
                : () {
                    context.app.tap();
                    onPressed!();
                  },
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              alignment: Alignment.center,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (icon != null) ...[Icon(icon, color: c.onAccent, size: 20), const SizedBox(width: 8)],
                Flexible(child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: c.onAccent, fontWeight: FontWeight.w700, fontSize: 16))),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  const OutlineBtn({super.key, required this.label, required this.onPressed, this.color});
  @override
  Widget build(BuildContext context) {
    final col = color ?? context.pal.accent;
    return OutlinedButton(
      onPressed: () {
        context.app.tap();
        onPressed();
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        foregroundColor: col,
        side: BorderSide(color: col, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
      child: Text(label, textAlign: TextAlign.center),
    );
  }
}

/// Container "cartão" padrão do app.
class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.radius = 22});
  @override
  Widget build(BuildContext context) {
    final c = context.pal;
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(radius), border: Border.all(color: c.line), boxShadow: [BoxShadow(color: c.accent.withValues(alpha: .08), blurRadius: 12, offset: const Offset(0, 3))]),
      child: child,
    );
  }
}

class IconBubble extends StatelessWidget {
  final IconData icon;
  final bool danger;
  const IconBubble(this.icon, {super.key, this.danger = false});
  @override
  Widget build(BuildContext context) {
    final c = context.pal;
    final col = danger ? c.danger : c.accent;
    return Container(width: 44, height: 44, decoration: BoxDecoration(color: danger ? col.withValues(alpha: .14) : c.accentSoft, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: col, size: 22));
  }
}

class ScreenHead extends StatelessWidget {
  final String title, subtitle;
  const ScreenHead(this.title, this.subtitle, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, height: 1.15)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: context.pal.muted, height: 1.4)),
        ]),
      );
}

/// Foto do pet (asset do app ou foto enviada pelo usuário).
class PetImage extends StatelessWidget {
  final Pet pet;
  final BoxFit fit;
  const PetImage(this.pet, {super.key, this.fit = BoxFit.cover});
  @override
  Widget build(BuildContext context) {
    final c = context.pal;
    final desc = 'Foto de ${pet.nome}, ${pet.tipo == 'gato' ? 'gato' : pet.tipo == 'cachorro' ? 'cachorro' : 'pet'} ${pet.raca}, ${pet.anos}';
    Widget img;
    if (pet.foto != null) {
      img = Image.memory(base64Decode(pet.foto!), fit: fit, width: double.infinity, height: double.infinity);
    } else if (pet.asset != null) {
      img = Image.asset(pet.asset!, fit: fit, width: double.infinity, height: double.infinity);
    } else {
      img = Container(color: c.surface2, child: Icon(Icons.pets, size: 48, color: c.accent2));
    }
    return Semantics(
      label: desc,
      image: true,
      child: Stack(fit: StackFit.expand, children: [
        img,
        // "Descrição de imagens" (Acessibilidade): legenda visível sobre a foto.
        if (context.app.descImg)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 22, 12, 8),
              decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87])),
              child: Text(desc, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ),
      ]),
    );
  }
}

class Tag extends StatelessWidget {
  final String text;
  final Color? bg, fg;
  const Tag(this.text, {super.key, this.bg, this.fg});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg ?? Colors.white.withValues(alpha: .94), borderRadius: BorderRadius.circular(99)),
        child: Text(text.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .4, color: fg ?? const Color(0xFF5A3A1E))),
      );
}

List<Widget> petTags(BuildContext context, Pet p) {
  final dalt = context.app.theme == 'daltonico';
  final macho = p.sexo == 'macho';
  return [
    Tag(p.tempLabel),
    Tag(p.sexoLabel,
        bg: dalt ? (macho ? const Color(0xFF0057A3) : const Color(0xFFE69F00)) : (macho ? const Color(0xFFDBEAFE) : const Color(0xFFFDE4EC)),
        fg: dalt ? (macho ? Colors.white : const Color(0xFF1A1200)) : (macho ? const Color(0xFF1D4ED8) : const Color(0xFFB4235A))),
    if (p.meu) Tag('Seu anúncio', bg: context.pal.accent, fg: context.pal.onAccent),
  ];
}

class FavButton extends StatelessWidget {
  final Pet pet;
  const FavButton(this.pet, {super.key});
  @override
  Widget build(BuildContext context) {
    final on = context.app.favoritos.contains(pet.id);
    final dalt = context.app.theme == 'daltonico';
    return Semantics(
      button: true,
      label: on ? 'Remover ${pet.nome} dos favoritos' : 'Favoritar ${pet.nome}',
      child: Material(
        color: Colors.white.withValues(alpha: .92),
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () async {
            final m = ScaffoldMessenger.of(context);
            final erro = await context.app.toggleFav(pet.id);
            if (erro != null) m.showSnackBar(SnackBar(content: Text(erro)));
          },
          child: SizedBox(
            width: 44,
            height: 44,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (w, a) => ScaleTransition(scale: a, child: w),
              child: Icon(on ? Icons.favorite : Icons.favorite_border, key: ValueKey(on), color: on ? (dalt ? const Color(0xFF0057A3) : const Color(0xFFE0245E)) : const Color(0xFF8A7567), size: 24),
            ),
          ),
        ),
      ),
    );
  }
}

class PetCard extends StatelessWidget {
  final Pet pet;
  const PetCard(this.pet, {super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.pal;
    return Panel(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () => showPetSheet(context, pet),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(fit: StackFit.expand, children: [
                Hero(tag: 'pet-${pet.id}', child: PetImage(pet)),
                Positioned(left: 12, bottom: context.app.descImg ? 44 : 12, child: Wrap(spacing: 6, children: petTags(context, pet))),
                Positioned(top: 10, right: 10, child: FavButton(pet)),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(pet.nome, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
              Text('${pet.raca} • ${pet.anos}', style: TextStyle(color: c.accent, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(pet.descricao, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: c.muted, height: 1.4)),
              const SizedBox(height: 8),
              Row(children: [
                Icon(Icons.place_outlined, size: 16, color: c.muted),
                const SizedBox(width: 4),
                Expanded(child: Text(pet.local, style: TextStyle(color: c.muted, fontSize: 13))),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => showPetSheet(context, pet),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48), foregroundColor: c.text, side: BorderSide(color: c.line, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: const Text('Ver detalhes', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: GradButton(label: 'Quero adotar', onPressed: () => showAdoptSheet(context, pet))),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ============ Detalhes do pet ============
Future<void> showPetSheet(BuildContext context, Pet pet) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 520),
    builder: (ctx) => AppScope(state: context.app, child: PetDetail(pet: pet, parent: context)),
  );
}

class PetDetail extends StatelessWidget {
  final Pet pet;
  final BuildContext parent;
  const PetDetail({super.key, required this.pet, required this.parent});
  @override
  Widget build(BuildContext context) {
    final c = context.pal;
    Widget fact(String l, String v) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.line), borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              Text(l.toUpperCase(), style: TextStyle(color: c.muted, fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: .3)),
              const SizedBox(height: 2),
              Text(v, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
            ]),
          ),
        );
    return ListenableBuilder(
      listenable: context.app,
      builder: (context, _) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(context).padding.bottom),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Stack(fit: StackFit.expand, children: [
                PetImage(pet),
                Positioned(left: 12, bottom: context.app.descImg ? 44 : 12, child: Wrap(spacing: 6, children: petTags(context, pet))),
                Positioned(top: 10, right: 10, child: FavButton(pet)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          Text(pet.nome, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          Text('${pet.raca} • ${pet.anos}', style: TextStyle(color: c.accent, fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.place_outlined, size: 18, color: c.muted),
            const SizedBox(width: 4),
            Text(pet.local, style: TextStyle(color: c.muted)),
          ]),
          const SizedBox(height: 16),
          Row(children: [fact('Porte', pet.porteLabel), const SizedBox(width: 8), fact('Idade', pet.faixaLabel), const SizedBox(width: 8), fact('Sexo', pet.sexoLabel)]),
          const SizedBox(height: 8),
          Row(children: [fact('Vacinado', pet.vacinado ? 'Sim' : 'Não'), const SizedBox(width: 8), fact('Castrado', pet.castrado ? 'Sim' : 'Não'), const SizedBox(width: 8), fact('Temperamento', pet.tempLabel)]),
          const SizedBox(height: 16),
          Text('Sobre ${pet.nome}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
          const SizedBox(height: 4),
          Text(pet.descricao, style: const TextStyle(height: 1.5, fontSize: 15.5)),
          const SizedBox(height: 20),
          Row(children: [
            if (pet.meu) ...[
              IconButton.outlined(
                onPressed: () async {
                  await context.app.removePet(pet.id);
                  if (context.mounted) Navigator.pop(context);
                  if (parent.mounted) parent.toast('Anúncio de ${pet.nome} removido');
                },
                style: IconButton.styleFrom(minimumSize: const Size(52, 52), foregroundColor: c.danger, side: BorderSide(color: c.danger, width: 2)),
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Remover anúncio',
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: GradButton(
                label: 'Quero adotar ${pet.nome}',
                icon: Icons.favorite,
                onPressed: () {
                  Navigator.pop(context);
                  showAdoptSheet(parent, pet);
                },
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ============ Formulário de adoção ============
Future<void> showAdoptSheet(BuildContext context, Pet pet) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 520),
    builder: (ctx) => AppScope(state: context.app, child: AdoptForm(pet: pet)),
  );
}

class AdoptForm extends StatefulWidget {
  final Pet pet;
  const AdoptForm({super.key, required this.pet});
  @override
  State<AdoptForm> createState() => _AdoptFormState();
}

class _AdoptFormState extends State<AdoptForm> {
  final _key = GlobalKey<FormState>();
  late final nome = TextEditingController(text: context.app.userName);
  late final email = TextEditingController(text: context.app.userEmail);
  final tel = TextEditingController(), end = TextEditingController(), motivo = TextEditingController();
  bool enviado = false, enviando = false;

  @override
  void dispose() {
    for (final c in [nome, email, tel, end, motivo]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_key.currentState!.validate()) return;
    setState(() => enviando = true);
    try {
      await context.app.enviarAdocao(widget.pet.id, {'nome': nome.text, 'email': email.text, 'telefone': tel.text, 'endereco': end.text, 'motivo': motivo.text});
      if (mounted) setState(() => enviado = true);
    } on ApiException catch (e) {
      if (mounted) context.toast(e.mensagem);
    }
    if (mounted) setState(() => enviando = false);
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null;

  @override
  Widget build(BuildContext context) {
    final c = context.pal;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    if (enviado) {
      return Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 28 + MediaQuery.of(context).padding.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(width: 84, height: 84, decoration: BoxDecoration(gradient: c.grad, shape: BoxShape.circle), child: Icon(Icons.check_rounded, color: c.onAccent, size: 48)),
          ),
          const SizedBox(height: 16),
          const Text('Solicitação enviada!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text('Entraremos em contato em breve para agendar sua visita com ${widget.pet.nome}.', textAlign: TextAlign.center, style: TextStyle(color: c.muted, height: 1.4)),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: GradButton(label: 'Voltar', onPressed: () => Navigator.pop(context))),
        ]),
      );
    }
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom + MediaQuery.of(context).padding.bottom),
      child: Form(
        key: _key,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ClipOval(child: SizedBox(width: 54, height: 54, child: PetImage(widget.pet))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Formulário de adoção', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                Text('Quero adotar ${widget.pet.nome}', style: TextStyle(color: c.accent, fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
          const SizedBox(height: 18),
          _f('Nome completo', nome, 'Digite seu nome completo', validator: _req, type: TextInputType.name, cap: TextCapitalization.words),
          _f('E-mail', email, 'seu@email.com', validator: (v) => (v == null || !v.contains('@')) ? 'Informe um e-mail válido' : null, type: TextInputType.emailAddress),
          _f('Telefone', tel, '(00) 00000-0000', validator: _req, type: TextInputType.phone),
          _f('Endereço', end, 'Rua, número, bairro', validator: _req, cap: TextCapitalization.words),
          _f('Por que você quer adotar ${widget.pet.nome}?', motivo, 'Conte um pouco sobre você e sua motivação...', validator: _req, lines: 4, cap: TextCapitalization.sentences),
          const SizedBox(height: 4),
          Row(children: [
            Expanded(flex: 2, child: OutlineBtn(label: 'Cancelar', onPressed: () => Navigator.pop(context), color: c.muted)),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: GradButton(
                label: enviando ? 'Enviando...' : 'Enviar solicitação',
                onPressed: enviando ? null : _enviar,
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _f(String label, TextEditingController ctl, String hint, {String? Function(String?)? validator, TextInputType? type, int lines = 1, TextCapitalization cap = TextCapitalization.none}) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: context.pal.muted)),
          const SizedBox(height: 6),
          TextFormField(controller: ctl, validator: validator, keyboardType: type, maxLines: lines, textCapitalization: cap, decoration: InputDecoration(hintText: hint)),
        ]),
      );
}
