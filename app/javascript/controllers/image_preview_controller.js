import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview"]

  preview() {
    const file = this.inputTarget.files[0]
    if (!file) return

    // 直前のObjectURLを解放（メモリリーク防止）
    if (this.currentUrl) URL.revokeObjectURL(this.currentUrl)

    this.currentUrl = URL.createObjectURL(file)
    this.previewTarget.src = this.currentUrl
    this.previewTarget.classList.remove("hidden")
  }

  disconnect() {
    if (this.currentUrl) URL.revokeObjectURL(this.currentUrl)
  }
}