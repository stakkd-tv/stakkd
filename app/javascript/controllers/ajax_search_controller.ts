import { Controller } from '@hotwired/stimulus'
import { debounce } from '../helpers/debounce'

type SearchResult = {
  value: string
  label: string
  image_url: string | null
}

// Connects to data-controller="ajax-search"
export default class extends Controller {
  static values = { searchUrl: String }

  declare searchUrlValue: string

  declare searchInput: HTMLInputElement
  declare searchResults: HTMLDivElement

  connect () {
    this.element.classList.add('hidden')

    this.searchInput = document.createElement('input')
    const name = this.element.getAttribute('name')?.split('[')
    if (name) {
      this.searchInput.setAttribute('name', name[name.length - 1].replace(']', '').replace('_id', ''))
    }
    this.element.parentElement?.appendChild(this.searchInput)

    this.searchResults = document.createElement('div')
    this.searchResults.classList.add(
      'rounded-lg',
      'bg-background-darker',
      'border',
      'border-pop',
      'absolute',
      'w-full',
      'hidden',
      'mt-2',
      'max-h-96',
      'overflow-y-auto'
    )
    this.element.parentElement?.appendChild(this.searchResults)

    this.searchInput.addEventListener('input', debounce(this.handleInput.bind(this), 300))
    document.addEventListener('click', (event) => {
      if (event.target !== this.searchInput && event.target !== this.searchResults) {
        this.clearSearchResults()
      }
    })
  }

  clearSearchResults () {
    this.searchResults.classList.add('hidden')
    this.searchResults.innerHTML = ''
  }

  handleInput () {
    const query = this.searchInput.value
    const options = {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json'
      }
    }
    fetch(this.searchUrlValue + '?query=' + query, options)
      .then(response => response.json())
      .then((results: SearchResult[]) => {
        (this.element as HTMLInputElement).value = ''
        this.clearSearchResults()
        if (results.length > 0) { this.searchResults.classList.remove('hidden') }
        this.searchResults.style.width = this.element.parentElement?.clientWidth + 'px'
        results.forEach((result, idx) => {
          this.createResult(result, idx)
        })
      })
      .catch(() => {
        console.error(`Could not fetch: ${this.searchUrlValue}?query=${query}`)
        this.clearSearchResults()
      })
  }

  createResult (result: SearchResult, idx: number) {
    const resultElement = document.createElement('div')
    resultElement.classList.add('p-2', 'flex', 'items-center', 'cursor-pointer', 'hover:bg-pop/75', 'focus:bg-pop/75', 'focus:outline-none')
    resultElement.innerText = result.label
    resultElement.tabIndex = idx + 1
    resultElement.addEventListener('click', () => {
      (this.element as HTMLInputElement).value = result.value
      this.searchInput.value = result.label
      this.clearSearchResults()
    })
    this.searchResults.appendChild(resultElement)
  }
}
