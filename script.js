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

// ======== VER MAIS PETS ========
document.addEventListener("DOMContentLoaded", () => {
  const btnVerMais = document.querySelector(".btn-ver-mais");
  const petsSection = document.querySelector(".pets");

  if (btnVerMais) {
    btnVerMais.addEventListener("click", () => {
      const novoPet = document.createElement("div");
      novoPet.classList.add("card-image", "card", "card-content");
      novoPet.innerHTML = `
        <span class="tag macho">Macho</span>
        <span class="tag docil">DÓCIL</span>
        <img src="./assets/thor.jpg" alt="Thor">
        <h3>Thor</h3>
        <p class="info">Vira-Lata • 2 anos</p>
        <p class="descricao">
          Thor é um cãozinho cheio de energia, adora brincar e fazer novos amigos. Está ansioso para encontrar um lar amoroso.
        </p>
        <p class="localizacao">Curitiba - PR</p>
        <button class="btn-adotar">Quero adotar</button>
      `;
      petsSection.insertBefore(novoPet, btnVerMais);
    });
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
