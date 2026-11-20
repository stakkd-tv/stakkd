import { csrfToken } from '../../helpers/csrfToken'
import DialogController from '../dialog_controller'

type Format = { id?: number; name: string; count: number }
type CollectionState = {
  title: string
  container: boolean
  excludes_specials: boolean
  total: number
  owned: number
  can_add: boolean
  formats: Format[]
  affected_items: Record<string, string>
}
type DialogDetail = {
  button: HTMLButtonElement
  stateUrl: string
  addUrl: string
  removeFormatsUrl: string
  removeUrl: string
}
type Screen = 'loading' | 'overview' | 'add' | 'remove' | 'confirm'

export default class extends DialogController {
  static targets = [
    'recordTitle',
    'ownership',
    'content',
    'screen',
    'summary',
    'addAction',
    'removeAction',
    'removeCollectionAction',
    'addHeading',
    'scopeChoices',
    'ownedScopeLabel',
    'allScopeLabel',
    'addFormats',
    'removeFormats',
    'customName',
    'preview',
    'removalSummary',
    'error',
    'backButton',
    'submitButton'
  ]
  declare recordTitleTarget: HTMLElement
  declare ownershipTarget: HTMLElement
  declare contentTarget: HTMLElement
  declare screenTargets: HTMLElement[]
  declare summaryTarget: HTMLElement
  declare addActionTarget: HTMLButtonElement
  declare removeCollectionActionTarget: HTMLButtonElement
  declare removeActionTarget: HTMLButtonElement
  declare addHeadingTarget: HTMLElement
  declare scopeChoicesTarget: HTMLElement
  declare ownedScopeLabelTarget: HTMLElement
  declare allScopeLabelTarget: HTMLElement
  declare addFormatsTarget: HTMLElement
  declare removeFormatsTarget: HTMLElement
  declare customNameTarget: HTMLInputElement
  declare previewTarget: HTMLElement
  declare removalSummaryTarget: HTMLElement
  declare errorTarget: HTMLElement
  declare backButtonTarget: HTMLButtonElement
  declare submitButtonTarget: HTMLButtonElement
  private detail?: DialogDetail
  private state?: CollectionState
  private screen: Screen = 'loading'
  private episodeScope: 'owned' | 'all' = 'all'
  private drafts: Format[] = []
  private selected = new Set<string>()
  private request?: AbortController
  private generation = 0
  private busy = false

  setVariables(detail: DialogDetail) {
    this.resetVariables()
    this.detail = detail
    this.load()
  }

  resetVariables() {
    this.generation++
    this.request?.abort()
    this.request = undefined
    this.detail = undefined
    this.state = undefined
    this.clearDrafts()
    this.episodeScope = 'all'
    this.element.querySelector('form')?.reset()
    for (const target of [
      this.recordTitleTarget,
      this.summaryTarget,
      this.addFormatsTarget,
      this.removeFormatsTarget,
      this.previewTarget,
      this.removalSummaryTarget,
      this.ownedScopeLabelTarget,
      this.allScopeLabelTarget,
      this.errorTarget
    ]) {
      target.replaceChildren()
    }
    this.ownershipTarget.textContent = 'Loading collection…'
    this.addHeadingTarget.textContent = 'Add to collection'
    this.addActionTarget.textContent = 'Add formats…'
    this.scopeChoicesTarget.classList.add('hidden')
    this.showScreen('loading')
    this.setBusy(false)
  }

  disconnect() {
    this.resetVariables()
    super.disconnect()
  }

  private clearDrafts() {
    this.drafts = []
    this.selected.clear()
    this.customNameTarget.value = ''
  }

  private async requestState(
    url: string,
    options: RequestInit,
    message: string
  ): Promise<CollectionState> {
    const response = await fetch(url, {
      ...options,
      headers: { Accept: 'application/json', 'X-CSRF-Token': csrfToken() }
    })
    if (response.redirected)
      throw new Error('Please sign in again to access your collection.')
    if (!response.ok) {
      const result = await response.json().catch(() => ({}))
      throw new Error(result.errors?.join(' ') || message)
    }
    return response.json()
  }

