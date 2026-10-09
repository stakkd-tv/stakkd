import { Controller } from '@hotwired/stimulus'
import SlimSelect, { Config } from 'slim-select'

// Connects to data-controller="slim-select"
export default class extends Controller {
  static values = {
    addable: { type: Boolean, default: false },
    searchable: { type: Boolean, default: true }
  }

  declare addableValue: boolean
  declare searchableValue: boolean

  declare slim: SlimSelect

  connect() {
    const options: Config = {
      select: this.element,
      settings: {
        showSearch: this.searchableValue
      }
    }
    if (this.addableValue) {
      options.events = {}
      options.events.addable = (value) => {
        return value
      }
    }
    this.slim = new SlimSelect(options)
  }

  disconnect() {
    this.slim.destroy()
  }
}
