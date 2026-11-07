import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["view", "form"]

  toggle() {
    this.viewTarget.classList.toggle("d-none")
    this.formTarget.classList.toggle("d-none")
  }

  // Optionnel : fermer si on clique ailleurs
  close(event) {
    if (!this.element.contains(event.target)) {
      this.viewTarget.classList.remove("d-none")
      this.formTarget.classList.add("d-none")
    }
  }
}
