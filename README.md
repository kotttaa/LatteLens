# LatteLens

ラテアートの練習を記録し、振り返るためのiOSアプリです。

カフェでアルバイトをしながらラテアートの練習を続ける中で、「自分の上達を手軽に振り返りたい」「同じ店舗の仲間と作品を見せ合いたい」と考えて開発しました。

<!-- スクリーンショットを追加する場合は、screenshots/ フォルダに画像を置いて以下のように記載 -->
<!-- <img src="screenshots/gallery.png" width="240"> <img src="screenshots/review.png" width="240"> -->

## 主な機能

### かんたん記録
- カメラで撮影するか、写真ライブラリから選択
- 柄（ハート／レイヤーハート／リーフ／スワン／チューリップ／ロゼッタなど）とドリンク（ラテ／抹茶ラテ／カフェモカ／フラットホワイト／カプチーノなど）をメニューから選ぶだけで保存できる
- 忙しい仕事の合間でも続けられるよう、入力項目は最小限に絞っている

### ギャラリー
- 記録した作品を2列のグリッドで一覧表示
- 柄・ドリンクごとにフィルタして、同じデザインの作品を見比べられる

### ガイド線を使った振り返り
- 作品を拡大・移動して細部を確認できる
- カップの縁と中心を示す円、縦横の十字線を重ねて表示し、**左右の対称さや絵のバランス**を感覚に頼らず確認できる

### コミュニティ共有
- 設定した「コミュニティID（合言葉）」が同じメンバー同士で作品を共有できる
- IDを設定しない場合は、すべての記録が端末内だけに保存される（完全プライベート）
- 自分の投稿はあとから削除できる

## 使用技術

| 項目 | 内容 |
| --- | --- |
| 言語 | Swift |
| UI | SwiftUI |
| ローカル保存 | UserDefaults（記録データ）＋ Documentsディレクトリ（画像） |
| バックエンド | Firebase（Authentication：匿名認証 / Cloud Firestore / Cloud Storage） |
| その他 | PhotosUI、UIImagePickerController（カメラ） |

## 構成

```
LatteLens/
├── LatteLensApp.swift        # エントリーポイント
├── ContentView.swift         # タブ構成・設定画面
├── CaptureView.swift         # 記録画面
├── CameraPicker.swift        # カメラ撮影
├── GalleryView.swift         # ギャラリー（一覧・フィルタ）
├── ReviewView.swift          # 振り返り画面（拡大・ガイド線）
├── CommunityFeedView.swift   # コミュニティの投稿一覧
├── LatteArtwork.swift        # 記録データのモデル
├── CommunityArtwork.swift    # 共有投稿のモデル
├── ArtworkStore.swift        # ローカル保存の管理
└── FirebaseManager.swift     # 認証・アップロード・削除
```

## 動作環境・ビルド方法

- iOS 16 以降 / Xcode 15 以降

1. このリポジトリをクローンする
2. 自分のFirebaseプロジェクトを作成し、Authentication（匿名）・Firestore・Storage を有効にする
3. ダウンロードした `GoogleService-Info.plist` を `LatteLens/` に配置する（このリポジトリには含めていません）
4. `LatteLens.xcodeproj` を開いてビルドする

## 今後の予定

- App Storeでの公開
- 店舗の仲間に使ってもらい、フィードバックをもとに改善する
