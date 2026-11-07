import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field"]

  connect() {
    const select = this.element.querySelector('[data-action*="trust-assets-form#toggleFields"]')
    if (select) this.toggleFields({ target: select })
  }

  toggleFields(event) {
    const selectedFormat = event.target.value
    
    // CONDITION D'AFFICHAGE : On liste ici les formats qui DOIVENT afficher les champs.
    // Si le format est vide ou n'est pas dans la liste, les champs restent cachés.
    const shouldShow = ['token'].includes(selectedFormat)

    this.fieldTargets.forEach(field => {
      if (shouldShow) {
        field.classList.remove('d-none')
      } else {
        field.classList.add('d-none')
      }
    })
  }
}
