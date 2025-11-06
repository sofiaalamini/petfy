function mostrarTela2() {
  document.getElementById("tela1").style.display = "none";
  document.getElementById("tela2").style.display = "block";
}

function entrar() {
  window.location.href = "indexTelas.html";
}

// ======== NAVEGAÇÃO POR SEÇÕES ========
function scrollToSection(sectionId) {
  const targetElement = document.getElementById(sectionId);
  if (targetElement) {
    targetElement.scrollIntoView({
      behavior: "smooth",
      block: "start"
    });
  }
}

// ======== MENU MOBILE ========
function toggleMenu() {
  document.getElementById("menu").classList.toggle("show");
}

document.querySelectorAll("#menu a").forEach((link) => {
  link.addEventListener("click", (e) => {
    e.preventDefault();
    document.getElementById("menu").classList.remove("show");
    
    const targetId = link.getAttribute("href").substring(1);
    const targetElement = document.getElementById(targetId);
    
    if (targetElement) {
      targetElement.scrollIntoView({
        behavior: "smooth",
        block: "start"
      });
    }
  });
});

// ======== DADOS DOS PETS ========
let petsData = [
  {
    id: 1,
    nome: "Chicle",
    tipo: "gato",
    porte: "medio",
    idade: "adulto",
    sexo: "macho",
    castrado: "sim",
    vacinado: "sim",
    especie: "Gato Malhado Comum",
    raca: "Malhado Comum",
    anos: "3 anos",
    descricao: "Chicle é um amor de gato, super brincalhão e sociável. Adora crianças e outros animais. Sempre está pronto para uma brincadeira!",
    localizacao: "Cascavel - PR",
    imagem: "./assets/chicle.avif",
    temperamento: "brincalhao"
  },
  {
    id: 2,
    nome: "Lolla",
    tipo: "cachorro",
    porte: "medio",
    idade: "adulto",
    sexo: "femea",
    castrado: "sim",
    vacinado: "sim",
    especie: "Vira-Lata",
    raca: "Vira-Lata",
    anos: "5 anos",
    descricao: "Lolla é muito amigável e carinhosa, ótima companhia para toda a família. É tranquila e adora receber carinho. Perfeita para um lar acolhedor.",
    localizacao: "Rio de Janeiro - RJ",
    imagem: "./assets/lolla.webp",
    temperamento: "carinhoso"
  }
];

// ======== FUNÇÃO PARA RENDERIZAR PETS ========
function renderizarPets(pets = petsData) {
  const petsSection = document.querySelector(".pets");
  const btnVerMais = document.querySelector(".btn-ver-mais");
  
  // Remove todos os cards existentes (exceto o botão "Ver mais")
  const cardsExistentes = petsSection.querySelectorAll(".card");
  cardsExistentes.forEach(card => card.remove());
  
  // Renderiza os pets
  pets.forEach(pet => {
    const card = criarCardPet(pet);
    petsSection.insertBefore(card, btnVerMais);
  });
}

// ======== FUNÇÃO PARA CRIAR CARD DO PET ========
function criarCardPet(pet) {
  const card = document.createElement("div");
  card.classList.add("card");
  card.setAttribute("data-pet-id", pet.id);
  
  const temperamentoClass = pet.temperamento || "docil";
  const sexoClass = pet.sexo === "macho" ? "macho" : "femea";
  
  card.innerHTML = `
    <div class="card-image">
      <img src="${pet.imagem}" alt="${pet.nome}" />
      <span class="tag ${temperamentoClass}">${pet.temperamento.toUpperCase()}</span>
      <span class="tag ${sexoClass}">${pet.sexo === 'macho' ? 'Macho' : 'Fêmea'}</span>
    </div>
    <div class="card-content">
      <h3>${pet.nome}</h3>
      <p class="info">${pet.especie} • ${pet.anos}</p>
      <p class="descricao">${pet.descricao}</p>
      <p class="localizacao">${pet.localizacao}</p>
      <button class="btn-adotar">Quero adotar</button>
    </div>
  `;
  
  // Adiciona event listener ao botão "Quero adotar"
  const btnAdotar = card.querySelector(".btn-adotar");
  if (btnAdotar) {
    btnAdotar.addEventListener("click", abrirModalAdocao);
  }
  
  return card;
}

