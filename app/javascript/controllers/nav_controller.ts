import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="nav"
export default class extends Controller {
  static targets = ['search', 'searchWrapper', 'button', 'user']

  declare readonly searchTarget: HTMLElement
  declare readonly searchWrapperTarget: HTMLElement
  declare readonly userTarget: HTMLElement
  declare readonly buttonTargets: HTMLElement[]
  declare readonly hasUserTarget: boolean

  connect () {
    this.searchWrapperTarget.addEventListener('click', () => {
      this.searchTarget.focus()
    })

    this.searchTarget.addEventListener('focusin', () => {
      this.buttonTargets.forEach((btn) => {
        btn.classList.add('!hidden')
      })
    })

    this.searchTarget.addEventListener('focusout', () => {
      this.buttonTargets.forEach((btn) => {
        btn.classList.remove('!hidden')
      })
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
