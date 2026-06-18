import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form"];

  connect() {
    this._onClickOutside = this._handleClickOutside.bind(this);
    document.addEventListener("click", this._onClickOutside);
  }

  disconnect() {
    document.removeEventListener("click", this._onClickOutside);
  }

  toggle() {
    this.formTarget.classList.toggle("hidden");
  }

  _handleClickOutside(event) {
    if (!this.formTarget.classList.contains("hidden") && !this.element.contains(event.target)) {
      this.formTarget.classList.add("hidden");
    }
  }
}
