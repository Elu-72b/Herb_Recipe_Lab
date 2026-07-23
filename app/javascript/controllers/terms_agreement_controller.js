import { Controller } from "@hotwired/stimulus";

// 同意チェックが入るまで送信ボタンを非活性にする
// メール登録と Google 新規登録の両方を対象にするため submitTargets（複数）で扱う
export default class extends Controller {
  static targets = ["checkbox", "submit"];

  connect() {
    this.toggle();
  }

  toggle() {
    const agreed = this.checkboxTarget.checked;
    this.submitTargets.forEach((button) => {
      button.disabled = !agreed;
    });
  }
}
