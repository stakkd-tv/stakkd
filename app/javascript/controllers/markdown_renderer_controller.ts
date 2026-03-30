import { Controller } from '@hotwired/stimulus'
import { marked } from 'marked'
import { sanitize } from '../helpers/sanitize_html'

// Connects to data-controller="markdown-renderer"
export default class extends Controller {
  static values = { markdown: String }

  declare markdownValue: string

  connect () {
    const html = marked.parse(this.markdownValue, { gfm: true, breaks: false }) as string
    this.element.innerHTML = sanitize(html)
  }
}
