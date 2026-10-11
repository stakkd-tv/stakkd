import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="stack-controls"
export default class extends Controller<HTMLFormElement> {
  static targets = [
    'sortingDirectionInput',
    'directionInput',
    'directionIcon',
    'reorderingIcon',
    'reorderingButton',
    'filterInput'
  ]

  declare readonly sortingDirectionInputTarget: HTMLSelectElement
  declare readonly directionInputTarget: HTMLInputElement
  declare readonly directionIconTarget: HTMLElement
  declare readonly reorderingIconTarget: HTMLElement
  declare readonly reorderingButtonTarget: HTMLButtonElement
  declare readonly filterInputTarget: HTMLSelectElement

  declare readonly hasReorderingIconTarget: boolean
  declare readonly hasReorderingButtonTarget: boolean

  submit() {
    if (this.hasReorderingIconTarget && this.hasReorderingButtonTarget) {
      this.reorderingIconTarget.dataset.enabled = 'false'
      this.enableOrDisableReordering()
    }
    this.element.requestSubmit()
  }

  toggleDirection() {
    const current = this.directionInputTarget.value
    const next = current === 'asc' ? 'desc' : 'asc'

    this.directionInputTarget.value = next
    this.directionIconTarget.dataset.direction = next

    this.submit()
  }

  toggleReordering() {
    const current = this.reorderingIconTarget.dataset.enabled
    const next = current === 'true' ? 'false' : 'true'

    this.reorderingIconTarget.dataset.enabled = next

    const stackItems = document.querySelector('#stack_items')
    if (stackItems === null) return
    const stackItemHandles = stackItems.querySelectorAll('.drag-handle')

    if (next === 'true') {
      stackItemHandles.forEach((element) => element.classList.remove('hidden!'))
    } else {
      stackItemHandles.forEach((element) => element.classList.add('hidden!'))
    }
  }

  enableOrDisableReordering() {
    if (this._reorderingCanBeEnabled()) {
      this.reorderingButtonTarget.classList.remove('text-gray-400')
      this.reorderingButtonTarget.disabled = false
    } else {
      this.reorderingButtonTarget.classList.add('text-gray-400')
      this.reorderingButtonTarget.disabled = true
    }
  }

  _reorderingCanBeEnabled() {
    return (
      this.directionInputTarget.value === 'asc' &&
      this.sortingDirectionInputTarget.value === 'position' &&
      this.filterInputTarget.selectedOptions.length === 0
    )
  }
}
