# 紡ぐノート

> 将来子どもに伝えたいことを、思った瞬間にストックするメモアプリ

---

## サービス概要

**紡ぐノート** は、将来子どもに伝えたい経験・学び・失敗談などを、思いついた瞬間にカテゴリ分けして記録・管理できる Web アプリケーションです。

メモ帳アプリや Notion では情報が乱立して後から見返しにくくなりがちですが、本サービスは「子どもへ伝えること」に特化することで、10年・20年後でもすぐに振り返れる記録を実現します。

### 解決する課題

| 課題 | 解決策 |
|------|--------|
| 伝えたいことを思いついても忘れてしまう | 思ったその瞬間にすぐ投稿できる UI |
| メモ帳だと情報が乱雑になる | カテゴリ・タグによる整理機能 |
| 長期間の記録は管理が難しい | 目的特化型の設計でノイズを排除 |

---

## 開発背景

妻の妊娠をきっかけに、「自分が 20 代前半で知っておくべきだったお金・キャリア・生き方の知識を子どもに伝えたい」と強く感じました。しかし、そのような気づきは日々の生活の中で突然訪れ、すぐに忘れてしまいます。

メモ帳や Notion を試しましたが、「子どもへ伝えること」に絞った専用ツールがなく、記録が他の情報に埋もれてしまう問題がありました。そこで、自分自身が本当に欲しいと思えるアプリを開発することにしました。

---

## 機能一覧

### MVP リリース

- **ユーザー認証**：メールアドレス・パスワードによる会員登録・ログイン
- **メモ投稿機能**：タイトル・本文・カテゴリを指定して投稿
- **カテゴリ管理**：大項目・小項目での分類、カスタムカテゴリの追加
- **メモ一覧・詳細表示**：投稿した記録を一覧・個別確認

### 本リリース（実装済み）

- Google OAuth ログイン
- パートナーとのメモ共有機能
- 投稿検索機能
- アプリの使い方説明機能
- 他ユーザーの事例を閲覧できる「事例紹介」機能
- 参考 URL の添付・リンクプレビュー

---

## 機能詳細

### ログイン
<img width="1921" height="963" alt="スクリーンショット 2026-05-12 9 13 07" src="https://github.com/user-attachments/assets/cde7ea2c-42b0-4b97-aa79-46f47d92816b" />

新規登録したメールアドレス or Gmailでのログインが可能です

### 「伝えたいこと」一覧
<img width="1920" height="966" alt="スクリーンショット 2026-05-12 9 13 52" src="https://github.com/user-attachments/assets/bbf97f77-2e3b-4397-a3e7-14800211d645" />

当アプリのメイン機能です。ここに自分が投稿した「伝えたいこと」が追加されていきます。検索機能では、タイトルと本文それぞれで検索を行うことが可能です。

### 「伝えたいこと」新規作成
<img width="1922" height="965" alt="スクリーンショット 2026-05-12 9 14 15" src="https://github.com/user-attachments/assets/e64e3e9a-ec54-49da-ad10-daecb34b4e37" />

ここから「伝えたいこと」を作成していきます。「伝えたいこと」はカテゴリごとに分類をしておくことができます。

### カテゴリ管理
https://github.com/user-attachments/assets/66c6233f-2148-4262-91b9-352c22b0cbd6

カテゴリは自身の好みに合わせて編集と新規作成が可能です。

### カテゴリ別「伝えたいこと」一覧
https://github.com/user-attachments/assets/3e6a133b-f3f4-4a4b-a5ae-8ce309c4ec4d

自身で振り分けたカテゴリ別に「伝えたいこと」を確認することが可能です。

### パートナー連携
https://github.com/user-attachments/assets/f0017adf-946a-4dfa-8147-76504f7a5c2d

パートナーとの連携を行うことでパートナーの許可した「伝えたいこと」を閲覧することが可能です。パートナー招待は発行したURLの共有のみで行えます。

### パートナーの投稿確認
https://github.com/user-attachments/assets/8a90bcdb-2702-4066-8199-15002094394a

パートナーとの連携後は「パートナーの投稿」ページが出来上がり、投稿を見ることが可能です。

---

## 技術スタック

### フロントエンド

