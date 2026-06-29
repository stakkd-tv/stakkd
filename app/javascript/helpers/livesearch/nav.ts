import { searchBox, hits, index } from 'instantsearch.js/es/widgets/index.js'

export function widgetsForNavLiveSearch (navbar: Element) {
  const env = document.querySelector<HTMLElement>('#rails-env')?.textContent || 'development'
  const searchContainer = navbar.querySelector<HTMLElement>('.search-box')
  const hitsContainer = navbar.querySelector<HTMLElement>('.hits')
  if (!searchContainer || !hitsContainer) return []

  return [
    searchBox({
      container: searchContainer,
      placeholder: 'Start typing to begin your exploration...',
      showSubmit: false,
      showReset: false,
      cssClasses: {
        root: 'w-full',
        form: 'w-full',
        input: 'nav-search peer w-full h-full text-white font-bold focus:outline-none placeholder:font-normal placeholder:text-white placeholder:opacity-75'
      }
    }),
    hits({
      container: hitsContainer,
      transformItems (items, { results }) {
        if (results && results.query === '*') { return [] }
        return items.map(item => ({ ...item, type: item.collection.includes('Show') ? 'show' : 'movie' }))
      },
      templates: {
        item: `
          <a href="/{{type}}s/{{id}}">
            <div class="flex items-center p-4 hover:bg-pop/75 cursor-pointer">
              <img src="/{{type}}s/{{id}}/poster" align="left" alt="" loading="lazy" class="aspect-2/3 w-8 mr-4" />
              <div class="hit-name">
                {{translated_title}}
              </div>
            </div>
          </a>
        `,
        empty (state) {
          if (!state.query || state.query === '*') {
            return ''
          }
          return '<div class="border-l-3 border-r-3 border-b-3 border-pop p-4 cursor-default">No results</div>'
        }
      },
      cssClasses: {
        root: 'bg-background/75 border-l-3 border-r-3 border-b-1 border-pop flex flex-col gap-4',
        emptyRoot: 'border-none',
        list: 'flex flex-col gap-2'
      }
    }),
    index({
      indexName: `Movie_${env}`
    })
  ]
}
