import { DatabaseSync } from 'node:sqlite';

export const PETS_INICIAIS = [
  ['Chicle', 'gato', 'medio', 'adulto', 'macho', 1, 1, 'Malhado Comum', '3 anos', 'Chicle é um amor de gato, super brincalhão e sociável. Adora crianças e outros animais. Sempre está pronto para uma brincadeira!', 'Cascavel - PR', 'brincalhao', 'chicle.jpg'],
  ['Lolla', 'cachorro', 'medio', 'adulto', 'femea', 1, 1, 'Vira-Lata', '5 anos', 'Lolla é muito amigável e carinhosa, ótima companhia para toda a família. É tranquila e adora receber carinho. Perfeita para um lar acolhedor.', 'Rio de Janeiro - RJ', 'carinhoso', 'lolla.jpg'],
  ['Thor', 'cachorro', 'medio', 'adulto', 'macho', 1, 1, 'Vira-Lata', '2 anos', 'Thor é um cãozinho cheio de energia e muito brincalhão. Adora correr no parque e fazer novos amigos. Perfeito para famílias ativas!', 'Curitiba - PR', 'energico', 'thor.jpg'],
  ['Mel', 'cachorro', 'pequeno', 'filhote', 'femea', 0, 1, 'Vira-Lata', '6 meses', 'Mel é uma filhotinha super brincalhona e curiosa. Adora explorar e brincar com brinquedos. Está aprendendo comandos básicos!', 'São Paulo - SP', 'brincalhao', 'vitalata.jpg'],
  ['Luna', 'gato', 'pequeno', 'adulto', 'femea', 1, 1, 'Siamês', '4 anos', 'Luna é uma gata muito tranquila e carinhosa. Adora receber carinho e ficar no colo. Perfeita para quem busca um companheiro calmo e afetuoso.', 'Belo Horizonte - MG', 'carinhoso', 'siames.jpg'],
  ['Max', 'cachorro', 'grande', 'adulto', 'macho', 1, 1, 'Labrador Retriever', '3 anos', 'Max é um cão muito dócil, leal e obediente. Adora atividades ao ar livre, nadar e brincar com crianças. É muito inteligente e aprende rápido!', 'Porto Alegre - RS', 'docil', 'labrador.jpg'],
  ['Bolinha', 'gato', 'medio', 'idoso', 'macho', 1, 1, 'Persa', '8 anos', 'Bolinha é um gato idoso muito tranquilo e independente. Prefere ambientes calmos e adora descansar ao sol. Ideal para quem busca um companheiro sossegado.', 'Florianópolis - SC', 'calma', 'persa.jpg'],
];

export function abrirBanco(caminho = process.env.DB_PATH || 'petfy.db') {
  const db = new DatabaseSync(caminho);
  db.exec(`
    PRAGMA foreign_keys = ON;
    CREATE TABLE IF NOT EXISTS usuarios (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      email TEXT NOT NULL UNIQUE,
      senha_hash TEXT NOT NULL,
      papel TEXT NOT NULL DEFAULT 'usuario',
      criado_em TEXT NOT NULL DEFAULT (datetime('now'))
    );
    CREATE TABLE IF NOT EXISTS pets (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      tipo TEXT NOT NULL CHECK (tipo IN ('cachorro','gato','outros')),
      porte TEXT NOT NULL CHECK (porte IN ('pequeno','medio','grande')),
      faixa TEXT NOT NULL CHECK (faixa IN ('filhote','adulto','idoso')),
      sexo TEXT NOT NULL CHECK (sexo IN ('macho','femea')),
      castrado INTEGER NOT NULL,
      vacinado INTEGER NOT NULL,
      raca TEXT NOT NULL,
      anos TEXT NOT NULL,
      descricao TEXT NOT NULL,
      local TEXT NOT NULL,
      temperamento TEXT NOT NULL,
      imagem TEXT
    );
    CREATE TABLE IF NOT EXISTS favoritos (
      usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
      pet_id INTEGER NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
      PRIMARY KEY (usuario_id, pet_id)
    );
    CREATE TABLE IF NOT EXISTS solicitacoes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
      pet_id INTEGER NOT NULL REFERENCES pets(id) ON DELETE CASCADE,
      nome TEXT NOT NULL,
      email TEXT NOT NULL,
      telefone TEXT NOT NULL,
      endereco TEXT NOT NULL,
      motivo TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'pendente',
      criado_em TEXT NOT NULL DEFAULT (datetime('now'))
    );
  `);
  // Bancos criados antes do papel de admin
  if (!db.prepare('PRAGMA table_info(usuarios)').all().some((c) => c.name === 'papel')) {
    db.exec("ALTER TABLE usuarios ADD COLUMN papel TEXT NOT NULL DEFAULT 'usuario'");
  }
  const { n } = db.prepare('SELECT COUNT(*) AS n FROM pets').get();
  if (n === 0) {
    const ins = db.prepare('INSERT INTO pets (nome,tipo,porte,faixa,sexo,castrado,vacinado,raca,anos,descricao,local,temperamento,imagem) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)');
    for (const p of PETS_INICIAIS) ins.run(...p);
  }
  return db;
}
