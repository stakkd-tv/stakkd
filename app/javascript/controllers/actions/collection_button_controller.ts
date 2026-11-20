import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    stateUrl: String,
    addUrl: String,
    removeFormatsUrl: String,
    removeUrl: String
  }
  declare stateUrlValue: string
  declare addUrlValue: string
  declare removeFormatsUrlValue: string
  declare removeUrlValue: string

  open() {
    if (!(this.element instanceof HTMLButtonElement)) return
    this.element.blur()
    this.dispatch('open', {
      target: window,
      detail: {
        button: this.element,
        stateUrl: this.stateUrlValue,
        addUrl: this.addUrlValue,
        removeFormatsUrl: this.removeFormatsUrlValue,
        removeUrl: this.removeUrlValue
      }
    })
  }

  updateStatus(event: { detail: { target: string; status: string } }) {
    const key = `${this.element.getAttribute('data-record-type')}:${this.element.getAttribute('data-record-id')}`
    if (key === event.detail.target)
      this.element.setAttribute('data-status', event.detail.status)
  }
}
