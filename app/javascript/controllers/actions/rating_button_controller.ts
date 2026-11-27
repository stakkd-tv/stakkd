import { Controller } from '@hotwired/stimulus'
import type { RatingConfiguration, RatingSelection } from './rating_controller'

export type RatingDialogDetails = RatingConfiguration & {
  button: HTMLButtonElement
  title: string
  context: string
}

export default class extends Controller<HTMLButtonElement> {
  static targets = ['badgeScore']
  static values = {
    url: String,
    score: Number,
    rateable: Boolean,
    title: String,
    context: String
  }

  declare readonly badgeScoreTarget: HTMLElement
  declare readonly urlValue: string
  declare scoreValue: number
  declare readonly rateableValue: boolean
  declare readonly titleValue: string
  declare readonly contextValue: string

  open() {
    this.dispatch('open', {
      detail: {
        button: this.element,
        url: this.urlValue,
        score: this.scoreValue,
        rateable: this.rateableValue,
        title: this.titleValue,
        context: this.contextValue
      } satisfies RatingDialogDetails
    })
  }

  sync({ detail }: CustomEvent<RatingSelection>) {
    if (detail.url !== this.urlValue) return

    const { score } = detail
    this.scoreValue = score
    this.element.disabled = !this.rateableValue && !score
    this.element.setAttribute(
      'aria-label',
      score
        ? `Edit your ${score}/10 rating for ${this.titleValue}`
        : `Rate ${this.titleValue}`
    )
    this.element.title = score ? `Your rating: ${score}/10` : 'Rate'
    this.element.dataset.rated = String(Boolean(score))
    this.badgeScoreTarget.textContent = score ? String(score) : ''
  }
}
