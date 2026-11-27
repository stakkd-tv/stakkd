import { Controller } from '@hotwired/stimulus'
import {
  applyDateVisibility,
  datesVisibleFromUrl,
  updateDateVisibilityUrl
} from '../helpers/dateVisibility'

// Connects to data-controller="history-controls"
export default class extends Controller<HTMLFormElement> {
  static targets = ['showDates', 'hideDates', 'hideDatesInput']

  declare readonly showDatesTarget: HTMLButtonElement
  declare readonly hideDatesTarget: HTMLButtonElement
  declare readonly hideDatesInputTarget: HTMLInputElement

  connect() {
    window.addEventListener('popstate', this.handlePopstate)
  }

  disconnect() {
    window.removeEventListener('popstate', this.handlePopstate)
  }

  // Always get the freshest grid as turbo interacts with this. The grid
  // may be destroyed/recreated as the user loads more items.
  grid(): HTMLElement | null {
    return document.querySelector('turbo-frame#history_items')
  }

  toggleMediaType(event: { currentTarget: HTMLElement }) {
    const checkbox = event.currentTarget
    const button = checkbox.parentElement
    if (button === null) return

    const active = button.dataset.active === 'true'
    button.dataset.active = String(!active)

    this.element.requestSubmit()
  }

  showDates() {
    this.applyState(true)
    updateDateVisibilityUrl(true)
  }

  hideDates() {
    this.applyState(false)
    updateDateVisibilityUrl(false)
  }

  applyState(showDates: boolean) {
    applyDateVisibility(showDates, {
      input: this.hideDatesInputTarget,
      showButton: this.showDatesTarget,
      hideButton: this.hideDatesTarget,
      items: this.grid()
    })
  }

  private handlePopstate = () => {
    this.applyState(datesVisibleFromUrl())
  }
}
