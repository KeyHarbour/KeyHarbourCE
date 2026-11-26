import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "annual", "monthly" ]

  toggle(event) {
    const isAnnual = event.target.checked
    const period = isAnnual ? "annual" : "monthly"

    document.querySelectorAll('.price').forEach((element) => {
      element.classList.add('d-none')
    })

    document.querySelectorAll(`.${period}-prices`).forEach((element) => {
      element.classList.remove('d-none')
    })
  }
}
