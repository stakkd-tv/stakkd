import { Controller } from '@hotwired/stimulus'
import EasyMDE from 'easymde'
import { MARKED_CONFIG } from '../helpers/marked'
import { sanitize } from '../helpers/sanitize_html'
import {
  spoilerToolbarButton,
  trackSpoilerToolbarState
} from '../helpers/spoiler_toolbar'

// Connects to data-controller="markdown-editor" on a textarea.
export default class extends Controller<HTMLTextAreaElement> {
  private editor?: EasyMDE

  connect() {
    this.editor = new EasyMDE({
      element: this.element,
      toolbar: [
        'bold',
        'italic',
        spoilerToolbarButton,
        'heading',
        '|',
        'quote',
        'unordered-list',
        'ordered-list',
        'check-list',
        '|',
        'link',
        'image',
        '|',
        'preview',
        '|',
        'guide'
      ],
      spellChecker: false,
      previewClass: 'rendered-markdown',
      renderingConfig: {
        sanitizerFunction: sanitize,
        markedOptions: MARKED_CONFIG
      }
    })

    trackSpoilerToolbarState(this.editor)
  }

  disconnect() {
    this.editor?.toTextArea()
    this.editor = undefined
  }
}
