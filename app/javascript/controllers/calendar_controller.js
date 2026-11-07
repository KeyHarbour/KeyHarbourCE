import { Controller } from "@hotwired/stimulus"
import FullCalendar from "fullcalendar" // On importe le module fraîchement exporté

export default class extends Controller {
  connect() {
    // Plus besoin d'attendre window, l'import garantit que c'est là
    this.calendar = new FullCalendar.Calendar(this.element, {
      initialView: 'listYear',

      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,listMonth,listYear'
      },
      buttonText: {
        today:        "Aujourd'hui",
        dayGridMonth: "Vue Mensuelle",
        timeGridWeek: "Planning Heures",
        listMonth:    "Liste du Mois",
        listYear:     "Agenda Annuel"
      },
      editable: false,
      selectable: true,
      events: '/member/events.json'
    })

    this.calendar.render()
  }

  disconnect() {
    if (this.calendar) {
      this.calendar.destroy()
    }
  }
}