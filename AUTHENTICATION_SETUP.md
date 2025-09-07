# React + Rails ハイブリッド認証セットアップ手順

## 概要
このドキュメントは、既存のRails認証とGoogle OAuth認証を統合したハイブリッド認証システムのセットアップ手順を説明します。

## 1. 必要な Gem のインストール

```bash
bundle install
```

以下のgemが追加されます：
- `omniauth`
- `omniauth-google-oauth2`
- `omniauth-rails_csrf_protection`

## 2. データベースマイグレーション実行

```bash
rails db:migrate
```

これにより `biru_users` テーブルに以下のカラムが追加されます：
- `google_id` (string): GoogleのユニークID
- `auth_provider` (string): 認証プロバイダー ('local' または 'google')
- `email` (string): メールアドレス

## 3. Google OAuth設定

### 3.1 Google Cloud Console設定
1. [Google Cloud Console](https://console.cloud.google.com/) にアクセス
2. プロジェクトを選択または作成
3. **APIs & Services > Credentials** へ移動
4. **Create Credentials > OAuth 2.0 Client IDs** を選択
5. Application typeは **Web application** を選択
6. **Authorized redirect URIs** に以下を追加：
   - 開発環境: `http://localhost:3000/auth/google/callback`
   - 本番環境: `https://yourdomain.com/auth/google/callback`

### 3.2 環境変数設定
`.env` ファイルを作成し、Google OAuth認証情報を設定：

```bash
# .env ファイル例
GOOGLE_CLIENT_ID=あなたのGoogle Client ID
GOOGLE_CLIENT_SECRET=あなたのGoogle Client Secret
```

**重要**: `.env` ファイルは `.gitignore` に追加してコミットしないでください。

## 4. アプリケーション起動

### 4.1 Rails サーバー起動
```bash
rails server
```

### 4.2 Vite 開発サーバー起動（別ターミナル）
```bash
npm run dev
```

## 5. 認証機能の使用方法

### 5.1 既存認証
- 社員番号とパスワードでのログインは従来通り利用可能
- `/cosmos` にアクセスするとログインフォームが表示
- 認証成功後、アプリケーションにリダイレクト

### 5.2 Google OAuth認証
- ログインフォームの「Googleでログイン」ボタンをクリック
- Google認証画面にリダイレクト
- 認証成功後、自動的にアプリケーションに戻る

### 5.3 アカウント連携
- 既存ユーザーが初回Google認証を行うと、メールアドレスでアカウント連携を試行
- 連携成功時は既存アカウントにGoogle認証を追加
- 連携できない場合は新規ユーザーとして作成

## 6. API エンドポイント

### 認証関連API
- `POST /api/v1/auth/login` - 既存認証（社員番号・パスワード）
- `GET /api/v1/auth/google` - Google認証開始
- `GET /api/v1/auth/me` - 現在のユーザー情報取得
- `POST /api/v1/auth/logout` - ログアウト
- `POST /api/v1/auth/link_google` - 既存アカウントとGoogle連携

## 7. トラブルシューティング

### よくある問題と解決方法

#### 7.1 Google認証エラー
```
Google認証に失敗しました
```
**解決方法**:
1. Google Client IDとSecretが正しく設定されているか確認
2. Redirect URIがGoogle Cloud Consoleの設定と一致するか確認
3. ブラウザのキャッシュをクリア

#### 7.2 CORS エラー
```
Access to fetch at '...' from origin '...' has been blocked by CORS policy
```
**解決方法**:
1. Rails サーバーとViteサーバーが両方起動しているか確認
2. `config/initializers/omniauth.rb` の設定を確認

#### 7.3 セッション関連エラー
```
ユーザーが見つかりません
```
**解決方法**:
1. ブラウザのCookieをクリア
2. Rails サーバーを再起動

## 8. セキュリティ考慮事項

- パスワードハッシュ化は現在の運用に合わせて保留
- Google OAuth認証はHTTPS環境での利用を推奨
- セッション設定の本番環境での調整が必要
- 定期的なアクセストークンの更新管理

## 9. 本番環境デプロイ時の注意点

1. 環境変数の適切な設定
2. Google OAuth CallbackのHTTPS対応
3. セッションストレージの設定（Redis等）
4. ログイン履歴機能の動作確認

## 10. 今後の拡張予定

- パスワードハッシュ化の段階的導入
- 多要素認証（MFA）の追加
- 企業SSO（SAML）対応
- ログイン試行回数制限