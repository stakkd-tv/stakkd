import { Controller } from '@hotwired/stimulus'
import { searchBox } from 'instantsearch.js/es/widgets'
import { setupLiveSearch } from '../helpers/livesearch'
import { getRailsEnv } from '../helpers/rails'
import { infiniteHits } from '../helpers/livesearch/infinite_hits'

// Connects to data-controller="livesearch"
export default class extends Controller {
  static values = {
    queryBy: String,
    collectionName: String,
    displayAttributes: Array,
    inputClasses: String,
    placeholder: String
  }

  declare queryByValue: string
  declare collectionNameValue: string
  declare displayAttributesValue: string[]
  declare inputClassesValue: string
  declare hasInputClassesValue: boolean
  declare placeholderValue: string
  declare hasPlaceholderValue: boolean

  declare searchInput: HTMLInputElement | null | undefined
  declare searchResults: HTMLElement

  connect () {
    this.element.classList.add('hidden')

    const searchInputWrapper = this.element.parentElement?.querySelector('.search-input') as HTMLElement
    const searchResultsWrapper = this.element.parentElement?.querySelector('.search-results') as HTMLElement

    let inputCssClasses = 'livesearch-input'
    if (this.hasInputClassesValue) {
      inputCssClasses += ` ${this.inputClassesValue}`
    }
    const env = getRailsEnv()
    const widgets = [
      searchBox({
        container: searchInputWrapper,
        placeholder: this.hasPlaceholderValue ? this.placeholderValue : '',
        showSubmit: false,
        showReset: false,
        cssClasses: {
          input: inputCssClasses
        }
      }),
      infiniteHits({
        container: searchResultsWrapper,
        transformItems (items, { results }) {
          if (results && results.query === '*') { return [] }
          return items
        },
        getItemText: this.getItemText.bind(this),
        onItemClick: this.onItemClick.bind(this)
      })
    ]
    const additionalSearchParameters = {
      per_page: 50,
      query_by: this.queryByValue
    }
    setupLiveSearch({
      widgets,
      union: false,
      indexName: `${this.collectionNameValue}_${env}`,
      additionalSearchParameters
    })

    this.searchInput = this.element.parentElement?.querySelector<HTMLInputElement>('input.livesearch-input')
    this.searchResults = searchResultsWrapper

    const name = this.element.getAttribute('name')?.split('[')
    if (name) {
      this.searchInput?.setAttribute('name', name[name.length - 1].replace(']', '').replace('_id', ''))
    }
    this.searchInput?.addEventListener('focusin', () => this.searchResults.classList.remove('hidden'))
  }

  getItemText (item: Record<string, string>): string {
    return this.displayAttributesValue.map(attr => {
      return item[attr]
    }).join(' - ')
  }

  onItemClick (item: Record<string, string>) {
    this.element.setAttribute('value', item.id)
    this.searchResults.classList.add('hidden')
    if (this.searchInput) {
      this.searchInput.value = this.getItemText(item)
    }
  }
}