// ======== FUNÇÃO DE FILTROS ========
function aplicarFiltros() {
  const tipo = document.getElementById("filtro-tipo").value;
  const porte = document.getElementById("filtro-porte").value;
  const idade = document.getElementById("filtro-idade").value;
  const sexo = document.getElementById("filtro-sexo").value;
  const castrado = document.getElementById("filtro-castrado").value;
  const vacinado = document.getElementById("filtro-vacinado").value;
  
  const petsFiltrados = petsData.filter(pet => {
    return (!tipo || pet.tipo === tipo) &&
           (!porte || pet.porte === porte) &&
           (!idade || pet.idade === idade) &&
           (!sexo || pet.sexo === sexo) &&
           (!castrado || pet.castrado === castrado) &&
           (!vacinado || pet.vacinado === vacinado);
  });
  
  renderizarPets(petsFiltrados);
}

// ======== FUNÇÃO PARA ADICIONAR PET ========
function adicionarPet(event) {
  event.preventDefault();
  
  const nome = document.getElementById("nome-pet").value;
  const idade = document.getElementById("idade-pet").value;
  const porte = document.getElementById("porte-pet").value;
  const especie = document.getElementById("especie-pet").value;
  const sexo = document.getElementById("sexo-pet").value;
  const raca = document.getElementById("raca-pet").value;
  const vacinado = document.getElementById("vacinado-pet").value;
  const castrado = document.getElementById("castrado-pet").value;
  const localizacao = document.getElementById("localizacao-pet").value;
  const descricao = document.getElementById("descricao-pet").value;
  
  // Determina o tipo baseado na espécie
  let tipo = "outros";
  if (especie.toLowerCase().includes("gato") || especie.toLowerCase().includes("cat")) {
    tipo = "gato";
  } else if (especie.toLowerCase().includes("cachorro") || especie.toLowerCase().includes("cão") || especie.toLowerCase().includes("dog")) {
    tipo = "cachorro";
  }
  
  // Determina a idade baseado no input
  let faixaIdade = "adulto";
  if (idade.toLowerCase().includes("filhote") || idade.toLowerCase().includes("bebê") || parseInt(idade) < 1) {
    faixaIdade = "filhote";
  } else if (idade.toLowerCase().includes("idoso") || idade.toLowerCase().includes("senior") || parseInt(idade) > 7) {
    faixaIdade = "idoso";
  }
  
  const novoPet = {
    id: petsData.length + 1,
    nome: nome,
    tipo: tipo,
    porte: porte.toLowerCase(),
    idade: faixaIdade,
    sexo: sexo.toLowerCase(),
    castrado: castrado.toLowerCase(),
    vacinado: vacinado.toLowerCase(),
    especie: especie,
    raca: raca,
    anos: idade,
    descricao: descricao,
    localizacao: localizacao,
    imagem: "./assets/thor.jpg", // Imagem padrão
    temperamento: "docil"
  };
  
  petsData.push(novoPet);
  renderizarPets();
  
  // Limpa o formulário
  document.getElementById("form-adicionar-pet").reset();
  
  alert("Pet adicionado com sucesso!");
}

