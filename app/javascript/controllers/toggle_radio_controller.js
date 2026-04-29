import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  toggle(event) {
    const clicked = event.currentTarget
    if (clicked.dataset.wasChecked === "true") {
      clicked.checked = false
      clicked.dataset.wasChecked = "false"
    } else {
      this.inputTargets.forEach(input => { input.dataset.wasChecked = "false" })
      clicked.dataset.wasChecked = "true"
    }
  }
}
