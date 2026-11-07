import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // On déclare les cibles (targets) au singulier
  static targets = [ "annual", "monthly" ]

  toggle(event) {
    const isAnnual = event.target.checked
    const activeRadio = document.querySelector('input[name="billing"]:checked')

    document.querySelectorAll('.price').forEach((element) => {
      element.classList.add('d-none')
    })
    document.querySelectorAll('.' + activeRadio.value + '-prices').forEach((element) => {
      element.classList.remove('d-none')
    })
    // // On boucle sur TOUS les prix annuels de la page
    // this.annualTargets.forEach(element => {
    //   element.classList.toggle("hidden", !isAnnual)
    // })
    //
    // // On boucle sur TOUS les prix mensuels de la page
    // this.monthlyTargets.forEach(element => {
    //   element.classList.toggle("hidden", isAnnual)
    // })
  }
}
