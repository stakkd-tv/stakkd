import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="jump-to"
export default class extends Controller {
  static targets = ['select']

  declare selectTarget: HTMLSelectElement

  connect () {
    this.selectTarget.addEventListener('change', () => {
      const selectedOption = this.selectTarget.options[this.selectTarget.selectedIndex]
      window.location.href = selectedOption.value
    })
  }
}
