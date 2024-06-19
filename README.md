# ■サービス概要
「どんなサービスなのかを３行で説明してください。」

このアプリは自分にマッチした煮干しラーメン屋を見つけるためのアプリです。
マップ上に煮干しラーメン屋の位置を表示し、そのお店の詳細情報を見ることができます。
また、行ったことのあるお店については、評価やコメントを投稿することができます。

■ このサービスへの思い・作りたい理由
「このサービスの題材となるものに関してのエピソードがあれば詳しく教えてください。
このサービスを思いつくにあたって元となる思いがあれば詳しく教えてください。」

このサービスは私が実際に欲しいと思ったところから生まれたものです。
私は、高校生の頃からラーメン屋が好きで、普段は関西でラーメンを食べています。そして、別の地方へ行った際にはその地域のラーメンを何店舗
か食べ歩くことが好きです。
多くあるラーメンの中でも、特に煮干しラーメンが好きで、最近は煮干しラーメン屋を探すことが趣味になっています。
しかし、煮干しラーメンといっても濃厚系、淡麗系、つけ麺、汁なし系など様々な種類があり、自分の好みに合ったお店を見つけるのはなかなか難しいです。
そこで、ユーザーの好みに合った煮干しラーメン屋を見つけるためのアプリを作りたいと思いました。

■ ユーザー層について
「決めたユーザー層についてどうしてその層を対象にしたのかそれぞれ理由を教えてください。」

若年層(10代～20代)濃厚系煮干しラーメン屋へ行った際に高校生や大学生が複数人で来店していることが多いため、この年代を中心にターゲットとしています。
働き盛り(20代後半～40代後半)淡麗系煮干しラーメン屋へ行った際には、サラリーマンやファミリーを含めた女性が多いため、この年代もターゲットとしています。

■サービスの利用イメージ
「ユーザーがこのサービスをどのように利用できて、それによってどんな価値を得られるかを簡単に説明してください。」

ユーザーはこのサービスを使うことで、場所、味、画像などの情報を得ることができ、自分の好みに合った煮干しラーメン屋を見つけることができます。

■ ユーザーの獲得について
「想定したユーザー層に対してそれぞれどのようにサービスを届けるのか現状考えていることがあれば教えてください。」

最初は知名度がないため、何の情報もないサイトになってしまうと思います。そこで、これまで自分が行った煮干しラーメン屋の情報を投稿し、最低限の情報は得られるようにします。
そこから、RUNTEQコミュニティ内での宣伝などをして、使っていただいて情報の蓄積をしていきます。
外部の口コミレビューサイトへ投稿してリンクを貼ることが許可されている場合は、そちらに投稿も行って知名度を上げていきます。

■ サービスの差別化ポイント・推しポイント
「似たようなサービスが存在する場合、そのサービスとの明確な差別化ポイントとその差別化ポイントのどこが優れているのか教えてください。
独自性の強いサービスの場合、このサービスの推しとなるポイントを教えてください。」

二郎系のラーメン屋を探すアプリは存在しますが、煮干しラーメン屋を探すアプリは存在しないため、煮干しラーメン屋を探すアプリとして独自性を持っています。
また、煮干しラーメン屋は濃厚系、淡麗系、つけ麺、汁なし系など様々な種類があり、自分の好みに合ったお店を見つけるのはなかなか難しい一方で、
煮干しラーメン専門店など最近は増えており、煮干しラーメン屋を探したいというユーザーの需要があると考えています。
このサービスの押しポイントは、大雑把に括られてきた煮干し系ラーメン屋を細かく分類し、自分の好みに合ったお店を見つけることができる点です。

■ 機能候補
「現状作ろうと思っている機能、案段階の機能をしっかりと固まっていなくても構わないのでMVPリリース時に作っていたいもの、本リリースまでに作っていたいものをそれぞれ分けて教えてください。」

作ろうと思っている機能は、ラーメン屋の位置を表示する地図の実装。ラーメン屋の詳細情報や口コミ、画像を取得し、表示する機能。サイト独自のコメント機能。
MVPリリースとして考えているのは、トップページの作成。店舗一覧ページの作成。ユーザー登録機能。
本リリースまでには、口コミ機能、評価機能、絞り込み機能、ソーシャルシェア機能

■ 機能の実装方針予定
「一般的なCRUD以外の実装予定の機能についてそれぞれどのようなイメージ(使用するAPIや)で実装する予定なのか現状考えているもので良いので教えて下さい。」

開発環境: Docker　
フレームワーク: Ruby on Rails
データベース: PostgreSQL　
API:Google Maps JavaScript API,Google Places API
認証・認可: Devise　
画像アップロード: Active Storage
バージョン管理: Git & GitHub
デプロイ: Heroku