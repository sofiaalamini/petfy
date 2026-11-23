import { criarApp, hashSenha } from './app.js';
import { abrirBanco } from './db.js';

const porta = Number(process.env.PORT) || 3000;
const db = abrirBanco();

// Admin do grupo: definido por ADMIN_EMAIL / ADMIN_SENHA (no .env, nunca no código).
const { ADMIN_EMAIL, ADMIN_SENHA, ADMIN_NOME = 'Admin Petfy' } = process.env;
if (ADMIN_EMAIL && ADMIN_SENHA) {
  const email = ADMIN_EMAIL.trim().toLowerCase();
  const existe = db.prepare('SELECT id FROM usuarios WHERE email = ?').get(email);
  if (existe) db.prepare("UPDATE usuarios SET papel = 'admin', senha_hash = ? WHERE id = ?").run(hashSenha(ADMIN_SENHA), existe.id);
  else db.prepare("INSERT INTO usuarios (nome, email, senha_hash, papel) VALUES (?,?,?,'admin')").run(ADMIN_NOME, email, hashSenha(ADMIN_SENHA));
  console.log(`Admin pronto: ${email}`);
}

criarApp(db).listen(porta, '0.0.0.0', () => console.log(`Petfy API em http://localhost:${porta}`));
