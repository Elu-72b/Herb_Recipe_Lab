# Issue テンプレート

## タイトル・ブランチ名の規定

issue タイトルの頭には、作業ブランチの種類に対応する prefix を付けること。
ブランチ名は `<種類>/#<issue番号>-<summary>` とする。

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

例: `chore: Dependabot alerts / security updates を有効化し、dependabot.yml を見直す`（ブランチ: `chore/#271-update-dependabot-config`）

---

## 概要

## 背景・目的

## 課題

## タスク
- [ ] 

## 完了目安

## ストーリーポイント :○P (2h=1P)

---
> **ルール**: 1 issue あたり **3P 未満**（6h未満）を厳守。3P を超える場合は issue を分割すること。
