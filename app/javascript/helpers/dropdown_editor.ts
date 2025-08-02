import { CellComponent, EmptyCallback, ValueBooleanCallback } from 'tabulator-tables'

export interface EditorParams {
  values: {
    label: string
    value: unknown
    scope: string | undefined
  }[]
  valuesLookupField: string | undefined
}

export class DropdownEditor {
  declare cell: CellComponent
  declare cellElement: HTMLElement
  declare editorParams: EditorParams
  declare success: ValueBooleanCallback
  declare parent: Element
  declare editor: HTMLElement
  declare input: HTMLInputElement
  declare resizeObserver: ResizeObserver
  declare onMouseDown: (this: Document, ev: MouseEvent) => void
  declare selectedOption: HTMLDivElement | null
  declare options: HTMLDivElement[]

  constructor (cell: CellComponent, editorParams: EditorParams, success: ValueBooleanCallback, parent: Element, onRendered: EmptyCallback) {
    this.cell = cell
    this.cellElement = cell.getElement()
    this.editorParams = editorParams
    this.success = success
    this.parent = parent
    this.options = []

    this.editor = document.createElement('div')
    this.editor.classList.add(
      'fixed',
      'sm:absolute',
      'cursor-pointer',
      'h-screen',
      'sm:max-h-96',
      'sm:h-fit',
      'bg-background',
      'overflow-y-scroll',
      'z-50',
      'border',
      'border-pop'
    )

    this.input = document.createElement('input')
    this.input.placeholder = 'Search'
    this.input.classList.add(
      'bg-background-darker',
      'py-[15px]',
      'px-[10px]',
      'w-full',
      'focus:outline-none',
      'border-b',
      'border-pop',
      'sticky',
      'top-0'
    )
    this.input.addEventListener('input', () => {
      this.options.forEach((option) => {
        option.classList.remove('hidden')
      })

      if (this.input.value.trim() === '') { return }

      this.options.forEach((option) => {
        if (!option.innerText.toLowerCase().includes(this.input.value.toLowerCase())) {
          option.classList.add('hidden')
        }
      })
    })
    this.editor.appendChild(this.input)

    this.setupPositioning()
    this.buildOptions()
    this.observeResize()
    this.setupOutsideClickHandler()

    // append to tabulator container
    this.parent.appendChild(this.editor)

    window.addEventListener('resize', () => {
      this.setupPositioning()
    })

    onRendered(() => {
      this.input.focus()
    })
  }

  setupPositioning () {
    const value = getComputedStyle(document.documentElement).getPropertyValue('--breakpoint-sm')
    if (window.innerWidth <= this._convertRemToPixels(value)) {
      this.editor.style.left = '0'
      this.editor.style.top = '0'
      this.editor.style.width = '80vw'
    } else {
      const rect = this.cellElement.getBoundingClientRect()
      this.editor.style.left = `${rect.left}px`
      this.editor.style.top = `${rect.top + this.cellElement.clientHeight + window.scrollY}px`
      this.editor.style.width = this.cellElement.style.width
    }
  }

  observeResize () {
    this.resizeObserver = new ResizeObserver(() => {
      const value = getComputedStyle(document.documentElement).getPropertyValue('--breakpoint-sm')
      if (window.innerWidth <= this._convertRemToPixels(value)) { return }
      const rect = this.cellElement.getBoundingClientRect()
      this.editor.style.left = `${rect.left}px`
      this.editor.style.width = `${rect.width}px`
    })
    this.resizeObserver.observe(this.cellElement)
  }

  buildOptions () {
    const { label: currentLabel, scope: currentScope } = this.cell.getValue()
    Array.from(this.editorParams.values).forEach(data => {
      const { label, value, scope } = data

      if (scope !== currentScope) return

      const elm = document.createElement('div')
      elm.classList.add('px-[10px]', 'py-[15px]', 'hover:bg-background-darker', 'dropdown-option')
      if (label === currentLabel) {
        elm.classList.remove('hover:bg-background-darker')
        elm.classList.add('bg-pop/50')
        this.selectedOption = elm
      }
      elm.innerText = label
      elm.addEventListener('click', () => {
        this.success({ label, value })
        this.destroy()
      })
      this.options.push(elm)
      this.editor.appendChild(elm)
    })
  }

  setupOutsideClickHandler () {
    setTimeout(() => {
      this.onMouseDown = (event) => {
        const target = event.target as HTMLElement
        if (
          !this.editor.contains(target) &&
          !this.cellElement.contains(target)
        ) {
          this.success(this.cell.getValue())
          this.destroy()
        }
      }
      document.addEventListener('mousedown', this.onMouseDown)
    }, 0)
  }

  destroy () {
    this.editor.remove()
    this.resizeObserver.disconnect()
    document.removeEventListener('mousedown', this.onMouseDown)
  }

  getDisplayElement () {
    const newCellElement = document.createElement('div')
    const value = this.cell.getValue()
    newCellElement.innerText = typeof value === 'object' ? value.label : value
    newCellElement.classList.add('h-full', 'flex', 'items-center', 'p-[10px]')
    return newCellElement
  }

  _convertRemToPixels (rem: string) {
    return parseFloat(rem) * parseFloat(getComputedStyle(document.documentElement).fontSize)
  }
}
