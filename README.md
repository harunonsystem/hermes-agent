# hermes-agent

Hermes のローカル設定、persona、skills、hooks を Git で管理するためのリポジトリ。

## 管理対象

- `config.yaml`: Hermes の設定
- `SOUL.md`: Hermes の人格・応答方針
- `mise.toml`: Python/uv の tool version
- `pyproject.toml` / `uv.lock`: 検証 script の Python 依存関係
- `skills/`: Hermes skills
- `hooks/`: Hermes hooks
- `scripts/`: GitHub Actions とローカルで共用する検証・通知 script
- `.github/workflows/`: 補助 workflow
- `channel_directory.example.json`: `channel_directory.json` のサニタイズ済み例

## 管理しないもの

`channel_directory.json` は Git 管理しない。Discord のチャンネル名・スレッド名に会話内容や個人情報が入ることがあるため。

`.gitignore` で runtime state、cache、logs、memory、`__pycache__`、`*.pyc` も除外する。

## 使い方

### `~/.hermes` からこのリポジトリへ取り込む

```bash
./sync.sh pull
```

### このリポジトリから `~/.hermes` へ反映する

```bash
./sync.sh deploy
```

反映後、必要に応じて Hermes gateway を再起動する。

```bash
hermes gateway restart
```

### 自動同期

```bash
./auto-sync.sh
```

`auto-sync.sh` は repository-managed files だけを stage する。`channel_directory.json` は PII 混入を避けるため自動 commit 対象外。

## セキュリティ方針

- secret は `.env` や GitHub Secrets に置き、Git に直接入れない
- `channel_directory.json`、sessions、logs、memories は commit しない
- `privacy.redact_pii` は `true` を基本にする
- セキュリティ検査が落ちた時に fail closed するため `security.tirith_fail_open` は `false` を基本にする

## 検証

ローカルでは最低限これを確認する。

```bash
mise trust
mise install
pinact run --check --verify
bash scripts/gha/validate.sh
```

GitHub Actions の `Validate repository` workflow では、`mise.toml` で Python/uv を用意し、`scripts/gha/validate.sh` を実行して shell syntax、Python compile、JSON/YAML/frontmatter parse を検証する。pinact はローカルで必要な時だけ実行する。