// ======== VER MAIS PETS ========
document.addEventListener("DOMContentLoaded", () => {
  const btnVerMais = document.querySelector(".btn-ver-mais");
  const petsSection = document.querySelector(".pets");

  // Renderiza os pets iniciais
  renderizarPets();

  if (btnVerMais) {
    btnVerMais.addEventListener("click", () => {
      // Lista de pets adicionais para adicionar
      const baseId = petsData.length;
      const novosPets = [
        {
          id: baseId + 1,
          nome: "Thor",
          tipo: "cachorro",
          porte: "medio",
          idade: "adulto",
          sexo: "macho",
          castrado: "sim",
          vacinado: "sim",
          especie: "Vira-Lata",
          raca: "Vira-Lata",
          anos: "2 anos",
          descricao: "Thor é um cãozinho cheio de energia e muito brincalhão. Adora correr no parque e fazer novos amigos. Perfeito para famílias ativas!",
          localizacao: "Curitiba - PR",
          imagem: "./assets/thor.jpg",
          temperamento: "energico"
        },
        {
          id: baseId + 2,
          nome: "Mel",
          tipo: "cachorro",
          porte: "pequeno",
          idade: "filhote",
          sexo: "femea",
          castrado: "nao",
          vacinado: "sim",
          especie: "Vira-Lata",
          raca: "Vira-Lata",
          anos: "6 meses",
          descricao: "Mel é uma filhotinha super brincalhona e curiosa. Adora explorar e brincar com brinquedos. Está aprendendo comandos básicos!",
          localizacao: "São Paulo - SP",
          imagem: "./assets/vitalata.webp",
          temperamento: "brincalhao"
        },
        {
          id: baseId + 3,
          nome: "Luna",
          tipo: "gato",
          porte: "pequeno",
          idade: "adulto",
          sexo: "femea",
          castrado: "sim",
          vacinado: "sim",
          especie: "Gato Siamês",
          raca: "Siamês",
          anos: "4 anos",
          descricao: "Luna é uma gata muito tranquila e carinhosa. Adora receber carinho e ficar no colo. Perfeita para quem busca um companheiro calmo e afetuoso.",
          localizacao: "Belo Horizonte - MG",
          imagem: "./assets/siames.jpg",
          temperamento: "carinhoso"
        },
        {
          id: baseId + 4,
          nome: "Max",
          tipo: "cachorro",
          porte: "grande",
          idade: "adulto",
          sexo: "macho",
          castrado: "sim",
          vacinado: "sim",
          especie: "Labrador",
          raca: "Labrador Retriever",
          anos: "3 anos",
          descricao: "Max é um cão muito dócil, leal e obediente. Adora atividades ao ar livre, nadar e brincar com crianças. É muito inteligente e aprende rápido!",
          localizacao: "Porto Alegre - RS",
          imagem: "./assets/labrador.jpg",
          temperamento: "docil"
        },
        {
          id: baseId + 5,
          nome: "Bolinha",
          tipo: "gato",
          porte: "medio",
          idade: "idoso",
          sexo: "macho",
          castrado: "sim",
          vacinado: "sim",
          especie: "Gato Persa",
          raca: "Persa",
          anos: "8 anos",
          descricao: "Bolinha é um gato idoso muito tranquilo e independente. Prefere ambientes calmos e adora descansar ao sol. Ideal para pessoas que buscam um companheiro sossegado.",
          localizacao: "Florianópolis - SC",
          imagem: "./assets/persa.png",
          temperamento: "calma"
        }
      ];
      
      // Adiciona todos os novos pets
      novosPets.forEach(pet => {
        petsData.push(pet);
      });
      
      // Renderiza todos os pets
      renderizarPets();
      
      // Opcional: desabilita o botão após adicionar todos os pets disponíveis
      // btnVerMais.style.opacity = "0.5";
      // btnVerMais.style.cursor = "not-allowed";
      // btnVerMais.disabled = true;
      // btnVerMais.textContent = "Todos os pets carregados";
    });
  }

  // Adiciona event listener para o formulário de adicionar pet
  const formAdicionarPet = document.getElementById("form-adicionar-pet");
  if (formAdicionarPet) {
    formAdicionarPet.addEventListener("submit", adicionarPet);
  }
  
  // Reabilita o botão "Ver mais" quando um novo pet é adicionado pelo formulário
  const originalAdicionarPet = adicionarPet;
  window.adicionarPet = function(event) {
    originalAdicionarPet(event);
    const btnVerMais = document.querySelector(".btn-ver-mais");
    if (btnVerMais) {
      btnVerMais.style.opacity = "1";
      btnVerMais.style.cursor = "pointer";
      btnVerMais.disabled = false;
      btnVerMais.textContent = "Ver mais pets";
    }
  };

  // Adiciona event listeners para os botões "Quero adotar"
  const botoesAdotar = document.querySelectorAll(".btn-adotar");
  botoesAdotar.forEach(botao => {
    botao.addEventListener("click", abrirModalAdocao);
  });

  // Event listener para fechar o modal
  const modalAdocao = document.getElementById("modal-adocao");
  const closeModal = document.querySelector(".close-modal");
  const btnCancelar = document.querySelector(".btn-cancelar");

  if (closeModal) {
    closeModal.addEventListener("click", fecharModalAdocao);
  }

  if (btnCancelar) {
    btnCancelar.addEventListener("click", fecharModalAdocao);
  }

  // Fecha o modal ao clicar fora dele
  if (modalAdocao) {
    modalAdocao.addEventListener("click", function(event) {
      if (event.target === modalAdocao) {
        fecharModalAdocao();
      }
    });
  }

  // Event listener para o formulário de adoção
  const formAdocao = document.getElementById("form-adocao");
  if (formAdocao) {
    formAdocao.addEventListener("submit", enviarSolicitacaoAdocao);
  }
});

