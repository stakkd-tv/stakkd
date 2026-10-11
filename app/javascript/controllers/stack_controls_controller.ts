import { Controller } from '@hotwired/stimulus'
import Sortable from 'sortablejs'
import { csrfToken } from '../helpers/csrfToken'

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

  declare sortable: Sortable | undefined

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
      this._initializeSortable()
    } else {
      stackItemHandles.forEach((element) => element.classList.add('hidden!'))
      this._destroySortable()
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

  _initializeSortable() {
    if (this.sortable !== undefined) return

    const stackItems = document.querySelector<HTMLElement>('#stack_items')
    if (stackItems === null) return
    this.sortable = new Sortable(stackItems, {
      handle: '.drag-handle',
      ghostClass: 'opacity-50',
      onEnd: this._updatePosition.bind(this)
    })
  }

  _destroySortable() {
    if (this.sortable === undefined) return

    this.sortable.destroy()
    this.sortable = undefined
  }

  async _updatePosition(event: Sortable.SortableEvent) {
    const newPosition = (event.newIndex || 0) + 1
    const element = event.item
    const stackItemUrl = element.dataset.stackItemUrl
    const endpoint = `${stackItemUrl}/move`
    const response = await fetch(endpoint, {
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken()
      },
      method: 'PATCH',
      body: JSON.stringify({ position: newPosition })
    })
    if (!response.ok) {
      console.error(response.status)
    }
  }
}
