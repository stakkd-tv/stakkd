import { CellComponent, EmptyCallback, ValueBooleanCallback, ValueVoidCallback } from 'tabulator-tables'
import { DropdownEditor, EditorParams } from '../dropdown_editor'

export function listEditor (cell: CellComponent, onRendered: EmptyCallback, success: ValueBooleanCallback, _cancel: ValueVoidCallback, editorParams: EditorParams): HTMLElement {
  const dropdown = new DropdownEditor(cell, editorParams, success, this.element, onRendered)
  return dropdown.getDisplayElement()
}
