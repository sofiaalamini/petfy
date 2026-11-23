# Petfy

App de adoção de pets (Flutter) com API própria (Node + SQLite).

**Escopo desta entrega (25%):** login e cadastro, tela inicial, lista de pets com busca e filtros, detalhes do pet, favoritos e formulário de adoção.

## Estrutura
- `lib/` — app Flutter
- `backend/` — API (veja `backend/README.md`)
- `assets/` — fotos dos pets

## Rodar
```bash
# 1) back-end
cd backend && npm install && cp .env.example .env   # troque JWT_SECRET e a senha do admin
npm run dev                                          # http://localhost:3000

# 2) app (em outro terminal)
flutter pub get
flutter run -d chrome
# para outro endereço de API: flutter run --dart-define=API_URL=https://seu-back
```

Testes: `flutter test` (app) e `cd backend && npm test` (API).

Fotos: [Pexels](https://www.pexels.com) (licença livre).
