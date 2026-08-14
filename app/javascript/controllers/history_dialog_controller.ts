import { Controller } from '@hotwired/stimulus'
import flatpickr from 'flatpickr'
import { Instance } from 'flatpickr/dist/types/instance'

const OPTIONS = ['now', 'release_date', 'date', 'unknown']

// Connects to data-controller="history-dialog"
export default class extends Controller {
  static targets = [
    'form',
    'consumedAtInput',
    'consumedAtInputContainer',
    'consumedAtType',
    'removeFromHistoryButton'
  ]

  declare readonly formTarget: HTMLFormElement
  declare readonly consumedAtInputTarget: HTMLInputElement
  declare readonly consumedAtInputContainerTarget: HTMLDivElement
  declare readonly consumedAtTypeTarget: HTMLInputElement
  declare readonly removeFromHistoryButtonTarget: HTMLButtonElement

  declare triggeredBy: HTMLButtonElement | null
  declare optionButtons: HTMLButtonElement[]
  declare dialog: HTMLDialogElement
  declare currentOption: string
  declare currentOptionButton: HTMLButtonElement
  declare flatpickrInstance: Instance

  connect() {
    this.dialog = this.element as HTMLDialogElement
    this.flatpickrInstance = flatpickr(this.consumedAtInputTarget, {
      enableTime: true,
      disableMobile: false,
      appendTo: this.dialog,

      onOpen: (_, __, instance) => {
        const positionCalendar = () => {
          const rect = this.consumedAtInputTarget.getBoundingClientRect()
          const calendar = instance.calendarContainer

          calendar.style.position = 'fixed'
          calendar.style.top = `${rect.bottom + 5}px`
          calendar.style.left = `${rect.left}px`
        }

        requestAnimationFrame(positionCalendar)
      }
    })

    this.optionButtons = Array.from(
      this.dialog.querySelectorAll('button[data-option]')
    )
    this.currentOption = OPTIONS[0]
    this.currentOptionButton = this.optionButtons[0]
  }

  open(event: {
    detail: {
      button: HTMLButtonElement
      addToHistoryUrl: string
      removeFromHistoryUrl: string
    }
  }) {
    this.triggeredBy = event.detail.button
    if (
      this.triggeredBy.dataset.status === 'watched' ||
      this.triggeredBy.dataset.status === 'partially_watched'
    ) {
      this.removeFromHistoryButtonTarget.classList.remove('hidden')
    } else {
      this.removeFromHistoryButtonTarget.classList.add('hidden')
    }

    this.formTarget.action = event.detail.addToHistoryUrl
    this.removeFromHistoryButtonTarget.dataset.removeFromHistoryUrl =
      event.detail.removeFromHistoryUrl

    this.dialog.showModal()
    document.documentElement.style.overflow = 'hidden'
  }

  close() {
    this.dialog.close()
    this.triggeredBy = null
    this.formTarget.action = ''
    this.removeFromHistoryButtonTarget.dataset.removeFromHistoryUrl = ''
    this._setOption(OPTIONS[0], this.optionButtons[0])
    this.consumedAtInputTarget.value = ''
    document.documentElement.style.overflow = ''
  }

  async removeFromHistory() {
    const url = this.removeFromHistoryButtonTarget.dataset.removeFromHistoryUrl
    if (!url) {
      return
    }

    const response = await this._sendRequest(url, 'DELETE', null)

    if (!response.ok) {
      // TODO: Alert the user that it could not be added to history
      console.error(response.status)
      return
    }

    const json = await response.json()
    const affectedItems = json.affected_items
    this._broadcastUpdates(affectedItems)

    this.close()
    this.formTarget.reset()
  }

  async submit(event: Event) {
    event.preventDefault()
    if (
      this.currentOption === 'date' &&
      this.consumedAtInputTarget.value === ''
    ) {
      this.consumedAtInputTarget.focus()
      return
    }

    const response = await this._sendRequest(
      this.formTarget.action,
      'POST',
      new FormData(this.formTarget)
    )

    if (!response.ok) {
      // TODO: Alert the user that it could not be added to history
      console.error(response.status)
      return
    }

    const json = await response.json()
    const affectedItems = json.affected_items
    this._broadcastUpdates(affectedItems)

    this.close()
    this.formTarget.reset()
  }

  setOption(event: { target: HTMLButtonElement }) {
    const option = event.target.dataset.option as string
    this._setOption(option, event.target)
  }

  _setOption(option: string, button: HTMLButtonElement) {
    if (OPTIONS.includes(option)) {
      this.currentOption = option
      this.currentOptionButton.setAttribute('data-active', 'false')
      this.currentOptionButton = button
      button.setAttribute('data-active', 'true')
      this.consumedAtTypeTarget.value = option

      if (option === 'date') {
        this.consumedAtInputContainerTarget.classList.remove('hidden')
      } else {
        this.consumedAtInputContainerTarget.classList.add('hidden')
      }
    }
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

  _broadcastUpdates(statuses: Record<string, string>) {
    Object.keys(statuses).forEach((target) => {
      const status = statuses[target]
      this.dispatch('status-update', {
        target: window,
        detail: {
          target,
          status
        }
      })
    })
  }
}
