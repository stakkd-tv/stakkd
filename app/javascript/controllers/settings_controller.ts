import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="settings"
export default class extends Controller {
  static targets = ['profilePictureUpload', 'profilePictureImage', 'backgroundUpload', 'backgroundImage']

  declare profilePictureUploadTarget: HTMLInputElement
  declare profilePictureImageTarget: HTMLImageElement
  declare backgroundUploadTarget: HTMLInputElement
  declare backgroundImageTarget: HTMLImageElement

  connect () {
    this.profilePictureUploadTarget.addEventListener('change', this.uploadProfilePicture.bind(this))
    this.backgroundUploadTarget.addEventListener('change', this.uploadBackground.bind(this))
  }

  triggerProfilePicture () {
    this.profilePictureUploadTarget.click()
  }

  triggerBackground () {
    this.backgroundUploadTarget.click()
  }

  uploadProfilePicture () {
    this.upload(this.profilePictureUploadTarget, this.profilePictureImageTarget)
  }

  uploadBackground () {
    this.upload(this.backgroundUploadTarget, this.backgroundImageTarget)
  }

  upload (uploadTarget: HTMLInputElement, imageTarget: HTMLImageElement) {
    const file = uploadTarget.files?.[0]
    if (file) {
      const reader = new FileReader()
      reader.onload = (e) => {
        imageTarget.src = e.target?.result as string
      }
      reader.readAsDataURL(file)
    }
  }
}
