import { IndexWidget, Widget } from 'instantsearch.js'
import { hits, index, searchBox } from 'instantsearch.js/es/widgets/index.js'
import { getRailsEnv } from '../rails'

export const NAV_SEARCH_PLACEHOLDER = 'Type / to begin your exploration...'
export const NAV_SEARCHING_PLACEHOLDER = 'What are you looking for today?'

export function buildSearchUrl(query: string): string {
  return `/search?q=${encodeURIComponent(query)}`
}

export function widgetsForNavLiveSearch(
  navbar: Element
): (Widget | IndexWidget)[] {
  const env = getRailsEnv()
  const searchContainer = navbar.querySelector<HTMLElement>('.search-box')
  const hitsContainer = navbar.querySelector<HTMLElement>('.hits-results')
  if (!searchContainer || !hitsContainer) return []

  const seeAllWidget: Widget = {
    $$type: 'custom.seeAll',
    render(options) {
      const seeAllBtn = navbar.querySelector<HTMLAnchorElement>('.see-all-btn')
      if (seeAllBtn) {
        // biome-ignore lint: any is allowed
        const results = options.results as any
        const query = results?.query?.trim() || ''
        if (query && query !== '*') {
          seeAllBtn.href = buildSearchUrl(query)
          seeAllBtn.classList.remove('hidden')
          seeAllBtn.classList.add('block')
        } else {
          seeAllBtn.classList.add('hidden')
          seeAllBtn.classList.remove('block')
        }
      }
    }
  }

  return [
    searchBox({
      container: searchContainer,
      placeholder: NAV_SEARCH_PLACEHOLDER,
      showSubmit: false,
      showReset: false,
      cssClasses: {
        root: 'w-full',
        form: 'w-full',
        input:
          'nav-search peer w-full h-full text-white font-bold focus:outline-none placeholder:font-normal placeholder:text-white placeholder:opacity-75'
      }
    }),
    hits({
      container: hitsContainer,
      transformItems(items, { results }) {
        if (results && results.query === '*') return []
        return items.map((item) => ({
          ...item,
          type: item.collection.includes('Show') ? 'show' : 'movie'
        }))
      },
      templates: {
        item: `
          <a href="/{{type}}s/{{slug}}" class="group outline-none block">
            <div class="flex items-center p-4 hover:bg-pop/75 group-focus:bg-pop/75 cursor-pointer">
              <img src="/{{type}}s/{{id}}/poster" align="left" alt="" loading="lazy" class="aspect-2/3 w-8 mr-4" />
              <div class="hit-name">
                {{translated_title}}
              </div>
            </div>
          </a>
        `,
        empty(state) {
          if (!state.query || state.query === '*') {
            return ''
          }
          return '<div class="border-l-3 border-r-3 border-b border-pop p-4 cursor-default">No movies or shows found. Press enter to search across all records.</div>'
        }
      },
      cssClasses: {
        root: 'border-l-3 border-r-3 border-b border-pop flex flex-col',
        emptyRoot: 'border-none',
        list: 'flex flex-col'
      }
    }),
    index({
      indexName: `Movie_${env}`
    }),
    seeAllWidget
  ]
}
