import { Controller } from '@hotwired/stimulus'
import { setupLiveSearch } from '../helpers/livesearch'
import { buildSearchUrl, NAV_SEARCH_PLACEHOLDER, NAV_SEARCHING_PLACEHOLDER, widgetsForNavLiveSearch } from '../helpers/livesearch/nav'
import { getRailsEnv } from '../helpers/rails'

// Connects to data-controller="nav"
export default class extends Controller {
  static targets = ['searchWrapper', 'button', 'user']

  declare readonly searchWrapperTarget: HTMLElement
  declare readonly userTarget: HTMLElement
  declare readonly buttonTargets: HTMLElement[]
  declare readonly hasUserTarget: boolean

  connect () {
    const env = getRailsEnv()
    const widgets = widgetsForNavLiveSearch(this.element)
    const additionalSearchParameters = {
      per_page: 3,
      query_by: 'translated_title,original_title,alternative_names'
    }
    setupLiveSearch({
      widgets,
      union: true,
      indexName: `Show_${env}`,
      additionalSearchParameters
    })
    const searchInput = this.element.querySelector<HTMLInputElement>('.nav-search')
    const hits = this.element.querySelector<HTMLInputElement>('.hits')
    if (!searchInput || !hits) return

    hits.classList.add('hidden')

    this.searchWrapperTarget.addEventListener('click', () => {
      searchInput.focus()
    })

    const hideHits = () => {
      this.buttonTargets.forEach((btn) => {
        btn.classList.remove('hidden!')
      })
      hits.style.width = (this.searchWrapperTarget.getBoundingClientRect().width + 3) + 'px'
      hits.classList.add('hidden')
    }

    const isFocusInsideSearch = (target: EventTarget | null) => {
      if (!target) return false
      return target === searchInput || hits.contains(target as Node)
    }

    searchInput.addEventListener('focusin', () => {
      searchInput.placeholder = NAV_SEARCHING_PLACEHOLDER
      this.buttonTargets.forEach((btn) => {
        btn.classList.add('hidden!')
      })
      hits.style.width = (this.searchWrapperTarget.getBoundingClientRect().width + 3) + 'px'
      hits.classList.remove('hidden')
    })

    searchInput.addEventListener('focusout', (event: FocusEvent) => {
      searchInput.placeholder = NAV_SEARCH_PLACEHOLDER
      if (isFocusInsideSearch(event.relatedTarget)) return
      hideHits()
    })

    hits.addEventListener('focusout', (event: FocusEvent) => {
      if (isFocusInsideSearch(event.relatedTarget)) return
      hideHits()
    })

    hits.addEventListener('mousedown', (event: MouseEvent) => {
      if (event.button === 0) {
        event.preventDefault()
      }
    })

    hits.addEventListener('click', () => {
      if (document.activeElement instanceof HTMLElement) {
        document.activeElement.blur()
      }
      hideHits()
    })

    const el = this.element as HTMLElement
    el.addEventListener('keydown', (event: KeyboardEvent) => {
      this.handleKeydown(event, hits, searchInput)
    })

    document.addEventListener('keydown', (event: KeyboardEvent) => {
      const active = document.activeElement as HTMLElement | null
      const isEditable =
        active instanceof HTMLInputElement ||
        active instanceof HTMLTextAreaElement ||
        active instanceof HTMLSelectElement ||
        active?.isContentEditable

      if (event.key === '/' && active !== searchInput && !isEditable) {
        event.preventDefault()
        searchInput.focus()
      }
    })

    const sidebar = document.getElementById('sidebar')
    if (this.hasUserTarget && sidebar) {
      const closeSidebar = document.getElementById('close-sidebar') as HTMLElement

      closeSidebar.addEventListener('click', () => {
        sidebar.classList.add('hidden')
        sidebar.classList.remove('flex')
      })

      this.userTarget.addEventListener('click', () => {
        sidebar.classList.add('flex')
        sidebar.classList.remove('hidden')
      })
    }
  }

  handleKeydown (event: KeyboardEvent, hits: HTMLElement, searchInput: HTMLInputElement) {
    if (event.key !== 'ArrowDown' && event.key !== 'ArrowUp' && event.key !== 'Enter') return

    const links = Array.from(hits.querySelectorAll<HTMLAnchorElement>('a'))
    if (links.length === 0) return

    const activeElement = document.activeElement

    if (activeElement === searchInput) {
      if (event.key === 'ArrowDown') {
        event.preventDefault()
        links[0].focus()
      } else if (event.key === 'Enter') {
        event.preventDefault()
        const query = searchInput.value.trim()
        if (query && query !== '*') {
          window.location.href = buildSearchUrl(query)
        }
      }
    } else if (activeElement instanceof HTMLAnchorElement && links.includes(activeElement)) {
      if (event.key === 'ArrowDown') {
        event.preventDefault()
        const currentIndex = links.indexOf(activeElement)
        if (currentIndex < links.length - 1) {
          links[currentIndex + 1].focus()
        } else {
          searchInput.focus()
        }
      } else if (event.key === 'ArrowUp') {
        event.preventDefault()
        const currentIndex = links.indexOf(activeElement)
        if (currentIndex > 0) {
          links[currentIndex - 1].focus()
        } else {
          searchInput.focus()
        }
      }
    }
  }
}
