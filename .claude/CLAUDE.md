# CLAUDE.md — Herb Recipe Lab

## 1. プロジェクト概要

配合（STEP 1）から感想（STEP 2）へ繋がる2段階保存が特徴のハーブティー管理アプリ。
Tech: Ruby 3.4 / Rails 7.2 / PostgreSQL / Docker / TailwindCSS / Stimulus / Turbo

## 2. 参照ファイルの優先順位

1. `.agent/issue_mvp.md` / `.agent/issue_full.md` — 現在のタスクと完了条件
2. `.agent/skills/GUIDELINE.md` — 開発規約・命名規則
3. `.agent/er_diagram.md` — テーブル設計
4. `.agent/templates/` — issue・PR・コミットテンプレート
5. `.claude/commands/` — 各機能の拡張コマンド

判断衝突時: 最新指示 > `issue.md` > `GUIDELINE.md`

## 3. よく使うコマンド

すべて `docker compose exec web [command]` 経由で実行。

- Test: `bundle exec rspec`
- DB: `bin/rails db:migrate`
- CSS: `bin/rails tailwindcss:build`
- Console: `bin/rails console`

## 4. 開発・設計の基本方針

- **Thin Controller**: ロジックは Service または Model へ。
- **2-Step Flow**: 配合と感想を別アクションで保存する仕様を厳守。
- **Unit Logic**: `recipe_herbs.unit` (g/tsp) の管理ロジックを尊重。
- **N+1 Prevention**: 関連取得時は `includes` 必須。

## 5. Git の作業ルール

ブランチ: `feature/#[issue_no]-[summary]`
Prefix: `feat`, `fix`, `docs`, `style`, `refactor`, `test`

## 6. Claude Code への禁止事項

- テーブルの削除・カラムの削除を含むマイグレーション（要ユーザー確認）
- `issue_mvp.md`, `issue_full.md` に記載のない新機能の追加
- `db/seeds.rb` の上書き
- 既存テストの削除

---

## 6.5 ドキュメント生成ルール（Claude Code）

### テンプレート参照

issue・PRコメント・コミットメッセージを作成する際は、必ず下記テンプレートを参照し、フォーマットに沿って文章を作成すること。

- Issue        : `.agent/templates/issue_template.md`
- PR コメント  : `.agent/templates/pr_template.md`
- コミット     : `.agent/templates/commit_template.md`

### 実装提案の保存

実装提案・設計案を作成した場合は `.agent/development_plan/` 配下に保存すること。
ファイル名形式: `YYYYMMDD_<概要>.md`
例: `20260610_herb_search_plan.md`

### ログの保存

issue・PRコメント・コミットメッセージを作成した場合は `.agent/development_log/` 配下にも保存すること。

### ストーリーポイント

1 issue あたり **3P 未満**（1P = 2h）を厳守。3P を超える場合は issue を分割すること。

### ファイル修正案の明示ルール

修正案を提示する際は、以下を必ず明記すること。

1. 編集対象ファイルのパス
2. 編集箇所（行番号、または前後のコードスニペット）
3. 変更前 → 変更後 の差分形式

---

## 7. 効率的な動作とトークン節約 (Efficiency & Performance)

エージェントの実行速度向上とトークン消費削減のため、以下の動作を徹底してください。

- **重複アクセスの禁止**: 一度読み込んだファイルの内容は記憶し、変更がない限り短時間に何度も読み直さない。
- **検索の最適化**: 広い範囲を `read_file` する前に、`grep_search` や `glob` を使用して対象を絞り込む。
- **ターンの統合**: 関連する調査や編集は、可能な限り1回のツール実行（並列呼び出し）にまとめる。
- **最小限の出力**: ユーザーから求められない限り、実行結果の長い要約や挨拶を省き、技術的な意図と結果のみを簡潔に伝える。
- **差分編集の優先**: ファイル全体の上書きよりも、特定の箇所を狙った `replace` を優先し、コンテキスト負荷を下げる。
