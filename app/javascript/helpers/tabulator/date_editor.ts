import flatpickr from 'flatpickr'
import { CellComponent, EmptyCallback, ValueBooleanCallback } from 'tabulator-tables'

export function dateEditor (cell: CellComponent, onRendered: EmptyCallback, success: ValueBooleanCallback): HTMLElement {
  const editor = document.createElement('input')
  editor.classList.add(
    'py-[15px]',
    'px-[10px]'
  )
  editor.value = cell.getValue()

  flatpickr(editor, {
    enableTime: false,
    dateFormat: 'd-m-Y',
    disableMobile: true,
    onClose: (selectedDates, dateStr, instance) => {
      success(dateStr)
      instance.destroy()
    },
    onChange: (selectedDates, dateStr, instance) => {
      success(dateStr)
      instance.destroy()
    }
  })

  onRendered(() => {
    editor.focus()
  })

  return editor
}
