import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    selector: String
  }

  declare selectorValue: string

  connect () {
    this.onDocumentClick = this.onDocumentClick.bind(this)

    this.element.addEventListener('click', this.toggle.bind(this))
    document.addEventListener('click', this.onDocumentClick)
  }

  disconnect () {
    document.removeEventListener('click', this.onDocumentClick)
  }

  toggle (event: Event) {
    event.stopPropagation()

    const menu = document.querySelector(this.selectorValue)
    menu?.classList.toggle('opacity-0')
    menu?.classList.toggle('pointer-events-none')

    this.element.classList.toggle('border-transparent')
    this.element.classList.toggle('border-pop')
  }

  onDocumentClick (event: Event) {
    const menu = document.querySelector(this.selectorValue)
    const target = event.target as Node

    if (
      this.element.contains(target) ||
      menu?.contains(target)
    ) {
      return
    }

    menu?.classList.add('opacity-0', 'pointer-events-none')
    this.element.classList.remove('border-pop')
    this.element.classList.add('border-transparent')
  }
}