// ======== CONFIGURAÇÃO DE AVALIAÇÃO ========
const RATINGS_READONLY = true;

function carregarAvaliacoesSalvas(historiaCard, estrelas) {
  const container = historiaCard.querySelector('.estrelas');
  if (container) container.classList.add('readonly');

  // Lê a avaliação do atributo data-rating do card, ou usa 4 como padrão
  const rating = parseInt(historiaCard.getAttribute('data-rating')) || 4;

  estrelas.forEach((estrela, index) => {
    if (index < rating) {
      estrela.classList.add("ativa");
    } else {
      estrela.classList.remove("ativa");
    }
  });
}

document.addEventListener("DOMContentLoaded", function () {
  const historiaCards = document.querySelectorAll('.historia-card');
  historiaCards.forEach(historiaCard => {
    const estrelas = historiaCard.querySelectorAll('.estrela');
    carregarAvaliacoesSalvas(historiaCard, estrelas);
  });
});
// ======== ACESSIBILIDADE ========
document.addEventListener("DOMContentLoaded", () => {
  // Carrega configurações salvas
  carregarConfiguracoes();
  
  // Event listener para o slider de fonte
  const fontRange = document.getElementById("fontRange");
  if (fontRange) {
    fontRange.addEventListener("input", function () {
      const fontSize = this.value + "px";
      document.documentElement.style.fontSize = fontSize;
      document.body.style.fontSize = fontSize;
    });
  }
  
  // Event listener para o formulário de contato
  const contatoForm = document.getElementById("contato-form");
  if (contatoForm) {
    contatoForm.addEventListener("submit", enviarContato);
  }
  
  // Event listeners para os botões de tema
  const themeBtns = document.querySelectorAll('.theme-btn');
  themeBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      const tema = btn.dataset.theme;
      setTheme(tema);
      atualizarTemaAtivo(tema);
    });
  });
});

function setTheme(theme) {
  document.body.className = theme;
  localStorage.setItem('petfy-theme', theme);
}

// ======== FUNÇÕES AUXILIARES ========
function carregarConfiguracoes() {
  // Carrega tema salvo
  const temaSalvo = localStorage.getItem('petfy-theme');
  if (temaSalvo) {
    setTheme(temaSalvo);
    atualizarTemaAtivo(temaSalvo);
  }
  
  // Carrega tamanho da fonte salvo
  const fonteSalva = localStorage.getItem('petfy-font-size');
  if (fonteSalva) {
    const fontSize = fonteSalva + 'px';
    document.documentElement.style.fontSize = fontSize;
    document.body.style.fontSize = fontSize;
    const fontRange = document.getElementById("fontRange");
    if (fontRange) {
      fontRange.value = fonteSalva;
    }
  }
  
  // Carrega configurações de áudio salvas
  const descImgSalva = localStorage.getItem('petfy-desc-img');
  const feedbackSalvo = localStorage.getItem('petfy-feedback');
  
  if (descImgSalva === 'true') {
    document.getElementById('descImg').checked = true;
  }
  if (feedbackSalvo === 'true') {
    document.getElementById('feedback').checked = true;
  }
}

