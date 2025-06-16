import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="form-nav"
export default class extends Controller {
  static targets = ['formNav', 'leftGrad', 'rightGrad']

  declare formNavTarget: HTMLElement
  declare leftGradTarget: HTMLElement
  declare rightGradTarget: HTMLElement

  connect () {
    this.scroll()
    this.formNavTarget.addEventListener('scroll', this.scroll.bind(this))

    const activeElement = this.formNavTarget.querySelector('a[data-active="true"]') as HTMLElement
    if (activeElement === null) { return }

    const scrollLeft = activeElement.offsetLeft - this.formNavTarget.clientWidth / 2 + activeElement.clientWidth / 2

    this.formNavTarget.scroll({
      left: scrollLeft,
      behavior: 'instant'
    })
  }

  scroll () {
    const max = this.formNavTarget.scrollWidth - this.formNavTarget.clientWidth - 10
    if (this.formNavTarget.scrollLeft < 10) {
      this.leftGradTarget.classList.add('opacity-0')
      this.leftGradTarget.classList.remove('opacity-100')
    } else {
      this.leftGradTarget.classList.remove('opacity-0')
      this.leftGradTarget.classList.add('opacity-100')
    }

    if (this.formNavTarget.scrollLeft > max) {
      this.rightGradTarget.classList.add('opacity-0')
      this.rightGradTarget.classList.remove('opacity-100')
    } else {
      this.rightGradTarget.classList.remove('opacity-0')
      this.rightGradTarget.classList.add('opacity-100')
    }
  }
}
