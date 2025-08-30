import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["date", "time", "seats", "feedback"]

  async submit(event) {
    event.preventDefault()
    const payload = {
      date: this.dateTarget.value,
      time: this.timeTarget.value,
      seats: this.seatsTarget.value
    }
    try {
      this._feedback('Se trimite cererea...', 'info')
      const res = await fetch('/reservations', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this._csrfToken(),
          'Accept': 'application/json'
        },
        body: JSON.stringify(payload)
      })
      let data = null
      try { data = await res.json() } catch (_) {}
      if (!res.ok) throw new Error((data && data.error) || `Eroare: ${res.status}`)
      this._feedback('Rezervare trimisă. Vei fi notificat după asignare.', 'success')
      this.element.reset && this.element.reset()
    } catch (e) {
      this._feedback(e?.message || 'Nu s-a putut trimite rezervarea.', 'error')
    }
  }

  _csrfToken() { return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') }
  _feedback(msg, kind) {
    if (!this.hasFeedbackTarget) return
    this.feedbackTarget.textContent = msg
    this.feedbackTarget.style.color = kind === 'error' ? '#c0392b' : (kind === 'success' ? '#27ae60' : '#333')
  }
}
