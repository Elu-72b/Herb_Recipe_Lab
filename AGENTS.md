# AGENTS.md — Herb Recipe Lab

このファイルはリポジトリ全体に適用されます。Gemini CLI・Codex・Claude Code 共通の作業指針です。
詳細な設計メモ・Issue 管理・AI 向けガイドは `.agent/` 配下を参照してください。

---

## プロジェクト概要

配合（STEP 1）から感想（STEP 2）へ繋がる2段階保存が特徴のハーブティー管理アプリ。
Tech: Ruby 3.4 / Rails 7.2 / PostgreSQL / Docker / TailwindCSS / Stimulus / Turbo

---

## 参照ファイルの優先順位

1. `.agent/issue_mvp.md` / `.agent/issue_full.md` — 現在のタスクと完了条件
2. `.agent/skills/GUIDELINE.md` — 開発規約・命名規則
3. `.agent/er_diagram.md` — テーブル設計
4. `.agent/templates/` — issue・PR・コミットテンプレート
5. `.agent/AGENTS.md` — `.agent/` 配下の編集ルール詳細

判断衝突時: 最新指示 > `issue_mvp.md` / `issue_full.md` > `GUIDELINE.md`

---

## よく使うコマンド

すべて `docker compose exec web [command]` 経由で実行。

- Test: `bundle exec rspec`
- DB: `bin/rails db:migrate`
- CSS: `bin/rails tailwindcss:build`
- Console: `bin/rails console`

---

## 開発・設計の基本方針

- **Thin Controller**: ロジックは Service または Model へ。
- **2-Step Flow**: 配合と感想を別アクションで保存する仕様を厳守。
- **Unit Logic**: `recipe_herbs.unit` (g/tsp) の管理ロジックを尊重。
- **N+1 Prevention**: 関連取得時は `includes` 必須。

---

## Git の作業ルール

ブランチ: `feature/#[issue_no]-[summary]`
Prefix: `feat`, `fix`, `docs`, `style`, `refactor`, `test`

---

## 禁止事項

- テーブルの削除・カラムの削除を含むマイグレーション（要ユーザー確認）
- `issue_mvp.md`, `issue_full.md` に記載のない新機能の追加
- `db/seeds.rb` の上書き
- 既存テストの削除

---

## ドキュメント生成ルール（全エージェント共通）

### テンプレート参照

issue・PRコメント・コミットメッセージを作成する際は、必ず下記テンプレートを参照し、フォーマットに沿って文章を作成すること。

- Issue        : `.agent/templates/issue_template.md`
- PR コメント  : `.agent/templates/pr_template.md`
- コミット     : `.agent/templates/commit_template.md`

### ファイル保存

作成したドキュメントは `.agent/development_log/` 配下に保存すること。
ファイル名形式: `YYYYMMDD_<種別>_<概要>.md`
例: `20260610_issue_add_herb_search.md`

### ストーリーポイント

1 issue あたり **3P 未満**（1P = 2h）を厳守。3P を超える場合は issue を分割すること。

### ファイル修正案の明示ルール

修正案を提示する際は、以下を必ず明記すること。

1. 編集対象ファイルのパス
2. 編集箇所（行番号、または前後のコードスニペット）
3. 変更前 → 変更後 の差分形式

例:
```
ファイル: app/models/recipe.rb (L45〜L52)
変更前:
  def some_method
    ...
  end
変更後:
  def some_method
    # 修正内容
  end
```
