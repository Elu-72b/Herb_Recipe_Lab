import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["category", "name"]
  static values = { categories: Object }

  change() {
    const category = this.categoryTarget.value
    const names = this.categoriesValue[category] || []
    this.nameTarget.innerHTML = '<option value="">指定なし（分類全体）</option>' +
      names.map((n) => `<option value="${n}">${n}</option>`).join("")
  }
}
