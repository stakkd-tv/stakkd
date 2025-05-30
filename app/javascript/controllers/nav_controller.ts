import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="nav"
export default class extends Controller {
  static targets = ['search', 'searchWrapper', 'button']

  declare readonly searchTarget: HTMLElement
  declare readonly searchWrapperTarget: HTMLElement
  declare readonly buttonTargets: HTMLElement[]

  connect () {
    this.searchWrapperTarget.addEventListener('click', () => {
      this.searchTarget.focus()
    })

    this.searchTarget.addEventListener('focusin', () => {
      this.buttonTargets.forEach((btn) => {
        btn.classList.add('!hidden')
      })
    })

    this.searchTarget.addEventListener('focusout', () => {
      this.buttonTargets.forEach((btn) => {
        btn.classList.remove('!hidden')
      })
    })
  }
}
