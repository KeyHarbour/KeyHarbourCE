// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "tabler"
import "jquery"
import "tom-select"

import "trix"
import "@rails/actiontext"


document.addEventListener("turbo:load", () => {
  if (window.tabler && window.tabler.Clipboard) {
    const clipboardElements = document.querySelectorAll('[data-bs-toggle="clipboard"]');
    
    clipboardElements.forEach((element) => {
      if (!window.tabler.Clipboard.getInstance(element)) {
        window.tabler.Clipboard.getOrCreateInstance(element);
      }
    });
  }
});

function initTablerComponents(container = document) {
  // Initialise les Tooltips
  const tooltips = container.querySelectorAll('[data-bs-toggle="tooltip"]')
  tooltips.forEach(el => Tooltip.getOrCreateInstance(el))

  // Initialise les Popovers
  const popovers = container.querySelectorAll('[data-bs-toggle="popover"]')
  popovers.forEach(el => Popover.getOrCreateInstance(el))
}

// S'exécute au chargement d'une page complète ou via un lien Turbo Drive
document.addEventListener("turbo:load", () => initTablerComponents(document))

// S'exécute à CHAQUE fois qu'un Turbo Frame ou un Turbo Stream injecte du HTML
document.addEventListener("turbo:frame-load", (event) => {
  initTablerComponents(event.target) // On initialise UNIQUEMENT le contenu du frame pour les performances
})

// Exemple pour Tom-Select si vous l'utilisez dans votre projet Tabler
function initAdvancedForms(container = document) {
  if (window.TomSelect) {
    container.querySelectorAll('.tom-select').forEach(el => {
      if (!el.tomselect) new TomSelect(el)
    })
  }
}

document.addEventListener("turbo:load", () => initAdvancedForms(document))
document.addEventListener("turbo:frame-load", (event) => initAdvancedForms(event.target))

// Réaffirme le thème de Tabler après un chargement Turbo
document.addEventListener("turbo:load", () => {
  const body = document.body
  const theme = localStorage.getItem('tablerTheme') || 'light'
  if (theme === 'dark') {
    body.setAttribute('data-bs-theme', 'dark')
  } else {
    body.removeAttribute('data-bs-theme')
  }
})
