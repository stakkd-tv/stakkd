import DialogController from '../dialog_controller'

// Connects to data-controller="deletion-dialog"
export default class extends DialogController {
  // URL values
  declare deleteRecordUrl: string

  connect() {
    super.connect()

    this.deleteRecordUrl = ''
  }

  setVariables(detail: {
    button: HTMLButtonElement
    deleteRecordUrl: string
  }): void {
    this.deleteRecordUrl = detail.deleteRecordUrl
  }

  resetVariables() {
    this.deleteRecordUrl = ''
  }

  async submit() {
    const url = this.deleteRecordUrl
    if (!url) {
      return
    }

    const response = await this._sendRequest(url, 'DELETE', null)

    if (!response.ok) {
      // TODO: Alert the user that it could not be added to history
      console.error(response.status)
      return
    }

    this._broadcastUpdates()

    this.close()
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

  _broadcastUpdates() {
    this.dispatch('deleted', {
      target: window,
      detail: {
        target: this.triggeredBy
      }
    })
  }
}
