import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="deletion-button"
export default class extends Controller {
  static values = {
    deleteRecordUrl: String,
    cardElementSelector: String,
    confirmation: String
  }

  declare deleteRecordUrlValue: string
  declare cardElementSelectorValue: string

  declare confirmationValue: string
  declare hasCardElementSelectorValue: boolean

  private cardElements: NodeListOf<HTMLElement> | undefined

  connect() {
    this.cardElements = this.hasCardElementSelectorValue
      ? document.querySelectorAll(this.cardElementSelectorValue)
      : undefined
  }

  open() {
    if (this.element instanceof HTMLButtonElement) {
      this.element.blur()
      this.dispatch('open', {
        target: window,
        detail: {
          button: this.element,
          deleteRecordUrl: this.deleteRecordUrlValue,
          confirmation: this.confirmationValue
        }
      })
    }
  }

  removeElementFromDOM(event: { detail: { target: HTMLButtonElement } }) {
    if (event.detail.target !== this.element) return
    this.cardElements?.forEach((element) => {
      element.addEventListener('animationend', () => {
        element.remove()
      })
      element.classList.add('animate-fade-out')
    })
  }
}
