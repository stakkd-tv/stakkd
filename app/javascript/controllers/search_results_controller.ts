import { Controller } from '@hotwired/stimulus'

type Result = {
  poster_path: string,
  title: string,
  slug: string,
  aspect: string | null
}

// Connects to data-controller="search-results"
export default class extends Controller {
  static targets = ['tab', 'resultsContainer']

  declare readonly tabTargets: HTMLElement[]
  declare readonly resultsContainerTarget: HTMLElement

  declare currentTab: HTMLElement

  connect () {
    this.setCurrentTab(this.tabTargets[0])
  }

  updateTab (event: Event) {
    const newTab = event.currentTarget as HTMLElement
    this.setCurrentTab(newTab)
  }

  setCurrentTab (newTab: HTMLElement) {
    const previousTab = this.currentTab
    if (previousTab) {
      previousTab.setAttribute('data-sidetab-active', 'false')
    }
    this.currentTab = newTab
    this.currentTab.setAttribute('data-sidetab-active', 'true')
    this.updateResults()
  }

  updateResults () {
    this.resultsContainerTarget.innerHTML = ''
    const rawResults = this.currentTab.getAttribute('data-initial-results')
    if (!rawResults) return

    const tab = this.currentTab.getAttribute('data-tab')
    const results: Result[] = JSON.parse(rawResults)
    results.forEach(result => {
      const fallback = this.currentTab.getAttribute('data-fallback-src')
      const html = `
        <a href="/${tab}/${result.slug}" class="h-fit border border-pop rounded-lg overflow-hidden relative" data-turbo="false">
          <img src="${result.poster_path ?? fallback}" class="w-full ${result.aspect ?? 'aspect-2/3'} object-cover">
          <div class="absolute w-full p-2 sm:p-4 bottom-0 left-0 bg-background/75 border-t border-pop">
            <div class="flex flex-col gap-2">
              <h3 class="text-sm sm:text-lg font-bold">${result.title}</h3>
            </div>
          </div>
        </a>
      `
      this.resultsContainerTarget.innerHTML += html
    })
  }
}
