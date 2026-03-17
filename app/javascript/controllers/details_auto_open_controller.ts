import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="details-auto-open"
export default class extends Controller {
  connect () {
    const screenWidth = window.innerWidth
    const open = screenWidth >= 768
    const detailTags = this.element.querySelectorAll('details[data-auto-open]')

    if (open) {
      detailTags.forEach(tag => {
        tag.setAttribute('open', 'open')
      })
    } else {
      detailTags.forEach(tag => {
        tag.removeAttribute('open')
      })
    }
  }
}
