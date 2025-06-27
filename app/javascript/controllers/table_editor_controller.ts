import { Controller } from '@hotwired/stimulus'
import { CellComponent, ColumnDefinition, EmptyCallback, Options, RowComponent, TabulatorFull as Tabulator, ValueBooleanCallback } from 'tabulator-tables'
import flatpickr from 'flatpickr'
import { listEditor } from '../helpers/tabulator/list_editor';
import { dateEditor } from '../helpers/tabulator/date_editor';

interface RowData {
  [key: string]: object;
}

interface Response {
  success: boolean
  errors: object[] | null
}

// Connects to data-controller="table-editor"
export default class extends Controller {
  static targets = ['tableContainer']
  static values = { tableData: Array, tableColumns: Array, pathPrefix: String, modelName: String, movable: Boolean, groupBy: String }

  declare readonly tableContainerTarget: HTMLElement

  declare tableDataValue: object[]
  declare tableColumnsValue: ColumnDefinition[]
  declare pathPrefixValue: string
  declare modelNameValue: string
  declare movableValue: boolean
  declare groupByValue: string

  declare hasGroupByValue: boolean

  async saveRecord (rowData: RowData): Promise<Response> {
    const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') ?? ''
    const { id, ...data } = rowData
    const url = `${this.pathPrefixValue}/${id}`
    const body = Object.entries(data).reduce((acc, [key, value]) => {
      let newVal: unknown = value

      if (typeof value === 'object' && value !== null && 'value' in value) {
        newVal = value.value
      }

      acc[key] = newVal
      return acc
    }, {})

    const response = await fetch(url, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': token },
      body: JSON.stringify({ [this.modelNameValue]: body })
    })

    const json = await response.json()

    if (!response.ok) {
      return Promise.reject(json)
    }
    return json
  }

  async removeRow (_event: UIEvent, cell: CellComponent): Promise<void> {
    const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') ?? ''
    const { id } = cell.getRow().getData()
    const url = `${this.pathPrefixValue}/${id}`
    const response = await fetch(url, {
      method: 'DELETE',
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': token }
    })
    if (response.ok) {
      const row = cell.getRow()
      row.delete()
    }
  }

  async moveRow (row: RowComponent) {
    const newPosition = row.getPosition()
    const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') ?? ''
    const { id } = row.getData()
    const url = `${this.pathPrefixValue}/${id}/move`
    await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': token },
      body: JSON.stringify({ position: newPosition })
    })
  }

  translateColumnsValue (): ColumnDefinition[] {
    return this.tableColumnsValue.map((columnData) => {
      if (columnData.editor === 'list') {
        columnData.editor = listEditor.bind(this)
        columnData.formatter = function (cell) {
          const val = cell.getValue()
          return typeof val === 'object' ? val.label : val
        }
      } else if (columnData.editor === 'date') {
        columnData.editor = dateEditor.bind(this)
      } else if (columnData.formatter === 'buttonCross') {
        columnData.cellClick = this.removeRow.bind(this)
      }

      return columnData
    })
  }

  handleError (data: Response, cell: CellComponent) {
    const cells = cell.getRow().getCells()
    const errorKeys = data.errors!.map((errorHash) => Object.keys(errorHash)).flat()
    cells.forEach((cell) => {
      const field = cell.getField()
      if (errorKeys.includes(field)) {
        cell.setValue(cell.getInitialValue())
      }
    })
  }

  connect () {
    const table = new Tabulator(this.tableContainerTarget, this.buildOptions())
    table.on('cellEdited', (cell) => {
      const data = cell.getRow().getData()
      this.saveRecord(data)
        .then(data => console.log('Saved:', data))
        .catch((data: Response) => this.handleError(data, cell))
    })
    table.on('rowMoved', (row) => {
      this.moveRow(row)
        .then(() => console.log('Row moved'))
        .catch(() => console.error('Could not move row'))
    })
  }

  buildOptions (): Options {
    const options: Options = {
      data: this.tableDataValue,
      layout: 'fitColumns',
      resizableColumnFit: true,
      columns: this.translateColumnsValue()
    }
    if (this.movableValue) {
      options.movableRows = true
      options.rowHeader = { rowHandle: true, width: 40, minWidth: 40, headerSort: false, resizable: false, formatter: 'handle' }
    }
    if (this.hasGroupByValue) {
      options.groupBy = (data) => {
        const valOrObj = data[this.groupByValue]
        return typeof valOrObj === 'object' ? valOrObj.label : valOrObj
      }
    }
    return options
  }
}