  private showError(error: unknown, generation: number) {
    if (generation === this.generation) {
      this.errorTarget.textContent =
        error instanceof Error
          ? error.message
          : 'Could not update collection. Please try again.'
    }
  }

  private async load() {
    if (!this.detail) return
    const generation = ++this.generation
    this.request = new AbortController()
    try {
      const state = await this.requestState(
        this.detail.stateUrl,
        { signal: this.request.signal },
        'Could not load your collection. Close and try again.'
      )
      if (generation === this.generation) this.receiveState(state)
    } catch (error) {
      this.showError(error, generation)
    }
  }

  private get recordedFormats() {
    return this.state?.formats.filter((format) => format.count > 0) || []
  }

  private get missingCount() {
    return this.state && this.episodeScope === 'all'
      ? this.state.total - this.state.owned
      : 0
  }

  private receiveState(state: CollectionState) {
    this.state = state
    this.clearDrafts()
    this.recordTitleTarget.textContent = state.title
    this.ownershipTarget.textContent = state.container
      ? `${state.owned} of ${state.total} released episodes owned`
      : state.owned
        ? 'In your collection'
        : 'Not in your collection'
    for (const [target, status] of Object.entries(state.affected_items)) {
      this.dispatch('status-update', {
        target: window,
        detail: { target, status }
      })
    }
    const formats = this.recordedFormats.map((format) =>
      this.createNode(
        'li',
        'bg-background-darker rounded py-1 px-2 text-sm break-words max-w-full',
        this.formatLabel(format)
      )
    )
    this.summaryTarget.replaceChildren(
      ...(formats.length
        ? formats
        : [this.createNode('li', '', 'No formats specified')])
    )
    this.addActionTarget.textContent = state.container
      ? 'Add episodes or formats…'
      : 'Add formats…'
    if (state.owned) this.showScreen('overview')
    else this.showAdd()
  }

  showAdd() {
    if (!this.state) return
    this.clearDrafts()
    this.episodeScope =
      this.state.container && this.state.owned > 0 ? 'owned' : 'all'
    this.scopeChoicesTarget.classList.toggle(
      'hidden',
      !this.state.container || !this.state.owned
    )
    this.ownedScopeLabelTarget.textContent = `Owned episodes only (${this.state.owned})`
    this.allScopeLabelTarget.textContent = `All released episodes (${this.state.total})`
    this.scopeChoicesTarget
      .querySelectorAll<HTMLInputElement>('input')
      .forEach((input) => {
        input.checked = input.value === this.episodeScope
      })
    this.addHeadingTarget.textContent = !this.state.owned
      ? 'Add to collection'
      : this.state.container
        ? 'Add episodes or formats'
        : 'Add formats'
    this.renderChoices(this.addFormatsTarget, this.state.formats)
    this.showScreen('add')
  }

  showRemove() {
    if (!this.state) return
    this.clearDrafts()
    this.renderChoices(this.removeFormatsTarget, this.recordedFormats)
    this.showScreen('remove')
  }

  showConfirmation() {
    if (!this.state) return
    this.removalSummaryTarget.textContent = this.state.container
      ? `${this.state.owned} owned ${this.state.owned === 1 ? 'episode will' : 'episodes will'} be removed.${this.state.excludes_specials ? ' Specials will stay in your collection.' : ''}`
      : ''
    this.showScreen('confirm')
  }

  changeScope(event: Event) {
    this.episodeScope = (event.target as HTMLInputElement).value as
      | 'owned'
      | 'all'
    this.updateAction()
  }

  addCustom(event: Event) {
    event.preventDefault()
    if (!this.state || this.busy) return
    const name = this.customNameTarget.value.trim()
    if (!name) {
      this.customNameTarget.focus()
      return
    }
    const match = [...this.state.formats, ...this.drafts].find(
      (format) => format.name.toLowerCase() === name.toLowerCase()
    )
    const format = match || { name, count: 0 }
    if (!match) this.drafts.push(format)
    this.selected.add(this.key(format))
    this.customNameTarget.value = ''
    this.renderChoices(this.addFormatsTarget, [
      ...this.state.formats,
      ...this.drafts
    ])
    this.updateAction()
    this.customNameTarget.focus()
  }

