import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="toggle"
export default class extends Controller {
  static targets = ['checkbox', 'toggleContainer', 'toggleHandle']

  declare readonly checkboxTarget: HTMLInputElement
  declare readonly toggleContainerTarget: HTMLElement
  declare readonly toggleHandleTarget: HTMLElement

  connect () {
    this.toggle(this.checkboxTarget.checked)
  }

  triggerToggle () {
    const checked = !this.checkboxTarget.checked
    this.checkboxTarget.checked = checked

    this.toggle(checked)
  }

  toggle (checked: boolean) {
    if (checked) {
      this.toggleContainerTarget.classList.remove('bg-background')
      this.toggleContainerTarget.classList.add('bg-pop')
      this.toggleHandleTarget.style.transform = 'translateX(1.5rem)'
    } else {
      this.toggleContainerTarget.classList.add('bg-background')
      this.toggleContainerTarget.classList.remove('bg-pop')
      this.toggleHandleTarget.style.transform = 'translateX(0)'
    }
  }
}
