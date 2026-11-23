import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';
import cors from 'cors';
import express from 'express';
import jwt from 'jsonwebtoken';

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const PASTA_IMAGENS = fileURLToPath(new URL('../../assets', import.meta.url));

export function hashSenha(senha) {
  const sal = crypto.randomBytes(16).toString('hex');
  return `${sal}:${crypto.scryptSync(senha, sal, 64).toString('hex')}`;
}
function confereSenha(senha, guardado) {
  const [sal, hash] = guardado.split(':');
  const novo = crypto.scryptSync(senha, sal, 64);
  const orig = Buffer.from(hash, 'hex');
  return orig.length === novo.length && crypto.timingSafeEqual(orig, novo);
}
const txt = (v, max = 200) => (typeof v === 'string' ? v.trim().slice(0, max) : '');

const petOut = (p, favs) => ({
  id: p.id, nome: p.nome, tipo: p.tipo, porte: p.porte, faixa: p.faixa, sexo: p.sexo,
  castrado: !!p.castrado, vacinado: !!p.vacinado, raca: p.raca, anos: p.anos,
  descricao: p.descricao, local: p.local, temperamento: p.temperamento, imagem: p.imagem,
  favorito: favs ? favs.has(p.id) : false,
});

export function criarApp(db, { segredo = process.env.JWT_SECRET } = {}) {
  if (!segredo) throw new Error('Defina JWT_SECRET (ex.: JWT_SECRET=uma-frase-longa npm start)');
  const app = express();
  app.use(cors());
  app.use(express.json({ limit: '50kb' }));

  const emitirToken = (u) => jwt.sign({ sub: u.id }, segredo, { expiresIn: '7d' });
  const usuarioOut = (u) => ({ id: u.id, nome: u.nome, email: u.email, papel: u.papel || 'usuario' });

  function auth(req, res, next) {
    const m = /^Bearer (.+)$/.exec(req.headers.authorization || '');
    if (!m) return res.status(401).json({ erro: 'Faça login para continuar.' });
    try {
      const { sub } = jwt.verify(m[1], segredo);
      const u = db.prepare('SELECT id, nome, email, papel FROM usuarios WHERE id = ?').get(sub);
      if (!u) throw new Error('usuario');
      req.usuario = u;
      next();
    } catch {
      res.status(401).json({ erro: 'Sessão expirada. Entre novamente.' });
    }
  }

  app.get('/saude', (_req, res) => res.json({ ok: true }));
  app.use('/imagens', express.static(PASTA_IMAGENS));

  // ---------- Autenticação ----------
  app.post('/auth/cadastro', (req, res) => {
    const nome = txt(req.body?.nome, 80);
    const email = txt(req.body?.email, 120).toLowerCase();
    const senha = req.body?.senha;
    if (!nome) return res.status(400).json({ erro: 'Informe seu nome.' });
    if (!EMAIL_RE.test(email)) return res.status(400).json({ erro: 'Informe um e-mail válido.' });
    if (typeof senha !== 'string' || senha.length < 4) return res.status(400).json({ erro: 'A senha precisa ter ao menos 4 caracteres.' });
    if (db.prepare('SELECT 1 FROM usuarios WHERE email = ?').get(email)) return res.status(409).json({ erro: 'Este e-mail já está cadastrado.' });
    const r = db.prepare('INSERT INTO usuarios (nome, email, senha_hash) VALUES (?,?,?)').run(nome, email, hashSenha(senha));
    const u = { id: Number(r.lastInsertRowid), nome, email };
    res.status(201).json({ token: emitirToken(u), usuario: usuarioOut(u) });
  });

  app.post('/auth/login', (req, res) => {
    const email = txt(req.body?.email, 120).toLowerCase();
    const senha = req.body?.senha;
    const u = typeof senha === 'string' && db.prepare('SELECT * FROM usuarios WHERE email = ?').get(email);
    if (!u || !confereSenha(senha, u.senha_hash)) return res.status(401).json({ erro: 'E-mail ou senha incorretos.' });
    res.json({ token: emitirToken(u), usuario: usuarioOut(u) });
  });

  app.get('/auth/eu', auth, (req, res) => res.json({ usuario: usuarioOut(req.usuario) }));

  // ---------- Pets ----------
  const FILTROS = {
    tipo: ['cachorro', 'gato', 'outros'],
    porte: ['pequeno', 'medio', 'grande'],
    faixa: ['filhote', 'adulto', 'idoso'],
    sexo: ['macho', 'femea'],
  };
  const favsDe = (id) => new Set(db.prepare('SELECT pet_id FROM favoritos WHERE usuario_id = ?').all(id).map((r) => r.pet_id));

  // Filtros: tipo, porte, faixa, sexo, castrado=sim|nao, vacinado=sim|nao, busca, favoritos=1
  app.get('/pets', auth, (req, res) => {
    const where = [];
    const args = [];
    for (const [campo, validos] of Object.entries(FILTROS)) {
      const v = req.query[campo];
      if (v === undefined || v === '') continue;
      if (!validos.includes(v)) return res.status(400).json({ erro: `Valor inválido para ${campo}.` });
      where.push(`${campo} = ?`);
      args.push(v);
    }
    for (const campo of ['castrado', 'vacinado']) {
      const v = req.query[campo];
      if (v === undefined || v === '') continue;
      if (!['sim', 'nao'].includes(v)) return res.status(400).json({ erro: `Valor inválido para ${campo}.` });
      where.push(`${campo} = ?`);
      args.push(v === 'sim' ? 1 : 0);
    }
    const busca = txt(req.query.busca, 60).toLowerCase().replace(/[%_]/g, '');
    if (busca) {
      where.push('(LOWER(nome) LIKE ? OR LOWER(raca) LIKE ? OR LOWER(local) LIKE ?)');
      args.push(`%${busca}%`, `%${busca}%`, `%${busca}%`);
    }
    if (req.query.favoritos === '1') {
      where.push('id IN (SELECT pet_id FROM favoritos WHERE usuario_id = ?)');
      args.push(req.usuario.id);
    }
    const sql = `SELECT * FROM pets ${where.length ? 'WHERE ' + where.join(' AND ') : ''} ORDER BY id`;
    const favs = favsDe(req.usuario.id);
    res.json({ pets: db.prepare(sql).all(...args).map((p) => petOut(p, favs)) });
  });

  app.get('/pets/:id', auth, (req, res) => {
    const p = db.prepare('SELECT * FROM pets WHERE id = ?').get(Number(req.params.id));
    if (!p) return res.status(404).json({ erro: 'Pet não encontrado.' });
    res.json({ pet: petOut(p, favsDe(req.usuario.id)) });
  });

  // ---------- Favoritos ----------
  const existePet = (id) => db.prepare('SELECT 1 FROM pets WHERE id = ?').get(id);
  app.put('/pets/:id/favorito', auth, (req, res) => {
    const id = Number(req.params.id);
    if (!existePet(id)) return res.status(404).json({ erro: 'Pet não encontrado.' });
    db.prepare('INSERT OR IGNORE INTO favoritos (usuario_id, pet_id) VALUES (?,?)').run(req.usuario.id, id);
    res.json({ favorito: true });
  });
  app.delete('/pets/:id/favorito', auth, (req, res) => {
    db.prepare('DELETE FROM favoritos WHERE usuario_id = ? AND pet_id = ?').run(req.usuario.id, Number(req.params.id));
    res.json({ favorito: false });
  });

  // ---------- Solicitações de adoção ----------
  app.post('/pets/:id/adocao', auth, (req, res) => {
    const id = Number(req.params.id);
    if (!existePet(id)) return res.status(404).json({ erro: 'Pet não encontrado.' });
    const b = req.body || {};
    const d = {
      nome: txt(b.nome, 80), email: txt(b.email, 120), telefone: txt(b.telefone, 30),
      endereco: txt(b.endereco, 160), motivo: txt(b.motivo, 600),
    };
    const faltando = Object.entries(d).find(([, v]) => !v);
    if (faltando) return res.status(400).json({ erro: `Preencha o campo: ${faltando[0]}.` });
    if (!EMAIL_RE.test(d.email)) return res.status(400).json({ erro: 'Informe um e-mail válido.' });
    if (db.prepare("SELECT 1 FROM solicitacoes WHERE usuario_id = ? AND pet_id = ? AND status = 'pendente'").get(req.usuario.id, id)) {
      return res.status(409).json({ erro: 'Você já enviou uma solicitação para este pet.' });
    }
    const r = db.prepare('INSERT INTO solicitacoes (usuario_id, pet_id, nome, email, telefone, endereco, motivo) VALUES (?,?,?,?,?,?,?)')
      .run(req.usuario.id, id, d.nome, d.email, d.telefone, d.endereco, d.motivo);
    res.status(201).json({ solicitacao: { id: Number(r.lastInsertRowid), pet_id: id, status: 'pendente' } });
  });

  // ---------- Admin ----------
  function soAdmin(req, res, next) {
    if (req.usuario.papel !== 'admin') return res.status(403).json({ erro: 'Acesso restrito a administradores.' });
    next();
  }
  app.get('/admin/solicitacoes', auth, soAdmin, (_req, res) => {
    const linhas = db.prepare(`SELECT s.id, s.status, s.criado_em, s.nome, s.email, s.telefone, s.endereco, s.motivo,
        p.id AS pet_id, p.nome AS pet_nome FROM solicitacoes s JOIN pets p ON p.id = s.pet_id ORDER BY s.id DESC`).all();
    res.json({ solicitacoes: linhas });
  });

  app.use((_req, res) => res.status(404).json({ erro: 'Rota não encontrada.' }));
  app.use((err, _req, res, _next) => {
    if (err.type === 'entity.parse.failed') return res.status(400).json({ erro: 'JSON inválido.' });
    console.error(err);
    res.status(500).json({ erro: 'Erro interno do servidor.' });
  });
  return app;
}