  back() {
    if (this.busy) return
    if (
      !this.state ||
      this.screen === 'overview' ||
      (this.screen === 'add' && !this.state.owned)
    )
      this.close()
    else {
      this.clearDrafts()
      this.showScreen('overview')
    }
  }

  private showScreen(screen: Screen) {
    this.screen = screen
    this.errorTarget.textContent = ''
    this.screenTargets.forEach((section) =>
      section.classList.toggle('hidden', section.dataset.screen !== screen)
    )
    this.contentTarget.scrollTop = 0
    this.updateAction()
    const generation = this.generation
    requestAnimationFrame(() => {
      if (this.dialog.open && generation === this.generation) {
        this.screenTargets
          .find((section) => section.dataset.screen === this.screen)
          ?.querySelector<HTMLElement>('h3')
          ?.focus()
      }
    })
  }

  private key(format: Format) {
    return format.id ? `id:${format.id}` : `custom:${format.name.toLowerCase()}`
  }

  private formatLabel(format: Format) {
    return this.state?.container
      ? `${format.name} · ${format.count} episodes`
      : format.name
  }

  private choiceLabel(format: Format, removing: boolean) {
    if (removing) return this.formatLabel(format)
    if (!format.count) return format.name
    return (
      format.name +
      (this.state?.container
        ? ` (already on ${format.count} episodes)`
        : ' (already recorded)')
    )
  }

  private createNode<K extends keyof HTMLElementTagNameMap>(
    tag: K,
    className = '',
    text = ''
  ) {
    const node = document.createElement(tag)
    node.className = className
    node.textContent = text
    return node
  }

  private choiceIcon(removing: boolean) {
    const icon = this.createNode('span', 'inline-grid text-xs shrink-0')
    icon.setAttribute('aria-hidden', 'true')
    icon.append(
      this.createNode(
        'i',
        `fa-solid ${removing ? 'fa-minus' : 'fa-plus'} col-start-1 row-start-1 group-data-[selected=true]/format:opacity-0`
      ),
      this.createNode(
        'i',
        'fa-solid fa-check col-start-1 row-start-1 opacity-0 group-data-[selected=true]/format:opacity-100'
      )
    )
    return icon
  }

  private formatChoice(format: Format, removing: boolean) {
    const key = this.key(format)
    const label = this.createNode(
      'label',
      'group/format relative cursor-pointer max-w-full'
    )
    const input = this.createNode('input', 'peer sr-only')
    input.type = 'checkbox'
    input.checked = this.selected.has(key)
    label.dataset.selected = String(input.checked)
    input.addEventListener('change', () => {
      if (input.checked) this.selected.add(key)
      else this.selected.delete(key)
      label.dataset.selected = String(input.checked)
      this.updateAction()
    })
    const pill = this.createNode(
      'span',
      'flex items-center gap-2 text-sm bg-background-darker border border-transparent rounded py-1 px-2 transition duration-300 ease-in-out peer-checked:border-watch peer-checked:bg-watch/15 peer-focus-visible:outline peer-focus-visible:outline-2 peer-focus-visible:outline-watch peer-focus-visible:outline-offset-2 peer-disabled:opacity-50'
    )
    pill.append(
      this.choiceIcon(removing),
      this.createNode(
        'span',
        'break-words min-w-0',
        this.choiceLabel(format, removing)
      )
    )
    label.append(input, pill)
    return label
  }

  private renderChoices(container: HTMLElement, formats: Format[]) {
    container.replaceChildren(
      ...formats.map((format) =>
        this.formatChoice(format, container === this.removeFormatsTarget)
      )
    )
  }

