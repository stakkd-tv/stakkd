import { Controller } from '@hotwired/stimulus'

export default class extends Controller<HTMLDetailsElement> {
  static targets = ['answer']

  declare readonly answerTarget: HTMLElement
  private animation?: Animation

  animateToggle(event: MouseEvent) {
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return

    event.preventDefault()
    // Wait for the current animation to settle the open state before toggling again.
    if (this.animation) return

    const opening = !this.element.open
    if (opening) this.element.open = true

    const answer = this.answerTarget
    const collapsed = { height: '0px', opacity: 0 }
    const expanded = { height: `${answer.offsetHeight}px`, opacity: 1 }
    this.animation = answer.animate(
      opening ? [collapsed, expanded] : [expanded, collapsed],
      {
        duration: opening ? 200 : 150,
        easing: 'ease-in-out'
      }
    )
    this.animation.onfinish = () => {
      this.element.open = opening
      this.animation = undefined
    }
  }

  disconnect() {
    this.animation?.cancel()
    this.animation = undefined
  }
}
