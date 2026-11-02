import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="history-controls"
export default class extends Controller<HTMLFormElement> {
  static targets = ['showDates', 'hideDates', 'hideDatesInput']

  declare readonly showDatesTarget: HTMLButtonElement
  declare readonly hideDatesTarget: HTMLButtonElement
  declare readonly hideDatesInputTarget: HTMLInputElement

  connect() {
    window.addEventListener('popstate', this.handlePopstate.bind(this))
  }

  disconnect() {
    window.removeEventListener('popstate', this.handlePopstate.bind(this))
  }

  // Always get the freshest grid as turbo interacts with this. The grid
  // may be destroyed/recreated as the user loads more items.
  grid(): HTMLElement {
    return document.querySelector('turbo-frame#history_items')!
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
    this.updateUrl(true)
    this.hideDatesInputTarget.value = ''
  }

  hideDates() {
    this.applyState(false)
    this.updateUrl(false)
    this.hideDatesInputTarget.value = 'true'
  }

  applyState(showDates: boolean) {
    this.grid().dataset.showDates = String(showDates)
    this.showDatesTarget.dataset.active = String(showDates)
    this.hideDatesTarget.dataset.active = String(!showDates)
  }

  updateUrl(showDates: boolean) {
    const url = new URL(window.location.href)
    if (showDates) {
      url.searchParams.delete('hide_dates')
    } else {
      url.searchParams.set('hide_dates', 'true')
    }
    window.history.pushState({}, '', url)
  }

  handlePopstate() {
    const params = new URLSearchParams(window.location.search)
    const hideDates = params.get('hide_dates') === 'true'
    this.applyState(!hideDates)
  }
}
