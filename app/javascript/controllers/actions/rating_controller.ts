import { Controller } from '@hotwired/stimulus'
import { csrfToken } from '../../helpers/csrfToken'

export type RatingSelection = { url: string; score: number }
export type RatingConfiguration = RatingSelection & { rateable: boolean }

export default class extends Controller<HTMLElement> {
  static targets = ['picker', 'star', 'status', 'label', 'removeHint', 'error']
  static values = {
    url: String,
    score: Number,
    rateable: Boolean
  }

  declare readonly pickerTarget: HTMLElement
  declare readonly starTargets: HTMLButtonElement[]
  declare readonly statusTarget: HTMLElement
  declare readonly labelTarget: HTMLElement
  declare readonly removeHintTarget: HTMLElement
  declare readonly errorTarget: HTMLElement
  declare urlValue: string
  declare scoreValue: number
  declare rateableValue: boolean

  private hovered = 0
  private focused = 0
  private pending: { url: string; score: number } | null = null

  configure({ detail }: CustomEvent<RatingConfiguration>) {
    this.urlValue = detail.url
    this.scoreValue = detail.score
    this.rateableValue = detail.rateable
    this.hovered = this.focused = 0
    this.showError('')
    this.render()
  }

  hover(event: PointerEvent) {
    if (event.pointerType === 'touch' || this.pending) return

    this.hovered = Number(
      (event.currentTarget as HTMLButtonElement).dataset.score
    )
    this.render()
  }

  focus(event: FocusEvent) {
    const button = event.currentTarget as HTMLButtonElement
    this.focused = button.matches(':focus-visible')
      ? Number(button.dataset.score)
      : 0
    this.render()
  }

  clearHover() {
    this.hovered = 0
    this.render()
  }

  clearFocus() {
    this.focused = 0
    this.render()
  }

  async save(event: Event) {
    if (this.pending) return

    const value = Number(
      (event.currentTarget as HTMLButtonElement).dataset.score
    )
    const removing = value === this.scoreValue
    if (!removing && !this.rateableValue) return

    const url = this.urlValue
    this.pending = { url, score: removing ? this.scoreValue : value }
    this.hovered = this.focused = 0
    this.showError('')
    this.render()

    try {
      const response = await fetch(url, {
        method: removing ? 'DELETE' : 'PUT',
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken()
        },
        body: removing ? undefined : JSON.stringify({ score: value })
      })
      if (response.status === 422) {
        const { errors } = await response.json()
        if (url === this.urlValue) {
          this.showError(
            errors?.join(' ') || 'Could not save your rating. Try again.'
          )
        }
        return
      }
      if (!response.ok || response.redirected)
        throw new Error('Rating request failed')

      const { score } = await response.json()
      this.dispatch('changed', {
        detail: { url, score: score ?? 0 }
      })
    } catch {
      if (url === this.urlValue)
        this.showError('Could not save your rating. Try again.')
    } finally {
      this.pending = null
      this.render()
    }
  }

  sync({ detail }: CustomEvent<RatingSelection>) {
    if (detail.url !== this.urlValue) return

    this.scoreValue = detail.score
    this.render()
  }

  private scoreLabel(score: number) {
    return this.starTargets[score - 1]?.dataset.scoreLabel ?? 'Unrated'
  }

  private render() {
    const preview = this.hovered || this.focused
    const pendingScore =
      this.pending?.url === this.urlValue ? this.pending.score : 0
    const displayedScore = pendingScore || preview || this.scoreValue
    const status = `Your rating: ${this.scoreLabel(this.scoreValue)}`
    if (this.statusTarget.textContent !== status)
      this.statusTarget.textContent = status
    this.labelTarget.textContent = this.scoreLabel(displayedScore)
    this.removeHintTarget.hidden = this.scoreValue === 0
    this.pickerTarget.setAttribute('aria-busy', String(Boolean(this.pending)))

    for (const button of this.starTargets) {
      const value = Number(button.dataset.score)
      const selected = value === this.scoreValue
      button.dataset.filled = String(value <= displayedScore)
      button.disabled = !this.rateableValue && !selected
      button.setAttribute(
        'aria-disabled',
        String(Boolean(this.pending) || button.disabled)
      )
      button.setAttribute('aria-pressed', String(selected))
      button.setAttribute(
        'aria-label',
        selected ? `Remove your ${value}/10 rating` : `Rate ${value} out of 10`
      )
    }
  }

  private showError(message: string) {
    this.errorTarget.textContent = message
    this.errorTarget.classList.toggle('hidden', !message)
  }
}
