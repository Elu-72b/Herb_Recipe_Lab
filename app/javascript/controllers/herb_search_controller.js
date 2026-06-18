import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fieldList", "template"]

  connect() {
    this._onClickOutside = this._handleClickOutside.bind(this)
    document.addEventListener("click", this._onClickOutside)
  }

  disconnect() {
    document.removeEventListener("click", this._onClickOutside)
  }

  _handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this._hideAllDropdowns()
    }
  }

  // ── 入力補完（キー入力） ──────────────────────────────
  async suggest(event) {
    const input = event.currentTarget
    const query = input.value.trim()
    const dropdown = input.closest(".herb-field").querySelector(".herb-suggestions")

    if (query.length === 0) {
      this.hideDropdown(dropdown)
      return
    }

    await this._fetchAndShow(query, dropdown)
  }

  // ── ▼ ボタン：全件トグル表示 ─────────────────────────
  async showAll(event) {
    event.preventDefault()
    const field    = event.currentTarget.closest(".herb-field")
    const dropdown = field.querySelector(".herb-suggestions")

    if (!dropdown.classList.contains("hidden")) {
      this.hideDropdown(dropdown)
      return
    }

    const input = field.querySelector("input[type=text]")
    await this._fetchAndShow(input.value.trim(), dropdown)
  }

  async _fetchAndShow(query, dropdown) {
    const res   = await fetch(`/herbs/autocomplete?q=${encodeURIComponent(query)}`)
    const names = await res.json()

    if (names.length === 0) {
      this.hideDropdown(dropdown)
      return
    }

    dropdown.innerHTML = names
      .map(name => `<li
          class="px-3 py-2 text-sm text-white hover:bg-herb-green-700 cursor-pointer border-b border-herb-green-500/30 last:border-b-0"
          data-name="${name}"
          data-action="mousedown->herb-search#select">
          ${name}
        </li>`)
      .join("")
    dropdown.classList.remove("hidden")
  }

  // Esc キーで閉じる
  keydown(event) {
    if (event.key === "Escape") {
      this._hideAllDropdowns()
    }
  }

  select(event) {
    const name  = event.currentTarget.dataset.name
    const field = event.currentTarget.closest(".herb-field")
    field.querySelector("input[type=text]").value = name
    this.hideDropdown(field.querySelector(".herb-suggestions"))
  }

  hideDropdown(dropdown) {
    if (dropdown) {
      dropdown.innerHTML = ""
      dropdown.classList.add("hidden")
    }
  }

  _hideAllDropdowns() {
    this.element.querySelectorAll(".herb-suggestions").forEach(d => this.hideDropdown(d))
  }

  blur(event) {
    setTimeout(() => {
      const dropdown = event.currentTarget.closest(".herb-field")?.querySelector(".herb-suggestions")
      this.hideDropdown(dropdown)
    }, 150)
  }

  // ── フィールド追加/削除 ───────────────────────────────
  addField(event) {
    event.preventDefault()
    const clone = this.templateTarget.content.cloneNode(true)
    this.fieldListTarget.appendChild(clone)
  }

  removeField(event) {
    event.preventDefault()
    event.stopPropagation()
    const field = event.currentTarget.closest(".herb-field")
    if (this.fieldListTarget.querySelectorAll(".herb-field").length > 1) {
      field.remove()
    } else {
      field.querySelector("input[type=text]").value = ""
      this.hideDropdown(field.querySelector(".herb-suggestions"))
    }
  }
}
