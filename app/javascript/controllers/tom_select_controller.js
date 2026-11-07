import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.select = new TomSelect(this.element, {
      plugins: {
        'remove_button': {
          title: 'Supprimer cet élément',
        }
      },
      persist: false,
      create: false,
      closeAfterSelect: false // Garde le menu ouvert pour sélectionner plusieurs éléments d'affilée
    })
  }

  disconnect() {
    if (this.select) {
      this.select.destroy()
    }
  }
}
