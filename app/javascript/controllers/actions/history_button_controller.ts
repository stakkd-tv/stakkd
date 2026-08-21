import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="history-button"
export default class extends Controller {
  static values = {
    addToHistoryUrl: String,
    removeFromHistoryUrl: String
  }

  declare addToHistoryUrlValue: string
  declare removeFromHistoryUrlValue: string

  open() {
    if (this.element instanceof HTMLButtonElement) {
      this.element.blur()
      this.dispatch('open', {
        target: window,
        detail: {
          button: this.element,
          addToHistoryUrl: this.addToHistoryUrlValue,
          removeFromHistoryUrl: this.removeFromHistoryUrlValue
        }
      })
    }
  }

  updateStatus(event: { detail: { target: string; status: string } }) {
    const recordType = this.element.getAttribute('data-record-type')
    const recordId = this.element.getAttribute('data-record-id')
    const parts = event.detail.target.split(':')
    const updatedRecordType = parts[0]
    const updatedRecordId = parts[1]
    if (updatedRecordType !== recordType || updatedRecordId !== recordId) return
    this.element.setAttribute('data-status', event.detail.status)
  }
}
