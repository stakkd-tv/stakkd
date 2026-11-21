import { Controller } from '@hotwired/stimulus'

export default class extends Controller<HTMLFormElement> {
  submit(event: Event) {
    const input = event.target
    if (
      input instanceof HTMLInputElement &&
      input.name === 'hidden_media_types[]'
    ) {
      const label = input.closest('label')
      if (label) label.dataset.active = String(!input.checked)
    }

    this.element.requestSubmit()
  }
}
