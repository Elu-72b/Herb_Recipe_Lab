import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fieldList", "template"]

  addField(event) {
    event.preventDefault()
    const clone = this.templateTarget.content.cloneNode(true)
    this.fieldListTarget.appendChild(clone)
  }

  removeField(event) {
    event.preventDefault()
    event.stopPropagation()
    const field = event.currentTarget.closest(".tag-field")
    if (this.fieldListTarget.querySelectorAll(".tag-field").length > 1) {
      field.remove()
    } else {
      field.querySelectorAll("select").forEach((select) => {
        select.value = ""
        select.dispatchEvent(new Event("change", { bubbles: true }))
      })
    }
  }
}
