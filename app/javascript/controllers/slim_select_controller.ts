import { Controller } from '@hotwired/stimulus'
import SlimSelect, { Config } from 'slim-select'

// Connects to data-controller="slim-select"
export default class extends Controller {
  static values = { addable: { type: Boolean, default: false } }

  declare addableValue: boolean

  declare slim: SlimSelect

  connect () {
    const options: Config = {
      select: this.element
    }
    if (this.addableValue) {
      options.events = {}
      options.events.addable = (value) => { return value }
    }
    this.slim = new SlimSelect(options)
  }

  disconnect () {
    this.slim.destroy()
  }
}