| 技術 | 採用理由 |
|------|----------|
| **React 19** | コンポーネント単位の設計でメモカードなどの UI を再利用しやすくするため |
| **TypeScript** | 投稿データの型安全性を保ち、バグを早期に検出するため |
| **Vite** | SSR が不要な SPA 構成のため、ビルドが高速な Vite を採用 |
| **React Router v7** | SPA でのページ遷移を管理するため |
| **Tailwind CSS v4** | ユーティリティクラスで一貫したスタイリングを素早く実装するため |
| **shadcn/ui** | カスタマイズ性が高く、くすみカラーを基調とした柔らかい UI を実現するため |
| **Radix UI** | shadcn/ui の基盤となるアクセシブルな UI プリミティブとして使用 |
| **class-variance-authority / clsx / tailwind-merge** | 条件付きクラス管理と Tailwind のクラス競合解消のため |
| **lucide-react** | shadcn/ui と親和性が高い軽量アイコンライブラリとして使用 |
| **axios** | Rails API との HTTP 通信を簡潔に記述するため |
| **Geist フォント** | 視認性が高くモダンな印象を与えるフォントとして採用 |

### バックエンド

| 技術 | 採用理由 |
|------|----------|
| **Ruby on Rails 7.2（API モード）** | 認証・CRUD の高速実装に優れており、MVP 開発のスピードを重視して採用 |
| **PostgreSQL** | メモデータを長期的・安全に保管するため。リレーション管理の安定性が高い |
| **Devise + devise_token_auth** | トークンベースの認証（メール・パスワード）を簡潔に実装するため |
| **rack-cors** | フロントエンド（異なるオリジン）からの API リクエストを許可するため |
| **active_model_serializers** | API レスポンスの JSON 形式を統一して管理するため |
| **dotenv-rails** | 環境変数を安全に管理するため |
| **Puma** | Rails 標準の Web サーバー |
| **bootsnap** | Rails 起動時間を短縮するため |

※ Google OAuth（`googleauth`）は本リリース時に追加

### 開発・テスト

| 技術 | 採用理由 |
|------|----------|
| **Vitest** | Vite と親和性が高く、高速にユニットテストを実行できるため |
| **Testing Library（React）** | ユーザー操作に近い形でコンポーネントをテストするため |
| **RSpec** | Rails の標準的なテストフレームワーク。可読性の高いテストを書くため |
| **factory_bot_rails / faker** | テストデータの生成を効率化するため |
| **RuboCop（Rails / RSpec）** | コーディング規約を統一し、コード品質を保つため |
| **letter_opener_web** | 開発環境でのメール送信内容をブラウザ上で確認するため |
| **Postman** | API エンドポイントの動作確認に使用 |

### インフラ

| 技術 | 採用理由 |
|------|----------|
| **Render** | フロント・バックエンドともにデプロイ可能で、個人開発に適したコストで運用できるため |

---

## 画面遷移図・ER 図

- **画面遷移図（Figma）**：[こちらを確認](https://www.figma.com/design/cAkpsiTsjAk1TA4y63xlGB/%E7%94%BB%E9%9D%A2%E9%81%B7%E7%A7%BB%E5%9B%B3?node-id=0-1&t=uMApTp3N3xuy1qtb-1)
- **ER 図**：[こちらを確認](https://app.diagrams.net/?src=about#G1ruSnFpAT1I-JVZQpohtstQQh6RslnTup)

---

## ローカル環境での起動方法

### 前提条件

- Node.js 18 以上
- Ruby 3.x 以上
- PostgreSQL

### バックエンド（Rails）

```bash
git clone https://github.com/nagi558/Letters_to_be_spun
cd backend
bundle install
```

`.env` を開き、各値を設定

```bash
DEVISE_JWT_SECRET_KEY=
ADMIN_EMAIL=
DEFAULT_FROM_EMAIL=
GOOGLE_CLIENT_ID=
FRONTEND_URL=
```

```bash
rails db:create db:migrate
rails s
```

### フロントエンド（React + Vite）

```bash
cd frontend
npm install
```

`.env` を開き、各値を設定

```bash
VITE_GOOGLE_CLIENT_ID=
```

```bash
npm run dev
```

---

## こだわりポイント

- **目的特化の設計**：「子どもへ伝えること」のみに絞ることで、余計な情報が混ざらない体験を実現
- **くすみカラーの UI**：子ども・家族というテーマに合わせ、温かみのある柔らかいデザインを shadcn/ui で実現
- **テスト設計**：フロントは Vitest + Testing Library、バックエンドは RSpec でテストを整備し、品質を担保

---

## 作者

| | |
|---|---|
| **GitHub** | https://github.com/nagi558/Letters_to_be_spun |
| **ポートフォリオ** | https://tsumuguletters.com/ |
