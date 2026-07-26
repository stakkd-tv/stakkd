import { BaseHit, RendererOptions } from 'instantsearch.js'
import connectInfiniteHits, { InfiniteHitsRenderState } from 'instantsearch.js/es/connectors/infinite-hits/connectInfiniteHits'

export interface InfiniteHitsWidgetParams<THit extends BaseHit = BaseHit> {
  container: HTMLElement
  getItemText: (item: THit) => string
  onItemClick: (item: THit) => void
}

let lastRenderArgs: InfiniteHitsRenderState<BaseHit> & RendererOptions<InfiniteHitsWidgetParams>
export const infiniteHits = connectInfiniteHits<BaseHit>(
  (renderArgs, isFirstRender) => {
    const { items, showMore, widgetParams } = renderArgs
    const container = widgetParams.container as HTMLElement

    lastRenderArgs = renderArgs as InfiniteHitsRenderState<BaseHit> & RendererOptions<InfiniteHitsWidgetParams>

    if (isFirstRender) {
      const sentinel = document.createElement('div')
      sentinel.classList.add('sentinel')
      const ul = document.createElement('ul')
      ul.classList.add('rounded-lg', 'bg-background-darker', 'border', 'border-pop', 'absolute', 'w-full', 'mt-2', 'max-h-96', 'overflow-y-auto', 'z-1')
      container.appendChild(ul)
      ul.appendChild(sentinel)

      const observer = new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting && !lastRenderArgs.isLastPage) {
            showMore()
          }
        })
      })
      observer.observe(sentinel)

      return
    }

    const ul = container.querySelector('ul') as HTMLUListElement
    const sentinel = ul.querySelector('div.sentinel') as HTMLDivElement
    const existingResults = ul.querySelectorAll('li.result')
    existingResults.forEach((result) => {
      ul.removeChild(result)
    })

    if (items.length > 0) {
      ul.classList.remove('hidden')
      items.forEach((item) => {
        const element = document.createElement('li')
        element.classList.add('result', 'p-2', 'flex', 'items-center', 'cursor-pointer', 'hover:bg-pop/75', 'focus:bg-pop/75', 'focus:outline-none')
        element.innerText = widgetParams.getItemText(item)
        element.addEventListener('click', () => {
          widgetParams.onItemClick(item)
        })
        ul.insertBefore(element, sentinel)
      })
    } else {
      ul.classList.add('hidden')
    }
  }
)
