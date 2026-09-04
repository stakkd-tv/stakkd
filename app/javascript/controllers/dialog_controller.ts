import { Controller } from '@hotwired/stimulus'

// Abstract controller, does not connect to anything
export default class extends Controller {
  declare triggeredBy: HTMLButtonElement | null
  declare dialog: HTMLDialogElement

  connect() {
    this.dialog = this.element as HTMLDialogElement

    this.handleKeydown = this.handleKeydown.bind(this)
    this.handleCancel = this.handleCancel.bind(this)

    document.addEventListener('keydown', this.handleKeydown)
    this.dialog.addEventListener('cancel', this.handleCancel)
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleKeydown)
    this.dialog.removeEventListener('cancel', this.handleCancel)
  }

  handleKeydown(event: KeyboardEvent) {
    if (event.key === 'Escape' && this.dialog.open) {
      event.preventDefault()
      this.close()
    }
  }

  handleCancel(event: Event) {
    event.preventDefault()
    this.close()
  }

  open(event: { detail: { button: HTMLButtonElement } }) {
    this.triggeredBy = event.detail.button

    this.setVariables(event.detail)

    this.dialog.showModal()
    document.documentElement.style.overflow = 'hidden'
  }

  close() {
    if (this.dialog.open) {
      this.dialog.close()
    }
    this.triggeredBy = null
    this.resetVariables()
    document.documentElement.style.overflow = ''
  }

  setVariables(detail: {}) {
    throw new Error('setVariables must be implemented by subclasses')
  }

  resetVariables() {
    throw new Error('resetVariables must be implemented by subclasses')
  }
}
