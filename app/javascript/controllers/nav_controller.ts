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
    const widgets = widgetsForNavLiveSearch(this.element)
    const additionalSearchParameters = {
      per_page: 3
    }
    const collectionSpecificSearchParameters = {
      Movie: { query_by: 'translated_title,original_title,alternative_names' },
      Show: { query_by: 'translated_title,original_title,alternative_names' }
    }
    setupLiveSearch({
      widgets,
      union: true,
      indexName: 'Show',
      additionalSearchParameters,
      collectionSpecificSearchParameters
    })
    const searchInput = this.element.querySelector<HTMLInputElement>('.nav-search')
    const hits = this.element.querySelector<HTMLInputElement>('.hits')
    if (!searchInput || !hits) return

    this.searchWrapperTarget.addEventListener('click', () => {
      searchInput.focus()
    })

    searchInput.addEventListener('focusin', () => {
      this.buttonTargets.forEach((btn) => {
        btn.classList.add('hidden!')
      })
      hits.style.width = (this.searchWrapperTarget.getBoundingClientRect().width + 3) + 'px'
    })

    searchInput.addEventListener('focusout', () => {
      this.buttonTargets.forEach((btn) => {
        btn.classList.remove('hidden!')
      })
      hits.style.width = (this.searchWrapperTarget.getBoundingClientRect().width + 3) + 'px'
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
