import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="stack-controls"
export default class extends Controller<HTMLFormElement> {
  static targets = ['directionInput', 'directionIcon']

  declare readonly directionInputTarget: HTMLInputElement
  declare readonly directionIconTarget: HTMLElement

  submit() {
    this.element.requestSubmit()
  }

  toggleDirection() {
    const current = this.directionInputTarget.value
    const next = current === 'asc' ? 'desc' : 'asc'

    this.directionInputTarget.value = next
    this.directionIconTarget.dataset.direction = next

    this.submit()
  }
}
