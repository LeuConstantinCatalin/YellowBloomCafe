import { Controller } from "@hotwired/stimulus"

// Handles client-side cart and order mode on the menu page
export default class extends Controller {
  static targets = [
    "cart", "cartItems", "total", "toggleBtn", "checkoutBtn", "addressInput", "feedback"
  ]
  static values = { state: String }

  connect() {
    this.cartData = { items: [] }
    this.orderMode = false
    this.updateTotals()
    this.renderCart()

    // Re-render + buttons if menu sections toggle open/closed
    this._boundToggleHandler = (e) => {
      if (e.target && e.target.matches && e.target.matches('.toggle-btn')) {
        if (this.orderMode) this.renderAddButtons()
      }
    }
    document.addEventListener('click', this._boundToggleHandler, true)

    // Start collapsed
    this.closeAllSections()
    this.updateInfoVisibility()
  }

  disconnect() {
    if (this._boundToggleHandler) {
      document.removeEventListener('click', this._boundToggleHandler, true)
    }
  }

  // Sidebar collapsible cards (wired via data-action)
  toggleSection(event) {
    const btn = event.currentTarget
    const card = btn.closest('.sb-card')
    if (!card) return
    const content = card.querySelector('.sb-content')
    if (!content) return

    const wasOpen = content.classList.contains('open')
    this.closeAllSections()
    if (!wasOpen) {
      content.classList.add('open')
      content.style.maxHeight = content.scrollHeight + 'px'
      btn.textContent = '−'
    }
    this.updateInfoVisibility()
  }

  // Back-compat: keep old action name working
  toggleCollapse(event) { return this.toggleSection(event) }

  closeAllSections() {
    this.element.querySelectorAll('.sb-card .sb-content').forEach(el => {
      el.classList.remove('open')
      el.style.maxHeight = '0'
    })
    this.element.querySelectorAll('.sb-card .sb-toggle-btn').forEach(b => b.textContent = '+')
  }

  updateInfoVisibility() {
    const info = this.element.querySelector('.sidebar-info')
    if (!info) return
    const anyOpen = Array.from(this.element.querySelectorAll('.sb-content')).some(c => c.classList.contains('open'))
    // Toggle both a container flag and the info visibility for robustness
    this.element.classList.toggle('has-open', anyOpen)
    info.classList.toggle('is-hidden', anyOpen)
  }

  // Toggle order mode: show + buttons on each product card
  toggleMode() {
    this.orderMode = !this.orderMode
    document.body.classList.toggle('order-mode', this.orderMode)
    this.toggleBtnTarget.textContent = this.orderMode ? 'Oprește modul comandă' : 'Pornește modul comandă'
    this.renderAddButtons()
  }

  // Inject or remove + buttons for each product in menu
  renderAddButtons() {
    const productLis = document.querySelectorAll('.menu-content li')
    productLis.forEach(li => {
      const placeholder = li.querySelector('.product-placeholder')
      if (!placeholder) return

      // Cleanup existing button
      placeholder.innerHTML = ''
      if (!this.orderMode) return

      const available = (li.dataset.available === 'true' || li.dataset.available === '1')
      const addBtn = document.createElement('button')
      addBtn.className = 'btn btn-primary btn-add-to-cart'
      addBtn.textContent = '+'
      addBtn.title = available ? 'Adaugă în coș' : 'Indisponibil'
      addBtn.disabled = !available

      addBtn.addEventListener('click', () => {
        const productId = this._productIdFromLi(li)
        const name = li.querySelector('.product-name')?.textContent?.trim() || li.dataset.name || `Produs #${productId}`
        const priceText = li.querySelector('.product-price')?.textContent || '0'
        const price = this._parsePrice(priceText)
        this.addItem({ id: productId, name, price })
      })
      placeholder.appendChild(addBtn)
    })
  }

  addItem(product) {
    const existing = this.cartData.items.find(i => i.id === product.id)
    if (existing) {
      existing.quantity += 1
    } else {
      this.cartData.items.push({ id: product.id, name: product.name, price: product.price, quantity: 1 })
    }
    this.updateTotals()
    this.renderCart()
  }

