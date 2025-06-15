import { Controller } from '@hotwired/stimulus'
import SlimSelect from 'slim-select'

// Connects to data-controller="slim-select"
export default class extends Controller {
  declare slim: SlimSelect

  connect () {
    this.slim = new SlimSelect({
      select: this.element
    })
  }

  disconnect () {
    this.slim.destroy()
  }
}
