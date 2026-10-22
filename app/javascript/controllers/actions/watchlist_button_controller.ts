import { Controller } from '@hotwired/stimulus'
import { csrfToken } from '../../helpers/csrfToken'

// Connects to data-controller="watchlist-button"
export default class extends Controller {
  static values = { watchlisted: Boolean, recordPath: String }
  static targets = ['activeState', 'inactiveState']

  declare watchlistedValue: boolean
  declare recordPathValue: string

  declare readonly activeStateTarget: HTMLElement
  declare readonly inactiveStateTarget: HTMLElement

  async submit() {
    const endpoint = this.watchlistedValue
      ? 'remove_from_watchlist'
      : 'add_to_watchlist'
    const method = this.watchlistedValue ? 'DELETE' : 'POST'
    const url = `/${this.recordPathValue.split('/').filter(Boolean).join('/')}/${endpoint}`
    const response = await this._sendRequest(url, method)
    if (!response.ok) {
      // TODO: Show an error?
      console.error(
        `Could not ${this.watchlistedValue ? 'remove from' : 'add to'} watchlist`
      )
    } else {
      this.watchlistedValue = !this.watchlistedValue
      this.activeStateTarget.classList.toggle('hidden!')
      this.inactiveStateTarget.classList.toggle('hidden!')
    }
  }

  async _sendRequest(url: string, method: string) {
    return fetch(url, {
      method,
      headers: {
        Accept: 'application/json',
        'X-CSRF-Token': csrfToken()
      }
    })
  }
}
