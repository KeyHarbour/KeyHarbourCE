import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["country", "province"]

  // Cette méthode s'exécute quand on change le pays
  updateProvinces() {
    const countryCode = this.countryTarget.value
    
    // On appelle l'API qu'on a créée dans Rails
    fetch(`/locations/provinces?country_code=${countryCode}`)
      .then(response => response.json())
      .then(data => {
        // On vide et on remplit le select des provinces
        this.provinceTarget.innerHTML = '<option value="">Sélectionnez...</option>'
        data.forEach(([name, code], index) => {
          const option = new Option(name, code)
          // Optionnel : Sélectionner le premier élément par défaut
          if (index === 0) option.selected = true 
          this.provinceTarget.add(option)
        })
      })
  }
}
