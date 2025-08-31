import { Controller } from "@hotwired/stimulus"


export default class extends Controller {
  static values = { reservationId: Number }
  static targets = ["table"]

  dragStart(event) {
    if (!this.hasReservationIdValue) return
    event.dataTransfer.setData('text/plain', String(this.reservationIdValue))
  }

  allowDrop(event) {
    event.preventDefault()
  }

  async dropOnTable(event) {
    event.preventDefault()
    const tableEl = event.currentTarget.closest('[data-table-id]')
    const tableId = tableEl?.dataset?.tableId
    const reservationId = event.dataTransfer.getData('text/plain')
    if (!tableId || !reservationId) return

    try {
      const res = await fetch(`/employee/reservations/${reservationId}/assign?table_id=${tableId}`, {
        method: 'PATCH',
        headers: { 'X-CSRF-Token': this._csrf() }
      })
      let data = null
      try { data = await res.json() } catch (_) {}
      if (!res.ok) throw new Error((data && data.error) || `Eroare ${res.status}`)


      const li = document.querySelector(`[data-reservations-board-reservation-id-value="${reservationId}"]`)
      if (li && li.parentElement) li.parentElement.removeChild(li)
    } catch (e) {
      alert(e?.message || 'Nu s-a putut asigna rezervarea.')
    }
  }

  _csrf() { return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') }
}

