import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const tablerBootstrap = window.tabler?.bootstrap || window.bootstrap;
    this.modal = new tablerBootstrap.Modal(this.element)
    this.modal.show()
  }

  disconnect() {
    // Cache proprement la modal si le frame est vidé
    if (this.modal) {
      this.modal.hide()
    }
  }

  close() {
    // Permet de fermer manuellement via Stimulus si nécessaire
    this.modal.hide()
  }
}