  private submitAction() {
    switch (this.screen) {
      case 'add':
        return {
          label: this.missingCount ? 'Add to collection' : 'Add formats',
          url: this.detail?.addUrl,
          method: 'POST',
          disabled:
            !this.state?.can_add || (!this.missingCount && !this.selected.size)
        }
      case 'remove':
        return {
          label: 'Remove formats',
          url: this.detail?.removeFormatsUrl,
          method: 'DELETE',
          disabled: !this.selected.size
        }
      case 'confirm':
        return {
          label: 'Remove from collection',
          url: this.detail?.removeUrl,
          method: 'DELETE',
          disabled: !this.state?.owned
        }
      default:
        return undefined
    }
  }

  private additionPreview() {
    if (!this.state) return ''
    if (!this.state.can_add)
      return 'Only released titles and episodes can be added to your collection.'
    let text: string
    if (!this.state.container) {
      text = this.state.owned
        ? 'Add selected formats. Existing formats will stay.'
        : 'Add this movie or episode to your collection. Formats are optional.'
    } else if (this.missingCount) {
      text = `Add ${this.missingCount} missing ${this.missingCount === 1 ? 'episode' : 'episodes'} to your collection${this.selected.size ? ` and apply selected formats to all ${this.state.total} released episodes` : ''}.`
    } else {
      text = `Apply selected formats to ${this.state.owned} owned ${this.state.owned === 1 ? 'episode' : 'episodes'}. No episodes will be added.`
    }
    return (
      text + (this.state.excludes_specials ? ' Specials are excluded.' : '')
    )
  }

  private updateAction() {
    const action = this.submitAction()
    this.backButtonTarget.textContent =
      this.screen === 'overview'
        ? 'Done'
        : !this.state?.owned
          ? 'Cancel'
          : 'Back'
    this.backButtonTarget.disabled = this.busy
    this.submitButtonTarget.classList.toggle('hidden', !action)
    this.submitButtonTarget.classList.toggle(
      'bg-red-500',
      this.screen === 'confirm'
    )
    this.submitButtonTarget.classList.toggle(
      'bg-watch',
      this.screen !== 'confirm'
    )
    this.submitButtonTarget.textContent = action?.label || 'Add to collection'
    this.submitButtonTarget.disabled = this.busy || !action || action.disabled
    this.addActionTarget.disabled = this.busy || !this.state?.can_add
    this.removeActionTarget.classList.toggle(
      'hidden',
      !this.recordedFormats.length
    )
    this.removeActionTarget.disabled = this.busy || !this.recordedFormats.length
    this.removeCollectionActionTarget.classList.toggle(
      'hidden',
      !this.state?.owned
    )
    this.removeCollectionActionTarget.disabled =
      this.busy || !this.state?.owned || this.screen === 'confirm'
    if (this.screen === 'add')
      this.previewTarget.textContent = this.additionPreview()
  }

  private setBusy(busy: boolean) {
    this.busy = busy
    this.contentTarget.setAttribute('aria-busy', String(busy))
    this.element
      .querySelectorAll<HTMLInputElement | HTMLButtonElement>('input, button')
      .forEach((input) => {
        input.disabled = busy
      })
    this.updateAction()
  }

  private submissionBody() {
    const body = new FormData()
    for (const format of [...(this.state?.formats || []), ...this.drafts]) {
      if (!this.selected.has(this.key(format))) continue
      if (format.id) body.append('format_ids[]', String(format.id))
      else body.append('custom_formats[]', format.name)
    }
    body.append('scope', this.episodeScope)
    return body
  }

  async submit(event: Event) {
    event.preventDefault()
    const action = this.submitAction()
    if (!action?.url || !this.state || this.busy || action.disabled) return
    const generation = this.generation
    this.errorTarget.textContent = ''
    this.setBusy(true)
    try {
      const state = await this.requestState(
        action.url,
        { method: action.method, body: this.submissionBody() },
        'Could not update collection. Please try again.'
      )
      if (generation !== this.generation) return
      this.receiveState(state)
      this.close()
    } catch (error) {
      this.showError(error, generation)
    } finally {
      if (generation === this.generation) this.setBusy(false)
    }
  }
}
