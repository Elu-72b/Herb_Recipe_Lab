import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.expanded = false;
    this.collapseHandler = (e) => {
      if (!this.element.contains(e.target)) this.collapse();
    };
    document.addEventListener("click", this.collapseHandler);
  }

  disconnect() {
    document.removeEventListener("click", this.collapseHandler);
    clearTimeout(this.timer);
  }

  toggle(event) {
    // PC幅(768px以上)では即遷移
    if (window.innerWidth >= 768) return;

    event.preventDefault();

    if (!this.expanded) {
      this.expanded = true;
      this.element.classList.add("fab-expanded");
      clearTimeout(this.timer);
      this.timer = setTimeout(() => this.collapse(), 3000);
    } else {
      window.location.href = this.element.href;
    }
  }

  collapse() {
    this.expanded = false;
    this.element.classList.remove("fab-expanded");
    clearTimeout(this.timer);
  }
}
