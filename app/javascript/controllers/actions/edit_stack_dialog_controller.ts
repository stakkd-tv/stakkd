import DialogController from '../dialog_controller'

// Connects to data-controller="edit-stack-dialog"
export default class extends DialogController {
  static targets = ['form']

  declare formTarget: HTMLFormElement

  declare nameInput: HTMLInputElement
  declare descriptionInput: HTMLInputElement
  declare sortingMethodSelect: HTMLSelectElement
  declare sortingDirectionSelect: HTMLSelectElement
  declare privateToggle: HTMLDivElement

  declare nameInputError: HTMLElement
  declare descriptionInputError: HTMLElement

  declare FIELD_MAP: Record<
    string,
    { element: HTMLElement; errorElement: HTMLElement | null }
  >

  connect(): void {
    super.connect()

    this.nameInput = this.formTarget.querySelector<HTMLInputElement>(
      '[name="stack[name]"]'
    )!
    this.descriptionInput = this.formTarget.querySelector<HTMLInputElement>(
      '[name="stack[description]"]'
    )!
    this.sortingMethodSelect = this.formTarget.querySelector<HTMLSelectElement>(
      '[name="stack[sorting_method]"]'
    )!
    this.sortingDirectionSelect =
      this.formTarget.querySelector<HTMLSelectElement>(
        '[name="stack[sorting_direction]"]'
      )!
    this.privateToggle = this.formTarget.querySelector('#stack_private')!

    this.nameInputError = this.formTarget.querySelector('#stack_name_error')!
    this.descriptionInputError = this.formTarget.querySelector(
      '#stack_description_error'
    )!

    this.FIELD_MAP = {
      name: { element: this.nameInput, errorElement: this.nameInputError },
      description: {
        element: this.descriptionInput,
        errorElement: this.descriptionInputError
      },
      sorting_method: { element: this.sortingMethodSelect, errorElement: null },
      sorting_direction: {
        element: this.sortingDirectionSelect,
        errorElement: null
      }
    }
  }

  setVariables(detail: {
    button: HTMLButtonElement
    updateStackUrl: string
    name: string
    description: string
    sortingMethod: string
    sortingDirection: string
    private: boolean
  }): void {
    this.formTarget.action = detail.updateStackUrl
    this.nameInput.value = detail.name
    this.descriptionInput.value = detail.description
    this.sortingMethodSelect.value = detail.sortingMethod
    this.sortingDirectionSelect.value = detail.sortingDirection
    this._broadcastPrivateToggle(detail.private)
  }

  resetVariables() {
    this.formTarget.action = ''
    this.nameInput.value = ''
    this.descriptionInput.value = ''
    this.sortingMethodSelect.value = this.sortingMethodSelect.options[0].value
    this.sortingDirectionSelect.value =
      this.sortingDirectionSelect.options[0].value
    this._broadcastPrivateToggle(false)

    this.nameInput.dataset.fieldError = 'false'
    this.descriptionInput.dataset.fieldError = 'false'
    this.sortingMethodSelect.dataset.fieldError = 'false'
    this.sortingDirectionSelect.dataset.fieldError = 'false'

    this.nameInputError.textContent = ''
    this.descriptionInputError.textContent = ''
    this.nameInputError.classList.add('hidden')
    this.descriptionInputError.classList.add('hidden')
  }

  async submit(event: Event) {
    event.preventDefault()

    const response = await this._sendRequest(
      this.formTarget.action,
      'PATCH',
      new FormData(this.formTarget)
    )
    const json = await response.json()

    if (!response.ok) {
      const errors = json.errors
      errors.forEach((error: Record<string, string[]>) => {
        const field = Object.keys(error)[0]
        if (field in this.FIELD_MAP) {
          const element = this.FIELD_MAP[field].element
          element.dataset.fieldError = 'true'
          const errorElement = this.FIELD_MAP[field].errorElement
          if (errorElement) {
            errorElement.textContent = error[field].join(', ')
            errorElement.classList.remove('hidden')
          }
        }
      })
      return
    }

    this._broadcastUpdate(json)

    this.close()
    this.formTarget.reset()
  }

  async _sendRequest(
    url: string,
    method: string,
    body: BodyInit | null | undefined
  ) {
    const csrfToken =
      document
        .querySelector('meta[name="csrf-token"]')
        ?.getAttribute('content') ?? ''
    return fetch(url, {
      method,
      body,
      headers: {
        Accept: 'application/json',
        'X-CSRF-Token': csrfToken
      }
    })
  }

  _broadcastUpdate(updatedAttributes: Record<string, string>) {
    this.dispatch('updated-stack', {
      target: window,
      detail: {
        target: this.triggeredBy,
        updatedAttributes
      }
    })
  }

  _broadcastPrivateToggle(checked: boolean) {
    this.dispatch('toggle', {
      target: window,
      detail: {
        target: this.privateToggle,
        checked
      }
    })
  }
}
