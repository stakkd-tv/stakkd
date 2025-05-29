import { Controller } from '@hotwired/stimulus'

// TODO: System specs
// Connects to data-controller="uploads"
export default class extends Controller {
  static targets = ['input', 'statuses', 'template', 'imageTemplate', 'images']

  static values = { recordType: String, recordId: String, type: String }

  declare recordTypeValue: string
  declare recordIdValue: string
  declare typeValue: string

  declare readonly inputTarget: HTMLInputElement
  declare readonly statusesTarget: HTMLDivElement
  declare readonly templateTarget: HTMLDivElement
  declare readonly imageTemplateTarget: HTMLDivElement
  declare readonly imagesTarget: HTMLDivElement

  connect () {
    this.inputTarget.addEventListener('change', async (event) => {
      const rawFiles = (event.target as HTMLInputElement).files ?? []
      const files = Array.from(rawFiles)

      for (const file of files) {
        await this.handleFile(file)
      }
    })
  }

  async handleFile (file: File) {
    const formData = new FormData()
    formData.append('image', file)
    formData.append('record_type', this.recordTypeValue)
    formData.append('record_id', this.recordIdValue)
    formData.append('type', this.typeValue)

    const result = this.templateTarget.cloneNode(true) as HTMLElement
    result.classList.add('flex')
    result.classList.remove('hidden')
    const textElement = result.querySelector('.fileUploadText') as HTMLElement
    const loadingElement = result.querySelector('.loading') as HTMLElement
    const errorElement = result.querySelector('.error-icon') as HTMLElement
    const successElement = result.querySelector('.success-icon') as HTMLElement

    textElement.textContent = `Uploading ${file.name}...`
    this.statusesTarget.appendChild(result)

    try {
      const token = document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') ?? ''
      const response = await fetch('/uploads', {
        method: 'POST',
        headers: { 'X-CSRF-Token': token },
        body: formData
      })

      loadingElement.classList.add('!hidden')

      if (!response.ok) {
        const error = await response.json()
        errorElement.classList.remove('!hidden')
        textElement.textContent = `${file.name}: ${error.message}`
      } else {
        const json = await response.json()
        successElement.classList.remove('!hidden')
        textElement.textContent = `${file.name} uploaded`

        const newImgElement = this.imageTemplateTarget.cloneNode(true) as HTMLElement
        newImgElement.classList.remove('hidden')
        const img = newImgElement.querySelector('.newImg') as HTMLImageElement
        img.src = json.image
        this.imagesTarget.appendChild(newImgElement)
      }
    } catch (err) {
      console.error(err)
      errorElement.classList.remove('!hidden')
      result.textContent = `${file.name}: Upload failed`
    }
  }
}
