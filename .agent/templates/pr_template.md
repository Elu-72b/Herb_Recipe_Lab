# PR コメント テンプレート

## PR タイトルの規定

PR タイトルの頭には、マージ元ブランチの種類に対応する prefix を付けること（issue タイトルと揃える）。

| ブランチ | issue・PR タイトルの頭 |
| --- | --- |
| `feature/` | `feat:` |
| `fix/` | `fix:` |
| `hotfix/` | `hotfix:` |
| `refactor/` | `refactor:` |
| `chore/` | `chore:` |
| `docs/` | `docs:` |
| `test/` | `test:` |
| `spike/`(issue のみ。PR はマージしない) | `spike:` |
| develop → main(リリース) | `release:` |

---

> PRコメントは以下のフォーマットを **1つのコードブロック（```markdown）内** に記述すること。

````markdown
## 概要

## 背景

## 変更内容（内容によっては表も用いてわかりやすく）

- **変更内容1**
  - 詳細を箇条書き
- **変更内容2**
  - 詳細を箇条書き

## 確認方法

## 影響範囲

- 箇条書き

## スクリーンショット

** ページ名・機能
| 改善前 | 改善後 |
| --- | --- |
|  |  |

## 関連 issue

Closes #"GitHubのissue番号"
````
