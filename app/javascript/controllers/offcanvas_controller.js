import { Controller } from "@hotwired/stimulus"
import "tabler" // Charge le fichier tabler.min.js

export default class extends Controller {
  static targets = [ "panel" ]
  static values = {
    onload: Boolean
  }

  connect() {
    const tablerBootstrap = window.tabler?.bootstrap || window.bootstrap;
    this.offcanvas = new tablerBootstrap.Offcanvas(this.panelTarget)
    console.log("Valeur brute", this.onloadValue)
    if (this.onloadValue) {
      this.open()
    }
  }

  open() {
    if (this.offcanvas) this.offcanvas.show()
  }

  close() {
    if (this.offcanvas) this.offcanvas.hide()
  }
}