function atualizarTemaAtivo(tema) {
  const themeBtns = document.querySelectorAll('.theme-btn');
  themeBtns.forEach(btn => {
    btn.classList.remove('active');
    if (btn.dataset.theme === tema) {
      btn.classList.add('active');
    }
  });
}

function salvarConfiguracoes() {
  // Salva tamanho da fonte
  const fontRange = document.getElementById("fontRange");
  if (fontRange) {
    localStorage.setItem('petfy-font-size', fontRange.value);
  }
  
  // Salva configurações de áudio
  const descImg = document.getElementById('descImg').checked;
  const feedback = document.getElementById('feedback').checked;
  
  localStorage.setItem('petfy-desc-img', descImg);
  localStorage.setItem('petfy-feedback', feedback);
  
  // Mostra feedback visual
  const btnSalvar = document.querySelector('.btn-salvar');
  const textoOriginal = btnSalvar.innerHTML;
  
  btnSalvar.innerHTML = 'Salvo!';
  btnSalvar.style.background = 'var(--accent-primary)';
  
  setTimeout(() => {
    btnSalvar.innerHTML = textoOriginal;
    btnSalvar.style.background = 'var(--accent-primary)';
  }, 2000);
}

function enviarContato(event) {
  event.preventDefault();
  
  const nome = document.getElementById('nome-contato').value;
  const email = document.getElementById('email-contato').value;
  const assunto = document.getElementById('assunto-contato').value;
  const mensagem = document.getElementById('mensagem-contato').value;
  
  // Simula envio (em uma aplicação real, aqui seria feita uma requisição para o servidor)
  console.log('Mensagem enviada:', { nome, email, assunto, mensagem });
  
  // Mostra feedback visual
  const btnEnviar = document.querySelector('.btn-enviar');
  const textoOriginal = btnEnviar.innerHTML;
  
  btnEnviar.innerHTML = 'Enviado!';
  btnEnviar.style.background = 'var(--accent-primary)';
  
  setTimeout(() => {
    btnEnviar.innerHTML = textoOriginal;
    btnEnviar.style.background = 'var(--accent-primary)';
  }, 2000);
  
  // Limpa o formulário
  document.getElementById('contato-form').reset();
  
  // Mostra alerta de sucesso
  alert('Mensagem enviada com sucesso! Entraremos em contato em breve.');
}

// ======== FUNÇÕES DO MODAL DE ADOÇÃO ========
function abrirModalAdocao(event) {
  const modal = document.getElementById("modal-adocao");
  if (modal) {
    modal.classList.add("show");
    document.body.style.overflow = "hidden"; // Previne scroll do body
  }
}

function fecharModalAdocao() {
  const modal = document.getElementById("modal-adocao");
  if (modal) {
    modal.classList.remove("show");
    document.body.style.overflow = "auto"; // Restaura scroll do body
  }
}

function enviarSolicitacaoAdocao(event) {
  event.preventDefault();
  
  const nome = document.getElementById('nome-adotante').value;
  const email = document.getElementById('email-adotante').value;
  const telefone = document.getElementById('telefone-adotante').value;
  const endereco = document.getElementById('endereco-adotante').value;
  const motivo = document.getElementById('motivo-adocao').value;
  
  // Simula envio (em uma aplicação real, aqui seria feita uma requisição para o servidor)
  console.log('Solicitação de adoção enviada:', { nome, email, telefone, endereco, motivo });
  
  // Mostra feedback visual
  const btnConfirmar = document.querySelector('.btn-confirmar');
  const textoOriginal = btnConfirmar.innerHTML;
  
  btnConfirmar.innerHTML = 'Enviado!';
  btnConfirmar.style.background = 'var(--accent-primary)';
  
  setTimeout(() => {
    btnConfirmar.innerHTML = textoOriginal;
    btnConfirmar.style.background = '';
    fecharModalAdocao();
    document.getElementById('form-adocao').reset();
    alert('Solicitação de adoção enviada com sucesso! Entraremos em contato em breve.');
  }, 2000);
}
