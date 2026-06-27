import { Controller } from "@hotwired/stimulus";

// クリックでページ最上部へスムーススクロールする
export default class extends Controller {
  scroll(event) {
    event.preventDefault();
    window.scrollTo({ top: 0, behavior: "smooth" });
  }
}
