import { Controller } from "@hotwired/stimulus"
import flatpickr from "flatpickr"

export default class extends Controller {
  static values = { maxDate: String }

  connect() {
    flatpickr(this.element, {
      // minDate: "today",
      altInput: true,       // Affiche un format lisible (ex: 12 Octobre 2023)
      altFormat: "d-m-Y",   // Format d'affichage pour l'utilisateur
      dateFormat: "Y-m-d",  // Format envoyé à Rails (standard DB)
      maxDate: this.hasMaxDateValue ? this.maxDateValue : null
    })
  }
}
