import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { max: Number }

  limit(event) {
    const checked = this.element.querySelectorAll("input[type=checkbox]:checked")
    if (checked.length > this.maxValue) {
      event.currentTarget.checked = false
    }
  }
}
