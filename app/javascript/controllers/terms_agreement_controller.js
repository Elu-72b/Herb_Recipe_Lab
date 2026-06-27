import { Controller } from "@hotwired/stimulus";

// 同意チェックが入るまで送信ボタンを非活性にする
export default class extends Controller {
  static targets = ["checkbox", "submit"];

  connect() {
    this.toggle();
  }

  toggle() {
    this.submitTarget.disabled = !this.checkboxTarget.checked;
  }
}