  removeItem(event) {
    const id = Number(event.currentTarget.dataset.id)
    this.cartData.items = this.cartData.items.filter(i => i.id !== id)
    this.updateTotals()
    this.renderCart()
  }

  increment(event) {
    const id = Number(event.currentTarget.dataset.id)
    const it = this.cartData.items.find(i => i.id === id)
    if (it) it.quantity += 1
    this.updateTotals()
    this.renderCart()
  }

  decrement(event) {
    const id = Number(event.currentTarget.dataset.id)
    const it = this.cartData.items.find(i => i.id === id)
    if (it) {
      it.quantity = Math.max(1, it.quantity - 1)
    }
    this.updateTotals()
    this.renderCart()
  }

  clearCart = () => {
    this.cartData.items = []
    this.updateTotals()
    this.renderCart()
  }

  updateTotals() {
    const total = this.cartData.items.reduce((sum, it) => sum + (Number(it.price) * Number(it.quantity)), 0)
    if (this.hasTotalTarget) this.totalTarget.textContent = this._formatPrice(total)
    if (this.hasCheckoutBtnTarget) this.checkoutBtnTarget.disabled = this.cartData.items.length === 0
  }

  renderCart() {
    if (!this.hasCartItemsTarget) return
    this.cartItemsTarget.innerHTML = ''
    this.cartData.items.forEach(it => {
      const row = document.createElement('div')
      row.className = 'cart-item'
      row.innerHTML = `
        <span class="name">${this._escape(it.name)}</span>
        <span class="qty">
          <button class="btn btn-secondary" data-action="click->order#decrement" data-id="${it.id}">-</button>
          <strong>${it.quantity}</strong>
          <button class="btn btn-secondary" data-action="click->order#increment" data-id="${it.id}">+</button>
        </span>
        <span class="price">${this._formatPrice(it.price * it.quantity)} lei</span>
        <button class="btn" title="Scoate" data-action="click->order#removeItem" data-id="${it.id}">x</button>
      `
      this.cartItemsTarget.appendChild(row)
    })
  }

  async checkout() {
    if (this.cartData.items.length === 0) return
    const payload = {
      items: this.cartData.items.map(i => ({ product_id: i.id, quantity: i.quantity })),
    }
    if (this.hasAddressInputTarget && this.addressInputTarget.value.trim().length > 0) {
      payload.address = this.addressInputTarget.value.trim()
    }
    try {
      this._feedback('Se procesează comanda...', 'info')
      const res = await fetch('/orders', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this._csrfToken(),
          'Accept': 'application/json'
        },
        body: JSON.stringify(payload)
      })
      let data = null
      try { data = await res.json() } catch (_) { /* ignore */ }
      if (!res.ok) {
        const msg = (data && data.error) ? data.error : `Eroare server: ${res.status}`
        throw new Error(msg)
      }
      this.clearCart()
      this.orderMode = false
      this.renderAddButtons()
      this.toggleBtnTarget.textContent = 'Pornește modul comandă'
      if (this.hasAddressInputTarget) this.addressInputTarget.value = ''
      this._feedback('Comanda a fost plasată cu succes!', 'success')
    } catch (e) {
      console.error(e)
      this._feedback(e?.message || 'Nu s-a putut plasa comanda. Încearcă din nou.', 'error')
    }
  }

  // Helpers
  _productIdFromLi(li) { return Number((li.id || '').replace('product-', '')) }
  _parsePrice(text) {
    // Expecting formats like "12 lei" or "12,50 lei"
    const cleaned = (text || '').replace(/[^0-9,\.]/g, '').replace(',', '.')
    const val = parseFloat(cleaned)
    return isNaN(val) ? 0 : val
  }
  _formatPrice(n) { return (Math.round(Number(n) * 100) / 100).toLocaleString('ro-RO') }
  _escape(s) { const d = document.createElement('div'); d.textContent = s; return d.innerHTML }
  _csrfToken() { return document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') }
  _feedback(msg, kind) {
    if (!this.hasFeedbackTarget) return
    this.feedbackTarget.textContent = msg
    this.feedbackTarget.style.color = kind === 'error' ? '#c0392b' : (kind === 'success' ? '#27ae60' : '#333')
  }
}
