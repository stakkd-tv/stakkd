import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="flash-item"
export default class extends Controller {
  static targets = ['remove']

  declare readonly removeTarget: HTMLElement

  connect () {
    this.removeTarget.addEventListener('click', () => {
      this.element.remove()
    })
  }
}
