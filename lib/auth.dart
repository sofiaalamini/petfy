import 'package:flutter/material.dart';

import 'api.dart';
import 'state.dart';
import 'theme.dart';
import 'widgets.dart';

enum _Stage { welcome, login, register }

class AuthFlow extends StatefulWidget {
  const AuthFlow({super.key});
  @override
  State<AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<AuthFlow> {
  _Stage stage = _Stage.welcome;

  @override
  Widget build(BuildContext context) {
    final c = context.pal;
    return Scaffold(
      body: Stack(children: [
        // Fundo: degradê quente + patinhas decorativas
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(color: c.accentSoft),
          ),
        ),
        Positioned(top: -30, right: -20, child: Icon(Icons.pets, size: 190, color: c.accent.withValues(alpha: .07))),
        Positioned(bottom: -40, left: -30, child: Transform.rotate(angle: -.4, child: Icon(Icons.pets, size: 230, color: c.accent.withValues(alpha: .07)))),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (w, a) => FadeTransition(opacity: a, child: SlideTransition(position: Tween(begin: const Offset(0, .04), end: Offset.zero).animate(a), child: w)),
                child: KeyedSubtree(
                  key: ValueKey(stage),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    decoration: BoxDecoration(color: c.surface.withValues(alpha: .88), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withValues(alpha: .5)), boxShadow: [BoxShadow(color: c.accent.withValues(alpha: .18), blurRadius: 40, offset: const Offset(0, 14))]),
                    child: switch (stage) {
                      _Stage.welcome => _welcome(context),
                      _Stage.login => _LoginForm(onBack: () => setState(() => stage = _Stage.welcome)),
                      _Stage.register => _RegisterForm(onBack: () => setState(() => stage = _Stage.welcome)),
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _welcome(BuildContext context) {
    final c = context.pal;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 8),
      const PetfyLogo(size: 56),
      const SizedBox(height: 6),
      Text('Conectando pets a famílias\nque oferecem amor.', textAlign: TextAlign.center, style: TextStyle(color: c.muted, height: 1.4)),
      const SizedBox(height: 28),
      SizedBox(width: double.infinity, child: GradButton(label: 'Entrar', onPressed: () => setState(() => stage = _Stage.login))),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => setState(() => stage = _Stage.register),
          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52), foregroundColor: c.accent, side: BorderSide(color: c.accent, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          child: Text.rich(TextSpan(text: 'Não tem uma conta? ', children: [TextSpan(text: 'Clique aqui', style: const TextStyle(fontWeight: FontWeight.w900, decoration: TextDecoration.underline))])),
        ),
      ),
      const SizedBox(height: 22),
      Row(children: [
        Expanded(child: Divider(color: c.line)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('ou continue com', style: TextStyle(color: c.muted, fontSize: 13))),
        Expanded(child: Divider(color: c.line)),
      ]),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _Social(onTap: () => context.toast('Login com Google em breve'), child: const _GoogleG()),
        const SizedBox(width: 16),
        _Social(onTap: () => context.toast('Login com Facebook em breve'), child: const Text('f', style: TextStyle(color: Color(0xFF1877F2), fontSize: 26, fontWeight: FontWeight.w900))),
      ]),
    ]);
  }
}

class _Social extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Social({required this.child, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        shape: CircleBorder(side: BorderSide(color: context.pal.line, width: 2)),
        elevation: 1.5,
        child: InkWell(customBorder: const CircleBorder(), onTap: onTap, child: SizedBox(width: 56, height: 56, child: Center(child: child))),
      );
}

class _GoogleG extends StatelessWidget {
  const _GoogleG();
  @override
  Widget build(BuildContext context) => ShaderMask(
        shaderCallback: (r) => const SweepGradient(colors: [Color(0xFF4285F4), Color(0xFF34A853), Color(0xFFFBBC05), Color(0xFFEA4335), Color(0xFF4285F4)]).createShader(r),
        blendMode: BlendMode.srcIn,
        child: const Text('G', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
      );
}

class _Head extends StatelessWidget {
  final VoidCallback onBack;
  const _Head({required this.onBack});
  @override
  Widget build(BuildContext context) => Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(onPressed: onBack, icon: const Icon(Icons.arrow_back_ios_new, size: 16), label: const Text('Voltar'), style: TextButton.styleFrom(foregroundColor: context.pal.accent, textStyle: const TextStyle(fontWeight: FontWeight.w700))),
        ),
        const PetfyLogo(size: 48),
        const SizedBox(height: 22),
      ]);
}

