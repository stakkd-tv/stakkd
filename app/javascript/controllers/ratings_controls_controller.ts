import { Controller } from '@hotwired/stimulus'
import {
  applyDateVisibility,
  datesVisibleFromUrl,
  updateDateVisibilityUrl
} from '../helpers/dateVisibility'

export default class extends Controller<HTMLElement> {
  static targets = [
    'form',
    'items',
    'sort',
    'scores',
    'dates',
    'hideDatesInput',
    'showDates',
    'hideDates'
  ]
  static values = { chronologicalSorts: Array }

  declare readonly formTarget: HTMLFormElement
  declare readonly itemsTarget: HTMLElement
  declare readonly hasItemsTarget: boolean
  declare readonly sortTarget: HTMLSelectElement
  declare readonly scoresTarget: HTMLElement
  declare readonly datesTarget: HTMLElement
  declare readonly chronologicalSortsValue: string[]
  declare readonly hideDatesInputTarget: HTMLInputElement
  declare readonly showDatesTarget: HTMLButtonElement
  declare readonly hideDatesTarget: HTMLButtonElement

  connect() {
    this.syncDates()
    this.revealSelectedScore()
    window.addEventListener('popstate', this.restoreDates)
  }

  disconnect() {
    window.removeEventListener('popstate', this.restoreDates)
  }

  submit(event: Event) {
    const input = event.target
    if (
      input instanceof HTMLInputElement &&
      input.name === 'hidden_media_types[]'
    ) {
      const label = input.closest('label')
      if (label) label.dataset.active = String(!input.checked)
    }
    if (input instanceof HTMLInputElement && input.name === 'score')
      this.revealSelectedScore()
    this.syncDates()
    this.formTarget.requestSubmit()
  }

  syncDates() {
    this.datesTarget.hidden = !this.chronologicalSortsValue.includes(
      this.sortTarget.value
    )
    this.applyDates(this.hideDatesInputTarget.value !== 'true')
  }

  showDates() {
    this.setDates(true)
  }

  hideDates() {
    this.setDates(false)
  }

  preserveCards(event: Event) {
    const stream = event.target
    if (
      !(stream instanceof HTMLElement) ||
      stream.getAttribute('target') !== 'rating_items'
    )
      return

    // An edited score can move into a later batch. Keep its existing card in
    // place, including when removal and re-rating gave it a new database ID.
    const template = stream.querySelector('template')
    if (!template) return

    for (const card of template.content.querySelectorAll(
      'article[data-rating-item]'
    )) {
      const key = card.getAttribute('data-rating-item')
      if (
        key &&
        this.element.querySelector(`[data-rating-item="${CSS.escape(key)}"]`)
      )
        card.remove()
    }

    // Only retained cards establish month boundaries. A batch may contain
    // nothing but edited cards already displayed under their original months.
    const existingMonths = this.itemsTarget.querySelectorAll(
      '[data-rating-month]'
    )
    let previousMonth =
      existingMonths[existingMonths.length - 1]?.getAttribute(
        'data-rating-month'
      )
    for (const heading of template.content.querySelectorAll(
      '[data-rating-month]'
    )) {
      const month = heading.getAttribute('data-rating-month')
      if (
        !heading.nextElementSibling?.matches('article[data-rating-item]') ||
        month === previousMonth
      )
        heading.remove()
      else previousMonth = month
    }
  }

  private setDates(show: boolean) {
    this.applyDates(show)
    updateDateVisibilityUrl(show)
  }

  private revealSelectedScore() {
    const selected = this.scoresTarget
      .querySelector('input:checked')
      ?.closest('label')
    if (!selected) return

    // Scroll only this row, without moving the page when restoring a filter.
    const row = this.scoresTarget.getBoundingClientRect()
    const button = selected.getBoundingClientRect()
    if (button.left < row.left)
      this.scoresTarget.scrollLeft += button.left - row.left
    else if (button.right > row.right)
      this.scoresTarget.scrollLeft += button.right - row.right
  }

  private applyDates(show: boolean) {
    applyDateVisibility(show, {
      input: this.hideDatesInputTarget,
      showButton: this.showDatesTarget,
      hideButton: this.hideDatesTarget,
      items: this.hasItemsTarget ? this.itemsTarget : null,
      enabled: !this.datesTarget.hidden
    })
  }

  private restoreDates = () => {
    this.applyDates(datesVisibleFromUrl())
  }
}
