# Petfy — API (backend)

Node + Express + SQLite (`node:sqlite`, já embutido no Node ≥ 22.13). Sem banco para instalar.

## Rodar

```bash
cd backend
npm install
cp .env.example .env     # e troque o JWT_SECRET por uma frase longa
npm run dev              # http://localhost:3000
npm test                 # testes da API
```

O arquivo `petfy.db` é criado na primeira execução, já com os 7 pets iniciais.

## Rotas (todas JSON; exceto cadastro/login, exigem `Authorization: Bearer <token>`)

| Método | Rota | O que faz |
|---|---|---|
| POST | `/auth/cadastro` | `{nome, email, senha}` → `{token, usuario}` |
| POST | `/auth/login` | `{email, senha}` → `{token, usuario}` |
| GET | `/auth/eu` | usuário logado |
| GET | `/pets` | lista. Filtros: `tipo, porte, faixa, sexo, castrado=sim\|nao, vacinado=sim\|nao, busca, favoritos=1` |
| GET | `/pets/:id` | detalhe |
| PUT / DELETE | `/pets/:id/favorito` | favoritar / desfavoritar |
| POST | `/pets/:id/adocao` | `{nome, email, telefone, endereco, motivo}` → solicitação `pendente` |
| GET | `/imagens/<arquivo>` | fotos dos pets (pasta `assets/`) |
| GET | `/saude` | health check |

Erros vêm como `{ "erro": "mensagem em português" }`.

## Próximos semestres
Cadastrar pet (com upload de foto), histórias, contato/dúvidas e painel para aprovar solicitações.
