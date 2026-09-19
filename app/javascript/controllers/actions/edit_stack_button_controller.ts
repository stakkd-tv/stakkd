import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="edit-stack-button"
export default class extends Controller {
  static values = {
    updateStackUrl: String,
    stackId: Number,
    name: String,
    description: String,
    sortingMethod: String,
    sortingDirection: String,
    private: Boolean
  }

  declare updateStackUrlValue: string
  declare stackIdValue: number
  declare nameValue: string
  declare descriptionValue: string
  declare sortingMethodValue: string
  declare sortingDirectionValue: string
  declare privateValue: boolean

  declare nameTextElements: HTMLElement[]
  declare descriptionTextElements: HTMLElement[]
  declare privateNotes: HTMLElement[]

  connect(): void {
    this.nameTextElements = Array.from(
      document.querySelectorAll(`.stack_${this.stackIdValue}_name`)
    )
    this.descriptionTextElements = Array.from(
      document.querySelectorAll(`.stack_${this.stackIdValue}_description`)
    )
    this.privateNotes = Array.from(
      document.querySelectorAll(`.stack_${this.stackIdValue}_private`)
    )
  }

  open() {
    if (this.element instanceof HTMLButtonElement) {
      this.element.blur()
      this.dispatch('open', {
        target: window,
        detail: {
          button: this.element,
          updateStackUrl: this.updateStackUrlValue,
          name: this.nameValue,
          description: this.descriptionValue,
          sortingMethod: this.sortingMethodValue,
          sortingDirection: this.sortingDirectionValue,
          private: this.privateValue
        }
      })
    }
  }

  update(event: {
    detail: {
      target: HTMLElement
      updatedAttributes: {
        name: string
        description: string
        sorting_method: string
        sorting_direction: string
        private: boolean
      }
    }
  }) {
    if (this.element !== event.detail.target) return
    this.nameValue = event.detail.updatedAttributes.name
    this.nameTextElements.forEach((el) => {
      el.textContent = this.nameValue
    })
    this.descriptionValue = event.detail.updatedAttributes.description
    this.descriptionTextElements.forEach((el) => {
      el.textContent = this.descriptionValue
    })
    this.sortingMethodValue = event.detail.updatedAttributes.sorting_method
    this.sortingDirectionValue =
      event.detail.updatedAttributes.sorting_direction
    this.privateValue = event.detail.updatedAttributes.private
    this.privateNotes.forEach((el) => {
      if (this.privateValue) {
        el.classList.remove('hidden')
      } else {
        el.classList.add('hidden')
      }
    })
  }
}
