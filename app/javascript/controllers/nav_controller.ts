import { Controller } from '@hotwired/stimulus'
import { setupLiveSearch } from '../helpers/livesearch'
import { widgetsForNavLiveSearch } from '../helpers/livesearch/nav'

// Connects to data-controller="nav"
export default class extends Controller {
  static targets = ['searchWrapper', 'button', 'user']

  declare readonly searchWrapperTarget: HTMLElement
  declare readonly userTarget: HTMLElement
  declare readonly buttonTargets: HTMLElement[]
  declare readonly hasUserTarget: boolean

  connect () {
    const env = document.querySelector<HTMLElement>('#rails-env')?.textContent || 'development'
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
      this.buttonTargets.forEach((btn) => {
        btn.classList.add('hidden!')
      })
      hits.style.width = (this.searchWrapperTarget.getBoundingClientRect().width + 3) + 'px'
      hits.classList.remove('hidden')
    })

    searchInput.addEventListener('focusout', (event: FocusEvent) => {
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
      searchInput.blur()
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
}
