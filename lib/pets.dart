import 'package:flutter/material.dart';

import 'data.dart';
import 'state.dart';
import 'theme.dart';
import 'widgets.dart';

class PetsTab extends StatefulWidget {
  const PetsTab({super.key});
  @override
  State<PetsTab> createState() => _PetsTabState();
}

class _PetsTabState extends State<PetsTab> {
  String busca = '';
  String tipo = ''; // '', cachorro, gato, outros, __fav
  final Map<String, String> filtros = {'porte': '', 'faixa': '', 'sexo': '', 'castrado': '', 'vacinado': ''};

  int get nFiltros => filtros.values.where((v) => v.isNotEmpty).length;

  List<Pet> aplicar(List<Pet> todos, Set<String> favs) {
    final q = busca.trim().toLowerCase();
    return todos.where((p) {
      if (tipo == '__fav' && !favs.contains(p.id)) return false;
      if (tipo.isNotEmpty && tipo != '__fav' && p.tipo != tipo) return false;
      if (filtros['porte']!.isNotEmpty && p.porte != filtros['porte']) return false;
      if (filtros['faixa']!.isNotEmpty && p.faixa != filtros['faixa']) return false;
      if (filtros['sexo']!.isNotEmpty && p.sexo != filtros['sexo']) return false;
      if (filtros['castrado']!.isNotEmpty && p.castrado != (filtros['castrado'] == 'sim')) return false;
      if (filtros['vacinado']!.isNotEmpty && p.vacinado != (filtros['vacinado'] == 'sim')) return false;
      if (q.isNotEmpty && !('${p.nome} ${p.raca} ${p.local}'.toLowerCase().contains(q))) return false;
      return true;
    }).toList();
  }

  void limpar() => setState(() {
        busca = '';
        tipo = '';
        filtros.updateAll((k, v) => '');
      });

  @override
  Widget build(BuildContext context) {
    final c = context.pal;
    final app = context.app;
    final lista = aplicar(app.todos, app.favoritos);

    if (app.todos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: app.carregandoPets
              ? const CircularProgressIndicator()
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.cloud_off_rounded, size: 56, color: c.accent2),
                  const SizedBox(height: 10),
                  const Text('Não foi possível carregar os pets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900), textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(app.erroPets ?? 'Nenhum pet cadastrado ainda.', textAlign: TextAlign.center, style: TextStyle(color: c.muted)),
                  const SizedBox(height: 16),
                  GradButton(label: 'Tentar novamente', icon: Icons.refresh_rounded, onPressed: app.carregarPets),
                ]),
        ),
      );
    }

    return RefreshIndicator(
      color: c.accent,
      onRefresh: app.carregarPets,
      child: CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const ScreenHead('Conheça nossos pets', 'Todos estão esperando por um lar cheio de amor. Toque em um pet para saber mais.'),
              Row(children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => busca = v),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome, raça ou cidade',
                      prefixIcon: Icon(Icons.search_rounded, color: c.muted),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Badge(
                  isLabelVisible: nFiltros > 0,
                  label: Text('$nFiltros'),
                  backgroundColor: c.accent,
                  textColor: c.onAccent,
                  child: Material(
                    color: c.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: c.line, width: 1.6)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: _abrirFiltros,
                      child: Tooltip(message: 'Filtros', child: SizedBox(width: 50, height: 50, child: Icon(Icons.tune_rounded, color: c.accent))),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(scrollDirection: Axis.horizontal, clipBehavior: Clip.none, children: [
                  for (final (v, l) in const [('', 'Todos'), ('cachorro', 'Cachorros'), ('gato', 'Gatos'), ('outros', 'Outros'), ('__fav', '♥ Favoritos')])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(l),
                        selected: tipo == v,
                        onSelected: (_) {
                          app.tap();
                          setState(() => tipo = v);
                        },
                        showCheckmark: false,
                        labelStyle: TextStyle(fontWeight: FontWeight.w700, color: tipo == v ? c.onAccent : c.muted),
                        selectedColor: c.accent,
                        backgroundColor: c.surface,
                        side: BorderSide(color: tipo == v ? c.accent : c.line, width: 1.5),
                        shape: const StadiumBorder(),
                      ),
                    ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(lista.length == 1 ? '1 pet encontrado' : '${lista.length} pets encontrados', style: TextStyle(color: c.muted, fontWeight: FontWeight.w700, fontSize: 13.5)),
              ),
            ]),
          ),
        ),
        if (lista.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(children: [
                Icon(tipo == '__fav' ? Icons.favorite_border : Icons.pets, size: 56, color: c.accent2),
                const SizedBox(height: 10),
                Text(tipo == '__fav' && busca.isEmpty && nFiltros == 0 ? 'Nenhum favorito ainda' : 'Nenhum pet encontrado', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(tipo == '__fav' && busca.isEmpty && nFiltros == 0 ? 'Toque no coração de um pet para salvá-lo aqui.' : 'Tente remover alguns filtros ou buscar por outro termo.', textAlign: TextAlign.center, style: TextStyle(color: c.muted)),
                const SizedBox(height: 16),
                OutlineBtn(label: 'Limpar filtros', onPressed: limpar),
              ]),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            sliver: SliverList.separated(
              itemCount: lista.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (_, i) => PetCard(lista[i]),
            ),
          ),
      ],
    ),
    );
  }

  void _abrirFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 520),
      builder: (ctx) => AppScope(
        state: context.app,
        child: StatefulBuilder(
          builder: (ctx, setSheet) {
            final c = ctx.pal;
            Widget grupo(String titulo, String chave, List<(String, String)> ops) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(titulo, style: TextStyle(fontWeight: FontWeight.w700, color: c.muted, fontSize: 13.5)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final (v, l) in [('', 'Qualquer'), ...ops])
                        ChoiceChip(
                          label: Text(l),
                          selected: filtros[chave] == v,
                          showCheckmark: false,
                          onSelected: (_) {
                            setSheet(() => filtros[chave] = v);
                            setState(() {});
                          },
                          labelStyle: TextStyle(fontWeight: FontWeight.w700, color: filtros[chave] == v ? c.accent : c.text),
                          selectedColor: c.accentSoft,
                          backgroundColor: c.surface,
                          side: BorderSide(color: filtros[chave] == v ? c.accent : c.line, width: 1.8),
                          shape: const StadiumBorder(),
                        ),
                    ]),
                  ]),
                );
            final n = aplicar(context.app.todos, context.app.favoritos).length;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(ctx).padding.bottom),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Expanded(child: Text('Filtros', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
                  TextButton(
                    onPressed: () {
                      setSheet(() => filtros.updateAll((k, v) => ''));
                      setState(() {});
                    },
                    child: Text('Limpar', style: TextStyle(color: c.accent, fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 8),
                grupo('Porte', 'porte', const [('pequeno', 'Pequeno'), ('medio', 'Médio'), ('grande', 'Grande')]),
                grupo('Idade', 'faixa', const [('filhote', 'Filhote'), ('adulto', 'Adulto'), ('idoso', 'Idoso')]),
                grupo('Sexo', 'sexo', const [('macho', 'Macho'), ('femea', 'Fêmea')]),
                grupo('Castrado', 'castrado', const [('sim', 'Sim'), ('nao', 'Não')]),
                grupo('Vacinado', 'vacinado', const [('sim', 'Sim'), ('nao', 'Não')]),
                SizedBox(width: double.infinity, child: GradButton(label: n == 1 ? 'Ver 1 pet' : 'Ver $n pets', onPressed: () => Navigator.pop(ctx))),
              ]),
            );
          },
        ),
      ),
    );
  }
}
