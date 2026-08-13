import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="search-results"
export default class extends Controller {
  static targets = ['tab', 'resultsGrid']

  declare readonly tabTargets: HTMLElement[]
  declare readonly resultsGridTargets: HTMLElement[]

  declare currentTab: HTMLElement

  connect() {
    this.setCurrentTab(this.tabTargets[0])
  }

  updateTab(event: Event) {
    const newTab = event.currentTarget as HTMLElement
    this.setCurrentTab(newTab)
  }

  setCurrentTab(newTab: HTMLElement) {
    const previousTab = this.currentTab
    if (previousTab) {
      previousTab.setAttribute('data-sidetab-active', 'false')
    }
    this.currentTab = newTab
    this.currentTab.setAttribute('data-sidetab-active', 'true')
    this.toggleGridVisibility()
  }

  toggleGridVisibility() {
    const activeTabName = this.currentTab.getAttribute('data-tab')
    if (!activeTabName) return

    this.resultsGridTargets.forEach((grid) => {
      if (grid.id === `${activeTabName}-results-container`) {
        grid.classList.remove('hidden')
      } else {
        grid.classList.add('hidden')
      }
    })
  }
}
