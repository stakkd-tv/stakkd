import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="stack-dialog"
export default class extends Controller {
  static targets = [
    'stack',
    'createStackForm',
    'availableStacks',
    'stackPlaceholder'
  ]

  declare stackTargets: HTMLButtonElement[]
  declare createStackFormTarget: HTMLFormElement
  declare availableStacksTarget: HTMLDivElement
  declare stackPlaceholderTarget: HTMLButtonElement

  declare triggeredBy: HTMLButtonElement | null
  declare dialog: HTMLDialogElement
  declare stacksForThisRecord: number[]

  // URL values
  declare addToStackUrl: string
  declare removeFromStackUrl: string

  connect() {
    this.dialog = this.element as HTMLDialogElement
    this.stacksForThisRecord = []

    this.addToStackUrl = ''
    this.removeFromStackUrl = ''

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

  open(event: {
    detail: {
      button: HTMLButtonElement
      stacksForThisRecord: number[]
      addToStackUrl: string
      createAndAddToStackUrl: string
      removeFromStackUrl: string
    }
  }) {
    this.triggeredBy = event.detail.button
    this.stacksForThisRecord = event.detail.stacksForThisRecord
    this.stackTargets.forEach((stack) => {
      stack.dataset.active = this._recordIsInStack(stack)
    })

    this.addToStackUrl = event.detail.addToStackUrl
    this.createStackFormTarget.action = event.detail.createAndAddToStackUrl
    this.removeFromStackUrl = event.detail.removeFromStackUrl

    this.dialog.showModal()
    document.documentElement.style.overflow = 'hidden'
  }

  close() {
    if (this.dialog.open) {
      this.dialog.close()
    }
    this.resetVariables()
  }

  resetVariables() {
    this.triggeredBy = null
    this.stacksForThisRecord = []
    this.stackTargets.forEach((target) => {
      target.dataset.active = 'false'
    })
    this.addToStackUrl = ''
    this.createStackFormTarget.action = ''
    this.removeFromStackUrl = ''
    document.documentElement.style.overflow = ''
  }

  async select(event: { currentTarget: HTMLButtonElement }) {
    const button = event.currentTarget
    button.disabled = true

    const active = button.dataset.active ?? 'false'
    const stackId = button.dataset.stackId ?? ''

    let method = 'POST'
    let url = this.addToStackUrl
    const body = JSON.stringify({ stack_id: stackId })
    const newState = active === 'true' ? 'false' : 'true'

    if (active === 'true') {
      method = 'DELETE'
      url = this.removeFromStackUrl
    } else {
      method = 'POST'
      url = this.addToStackUrl
    }

    const response = await this._sendRequest(url, method, body)
    if (response.ok) {
      const json = await response.json()

      button.dataset.active = newState
      this._broadcastUpdatedStacksForRecord(json.stacks_for_this_record)
    }
    button.disabled = false
  }

  async createAndAddToStack(event: Event) {
    event.preventDefault()
    const stackNameInput = this.createStackFormTarget.querySelector(
      '#stack_name'
    ) as HTMLInputElement
    if (stackNameInput.value.trim() === '') {
      stackNameInput.focus()
      return
    }

    const response = await this._sendRequest(
      this.createStackFormTarget.action,
      'POST',
      new FormData(this.createStackFormTarget),
      null
    )

    if (!response.ok) {
      // TODO: Alert the user that it could not be added to stack
      console.error(response.status)
      return
    }

    const json = await response.json()
    const newStackName = json.stack.name
    const newStackId = json.stack.id

    stackNameInput.value = ''
    const newStackButton =
      this.stackPlaceholderTarget.cloneNode() as HTMLButtonElement
    newStackButton.textContent = newStackName
    newStackButton.dataset.stackId = newStackId
    newStackButton.dataset.stackDialogTarget = 'stack'
    newStackButton.dataset.active = 'true'
    newStackButton.classList.remove('hidden')
    this.availableStacksTarget.appendChild(newStackButton)
    this._broadcastUpdatedStacksForRecord(json.stacks_for_this_record)
  }

  async _sendRequest(
    url: string,
    method: string,
    body: BodyInit | null | undefined,
    contentType: string | null = 'application/json'
  ) {
    const csrfToken =
      document
        .querySelector('meta[name="csrf-token"]')
        ?.getAttribute('content') ?? ''

    const headers: HeadersInit = {
      Accept: 'application/json',
      'X-CSRF-Token': csrfToken
    }

    if (contentType) {
      headers['Content-Type'] = contentType
    }

    return fetch(url, {
      method,
      body,
      headers
    })
  }

  _recordIsInStack(stack: HTMLElement) {
    const targetStackId = Number(stack.dataset.stackId)
    return String(this.stacksForThisRecord.includes(targetStackId))
  }

  _broadcastUpdatedStacksForRecord(stackIds: number[]) {
    this.dispatch('updated-stacks', {
      target: window,
      detail: {
        target: this.triggeredBy,
        updatedStacks: stackIds
      }
    })
  }
}
