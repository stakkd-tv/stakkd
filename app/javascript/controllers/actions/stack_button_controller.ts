import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="stack-button"
export default class extends Controller {
  static values = {
    stacksForThisRecord: Array,
    addToStackUrl: String,
    createAndAddToStackUrl: String,
    removeFromStackUrl: String
  }

  static targets = ['stackCount']

  declare stackCountTarget: HTMLElement

  declare stacksForThisRecordValue: number[]
  declare addToStackUrlValue: string
  declare createAndAddToStackUrlValue: string
  declare removeFromStackUrlValue: string

  connect() {
    this._toggleCount()
  }

  open() {
    if (this.element instanceof HTMLButtonElement) {
      this.element.blur()
      this.dispatch('open', {
        target: window,
        detail: {
          button: this.element,
          stacksForThisRecord: this.stacksForThisRecordValue,
          addToStackUrl: this.addToStackUrlValue,
          createAndAddToStackUrl: this.createAndAddToStackUrlValue,
          removeFromStackUrl: this.removeFromStackUrlValue
        }
      })
    }
  }

  updateStacksForThisRecord(event: {
    detail: { target: HTMLButtonElement; updatedStacks: number[] }
  }) {
    if (event.detail.target !== this.element) return
    this.stacksForThisRecordValue = event.detail.updatedStacks
    this.stackCountTarget.textContent =
      this.stacksForThisRecordValue.length.toString()
    this._toggleCount()
  }

  _toggleCount() {
    if (this.stacksForThisRecordValue.length === 0) {
      this.stackCountTarget.classList.add('hidden')
    } else {
      this.stackCountTarget.classList.remove('hidden')
    }
  }
}
