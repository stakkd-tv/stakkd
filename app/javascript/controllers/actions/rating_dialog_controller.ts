import DialogController from '../dialog_controller'
import type { RatingDialogDetails } from './rating_button_controller'

export default class extends DialogController {
  static targets = ['title', 'context', 'picker']

  declare readonly titleTarget: HTMLElement
  declare readonly contextTarget: HTMLElement
  declare readonly pickerTarget: HTMLElement

  setVariables(detail: RatingDialogDetails) {
    this.titleTarget.textContent = detail.title
    this.contextTarget.textContent = detail.context
    this.dispatch('configure', { target: this.pickerTarget, detail })
  }

  resetVariables() {
    this.titleTarget.textContent = ''
    this.contextTarget.textContent = ''
  }
}
