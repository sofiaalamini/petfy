function mostrarTela2() {
  document.getElementById("tela1").style.display = "none";
  document.getElementById("tela2").style.display = "block";
}

function entrar() {
  window.location.href = "indexTelas.html";
}

// ======== MENU MOBILE ========
function toggleMenu() {
  document.getElementById("menu").classList.toggle("show");
}

document.querySelectorAll("#menu a").forEach((link) => {
  link.addEventListener("click", () => {
    document.getElementById("menu").classList.remove("show");
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
    descricao: "Chicle é um amor de gato, super brincalhão e sociável. Adora crianças e outros animais.",
    localizacao: "Cascavel - PR",
    imagem: "./assets/chicle.avif",
    temperamento: "docil"
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
    descricao: "Lolla é muito amigável e carinhosa, ótima companhia para toda a família.",
    localizacao: "Rio de Janeiro - RJ",
    imagem: "./assets/lolla.webp",
    temperamento: "calma"
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
  
  const temperamentoClass = pet.temperamento === "docil" ? "docil" : "calma";
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
      const novoPet = {
        id: petsData.length + 1,
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
        descricao: "Thor é um cãozinho cheio de energia, adora brincar e fazer novos amigos. Está ansioso para encontrar um lar amoroso.",
        localizacao: "Curitiba - PR",
        imagem: "./assets/thor.jpg",
        temperamento: "docil"
      };
      
      petsData.push(novoPet);
      renderizarPets();
    });
  }

  // Adiciona event listener para o formulário de adicionar pet
  const formAdicionarPet = document.getElementById("form-adicionar-pet");
  if (formAdicionarPet) {
    formAdicionarPet.addEventListener("submit", adicionarPet);
  }
});

// ======== ESTRELAS ========
document.addEventListener("DOMContentLoaded", () => {
  const historias = document.querySelectorAll(".historias .historia");

  historias.forEach((historia) => {
    const estrelas = Array.from(historia.querySelectorAll(".estrela"));

    estrelas.forEach((estrela, index) => {
      // Hover
      estrela.addEventListener("mouseenter", () => {
        estrelas.forEach((e, i) => {
          if (i <= index) {
            e.classList.add("hovered");
          } else {
            e.classList.remove("hovered");
          }
        });
      });

      estrela.addEventListener("mouseleave", () => {
        estrelas.forEach((e) => e.classList.remove("hovered"));
      });

      // Clique
      estrela.addEventListener("click", () => {
        estrelas.forEach((e, i) => {
          if (i <= index) {
            e.classList.add("ativa");
          } else {
            e.classList.remove("ativa");
          }
        });
      });
    });
  });
});
// ======== ACESSIBILIDADE ========
document.getElementById("fontRange").addEventListener("input", function () {
  document.body.style.fontSize = this.value + "px";
});

function setTheme(theme) {
  document.body.className = theme;
}
