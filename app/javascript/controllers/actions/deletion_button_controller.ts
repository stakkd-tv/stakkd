import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="deletion-button"
export default class extends Controller {
  static values = {
    deleteRecordUrl: String,
    cardElementSelector: String
  }

  declare deleteRecordUrlValue: string
  declare cardElementSelectorValue: string

  declare cardElements: NodeListOf<HTMLElement>

  connect() {
    this.cardElements = document.querySelectorAll(this.cardElementSelectorValue)
  }

  open() {
    if (this.element instanceof HTMLButtonElement) {
      this.element.blur()
      this.dispatch('open', {
        target: window,
        detail: {
          button: this.element,
          deleteRecordUrl: this.deleteRecordUrlValue
        }
      })
    }
  }

  removeElementFromDOM(event: { detail: { target: HTMLButtonElement } }) {
    if (event.detail.target !== this.element) return
    this.cardElements.forEach((element) => {
      element.addEventListener('animationend', () => {
        element.remove()
      })
      element.classList.add('animate-fade-out')
    })
  }
}
