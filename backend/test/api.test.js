import assert from 'node:assert/strict';
import { after, before, test } from 'node:test';
import { criarApp } from '../src/app.js';
import { abrirBanco } from '../src/db.js';

let servidor, base, token, banco;
const chamar = async (metodo, caminho, corpo, tk = token) => {
  const r = await fetch(base + caminho, { method: metodo, headers: { 'content-type': 'application/json', ...(tk ? { authorization: `Bearer ${tk}` } : {}) }, body: corpo ? JSON.stringify(corpo) : undefined });
  return { status: r.status, json: await r.json() };
};

before(async () => {
  banco = abrirBanco(':memory:');
  servidor = criarApp(banco, { segredo: 'teste' }).listen(0);
  base = `http://localhost:${servidor.address().port}`;
});
after(() => servidor.close());

test('cadastro, login e rotas protegidas', async () => {
  assert.equal((await chamar('GET', '/pets', null, null)).status, 401);
  assert.equal((await chamar('POST', '/auth/cadastro', { nome: 'Sofia', email: 'x', senha: '1234' }, null)).status, 400);
  const c = await chamar('POST', '/auth/cadastro', { nome: 'Sofia', email: 'Sofia@Teste.com', senha: '1234' }, null);
  assert.equal(c.status, 201);
  assert.equal(c.json.usuario.email, 'sofia@teste.com');
  assert.equal((await chamar('POST', '/auth/cadastro', { nome: 'Outra', email: 'sofia@teste.com', senha: '1234' }, null)).status, 409);
  assert.equal((await chamar('POST', '/auth/login', { email: 'sofia@teste.com', senha: 'errada' }, null)).status, 401);
  const l = await chamar('POST', '/auth/login', { email: 'sofia@teste.com', senha: '1234' }, null);
  assert.equal(l.status, 200);
  token = l.json.token;
  assert.equal((await chamar('GET', '/auth/eu')).json.usuario.nome, 'Sofia');
});

test('lista e filtra pets', async () => {
  assert.equal((await chamar('GET', '/pets')).json.pets.length, 7);
  const gatos = (await chamar('GET', '/pets?tipo=gato')).json.pets;
  assert.deepEqual(gatos.map((p) => p.nome), ['Chicle', 'Luna', 'Bolinha']);
  assert.equal((await chamar('GET', '/pets?tipo=gato&faixa=idoso')).json.pets.length, 1);
  assert.equal((await chamar('GET', '/pets?castrado=nao')).json.pets[0].nome, 'Mel');
  assert.equal((await chamar('GET', '/pets?busca=curitiba')).json.pets[0].nome, 'Thor');
  assert.equal((await chamar('GET', '/pets?tipo=dragao')).status, 400);
  assert.equal((await chamar('GET', "/pets?busca=%27%20OR%201=1--")).json.pets.length, 0);
  assert.equal((await chamar('GET', '/pets/1')).json.pet.nome, 'Chicle');
  assert.equal((await chamar('GET', '/pets/999')).status, 404);
});

test('favoritos', async () => {
  assert.equal((await chamar('PUT', '/pets/2/favorito')).json.favorito, true);
  assert.equal((await chamar('PUT', '/pets/2/favorito')).status, 200);
  assert.equal((await chamar('GET', '/pets/2')).json.pet.favorito, true);
  assert.deepEqual((await chamar('GET', '/pets?favoritos=1')).json.pets.map((p) => p.id), [2]);
  await chamar('DELETE', '/pets/2/favorito');
  assert.equal((await chamar('GET', '/pets?favoritos=1')).json.pets.length, 0);
  assert.equal((await chamar('PUT', '/pets/999/favorito')).status, 404);
});

test('solicitação de adoção', async () => {
  const ok = { nome: 'Sofia', email: 'sofia@teste.com', telefone: '45999999999', endereco: 'Rua A, 1', motivo: 'Amo gatos' };
  assert.equal((await chamar('POST', '/pets/1/adocao', { ...ok, motivo: '' })).status, 400);
  assert.equal((await chamar('POST', '/pets/1/adocao', ok)).status, 201);
  assert.equal((await chamar('POST', '/pets/1/adocao', ok)).status, 409);
  assert.equal((await chamar('POST', '/pets/999/adocao', ok)).status, 404);
});

test('rota de admin é restrita', async () => {
  assert.equal((await chamar('GET', '/admin/solicitacoes')).status, 403);
  const { hashSenha } = await import('../src/app.js');
  banco.prepare("INSERT INTO usuarios (nome,email,senha_hash,papel) VALUES ('Adm','adm@petfy.com',?,'admin')").run(hashSenha('segredo1'));
  const l = await chamar('POST', '/auth/login', { email: 'adm@petfy.com', senha: 'segredo1' }, null);
  assert.equal(l.json.usuario.papel, 'admin');
  const r = await chamar('GET', '/admin/solicitacoes', null, l.json.token);
  assert.equal(r.status, 200);
  assert.equal(r.json.solicitacoes[0].pet_nome, 'Chicle');
});