class _LoginForm extends StatefulWidget {
  final VoidCallback onBack;
  const _LoginForm({required this.onBack});
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final user = TextEditingController(), pass = TextEditingController();
  bool ver = false, busy = false;
  String? erro;

  Future<void> _entrar() async {
    if (user.text.trim().isEmpty || pass.text.isEmpty) {
      setState(() => erro = 'Informe e-mail e senha para entrar.');
      return;
    }
    setState(() {
      busy = true;
      erro = null;
    });
    try {
      await context.app.login(user.text.trim(), pass.text);
    } on ApiException catch (e) {
      if (mounted) setState(() => erro = e.mensagem);
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pal;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _Head(onBack: widget.onBack),
      TextField(controller: user, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, autofillHints: const [AutofillHints.email], decoration: InputDecoration(hintText: 'E-mail', prefixIcon: Icon(Icons.person_outline, color: c.accent))),
      const SizedBox(height: 14),
      TextField(
        controller: pass,
        obscureText: !ver,
        onSubmitted: (_) => _entrar(),
        autofillHints: const [AutofillHints.password],
        decoration: InputDecoration(hintText: 'Senha', prefixIcon: Icon(Icons.lock_outline, color: c.accent), suffixIcon: IconButton(icon: Icon(ver ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: c.muted), tooltip: ver ? 'Ocultar senha' : 'Mostrar senha', onPressed: () => setState(() => ver = !ver))),
      ),
      if (erro != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(erro!, style: TextStyle(color: c.danger, fontWeight: FontWeight.w700))),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: GradButton(label: busy ? 'Entrando...' : 'Entrar', onPressed: busy ? null : _entrar)),
      const SizedBox(height: 8),
      TextButton(onPressed: () => context.toast('Recuperação de senha em breve'), child: Text('Esqueceu a senha?', style: TextStyle(color: c.accent, fontWeight: FontWeight.w700))),
    ]);
  }
}

class _RegisterForm extends StatefulWidget {
  final VoidCallback onBack;
  const _RegisterForm({required this.onBack});
  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final nome = TextEditingController(), email = TextEditingController(), pass = TextEditingController();
  String? erro;
  bool busy = false;

  Future<void> _criar() async {
    if (nome.text.trim().isEmpty) return setState(() => erro = 'Informe seu nome.');
    if (!email.text.contains('@')) return setState(() => erro = 'Informe um e-mail válido.');
    if (pass.text.length < 4) return setState(() => erro = 'A senha precisa ter ao menos 4 caracteres.');
    setState(() {
      busy = true;
      erro = null;
    });
    try {
      await context.app.cadastrar(nome.text.trim(), email.text.trim(), pass.text);
    } on ApiException catch (e) {
      if (mounted) setState(() => erro = e.mensagem);
    }
    if (mounted) setState(() => busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pal;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _Head(onBack: widget.onBack),
      TextField(controller: nome, textCapitalization: TextCapitalization.words, textInputAction: TextInputAction.next, decoration: InputDecoration(hintText: 'Seu nome', prefixIcon: Icon(Icons.person_outline, color: c.accent))),
      const SizedBox(height: 14),
      TextField(controller: email, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, decoration: InputDecoration(hintText: 'E-mail', prefixIcon: Icon(Icons.mail_outline, color: c.accent))),
      const SizedBox(height: 14),
      TextField(controller: pass, obscureText: true, onSubmitted: (_) => _criar(), decoration: InputDecoration(hintText: 'Senha (mín. 4 caracteres)', prefixIcon: Icon(Icons.lock_outline, color: c.accent))),
      if (erro != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(erro!, style: TextStyle(color: c.danger, fontWeight: FontWeight.w700))),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: GradButton(label: busy ? 'Criando...' : 'Criar conta', onPressed: busy ? null : _criar)),
    ]);
  }
}
