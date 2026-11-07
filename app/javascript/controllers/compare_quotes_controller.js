import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "link", "checkbox" ]

  // Exécuté à chaque fois qu'une checkbox est cochée ou décochée
  toggle(event) {
    // 1. Récupérer toutes les checkboxes actuellement cochées
    const checkedBoxes = this.checkboxTargets.filter(cb => cb.checked)

    // 2. Contrainte : Pas possible d'en choisir 3 (Max 2)
    if (checkedBoxes.length > 3) {
      event.target.checked = false // Décoche la 3ème case qui vient d'être cliquée
      alert("Vous ne pouvez pas comparer plus de 3 éléments.")
      return
    }

    // 3. Contrainte : Activer le bouton SEULEMENT si exactement 3 items sont sélectionnés
    if (checkedBoxes.length >= 2) {
      this.linkTarget.classList.remove("disabled")
      this.linkTarget.removeAttribute("aria-disabled")
    } else {
      this.linkTarget.classList.add("disabled")
      this.linkTarget.setAttribute("aria-disabled", "true")
    }
  }

  // Exécuté lors du clic sur le bouton "compare"
  navigate(event) {
    // Si le bouton a la classe disabled, on bloque l'action
    if (this.linkTarget.classList.contains("disabled")) {
      event.preventDefault()
      return
    }

    event.preventDefault()

    const selectedIds = this.checkboxTargets
      .filter(checkbox => checkbox.checked)
      .map(checkbox => checkbox.value)

    const baseUrl = this.linkTarget.getAttribute("href")
    const params = new URLSearchParams()
    selectedIds.forEach(id => params.append("ids[]", id))
    
    window.location.href = `${baseUrl}?${params.toString()}`
  }
}
