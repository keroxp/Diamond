# Diamond Framework Draft
Diamond FrameworkはiOSアプリケーションの開発において頻発する様々なつらみを解決することを目的としたフレームワークです。ここでは、主にjsonを返すWeb-APIを利用したクライアントアプリケーションの問題を解決します。その草案を以下に記します。

DiamondはRequest-Connection-Collection-Modelの４つのパーツから構成されます。
下記ふたつのフレームワークに依存します。

**Mantle**

[https://github.com/github/Mantle](https://github.com/github/Mantle)

Mantleはgithubが開発したクライアント向けjsonモデルフレームワークで、非常に便利なフレームワークです。Objective-C開発者であれば必ずチェックすべきです。json（NSDictionary）をベースのデータスキーマとして、NSCoding, NSCopying準拠,JSONSeriarization（モデルオブジェクトからJSONオブジェクトへの変換）が可能です。

**AFNetworking**

[https://github.com/AFNetworking/AFNetworking](https://github.com/AFNetworking/AFNetworking)

AFNetworkingはObjctive-Cにおける最強ネットワークライブラリです。

（**ReactiveCocoa**）

[https://github.com/ReactiveCocoa/ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)

ReactiveCocoaはこのフレームワークに直接は関係しませんが、Objective-CでFRP(関数的リアクティブプログラミング)を可能にするというライブラリです。主にView-Modelのデータバインディングに用いられているようです。FRPに関しては[http://nshipster.com/reactivecocoa/](http://nshipster.com/reactivecocoa/)を読むといいと思います。


# Diamond Request
- Objective-C向けのHTTPリクエストクラス

## Requestは
- Mantleをベースとする
- Web APIへのHTTPリクエストを抽象化する
- NSCoding準拠である
- NSCopying準拠である
- JSONから生成可能でJSONへシリアライズ可能である
- パラメータが可変で、再利用が可能である

## Requestが再利用可能であるとなにがいいのか？
- urlではなく、requestに対してキャッシュが可能である
	- パラメータが違う場合などでも適切にキャッシュを用いることができる
- connection（下記）が失敗したときにリトライが可能である 

# Diamond Connection
- Objective-C向けのHTTPコネクション

## Connctionは
- AFNetworkingをベースに用いる
- AFJSONRequestOperationのサブクラスである
- DiamondRequestを使って通信を行う
- NSCoding準拠である
- NSCopying準拠である

## Connectionの存在意義
- NSOperationのサブクラスであることを利用して高度な非同期処理が可能である
	- isExecuting, isFinished, isPaused…
	- 非同期処理のstateに対してKVO & callbackが可能である
	- Functional Reactive Programmingが可能である
- Dependencyを付けてキューイングすることが可能である
- バッチ処理をまとめることができる
	- これは正確にはGCDの機能だけど

# Diamond Model
- Objective-C向けのモデルクラス

## Modelは
- JSONを基本データ構造として持つ
- Mantleをベースクラスとする
- NSCoding準拠である
- NSCopying準拠である
- すべてのプロパティについてデフォルトの値を持つ
	- nullのプロパティを持たない
- JSONからインスタンス化し、JSONにシリアライズ可能である
- 継承したすべてのプロパティのミューテーションに対して検知が可能である
- Model, Collection以外のミュータブルなプロパティを持たない
	- NSMutableString, NSMutableArray, NSMutableDictionary…
	- ミューテーションの検知ができないから
- ユーザが変更なプロパティのみセッターをもつ
- readonlyなプロパティへの変更は新しいjsonでマージする
	- 内部でセッターが呼ばれるのでミューテーションが検知できる 
- イベント駆動またはFunctional Reactive ProgrammingによってViewとのData-Bindingを可能にする
- 自身のurlに対してCRUDが可能である
- プロパティに対してのバリデーションを持つ
	- null, nil, 0 , falseなどが入るとまずい場合とか 
- 同じクラスの複数のModelがインスタンス化される場合、原則としてCollectionに収められる
- Collectionに所属するModelはCollectionにObservingされる
- 自身が持つ画像リソースについて、画像URLと一対一対応するキャッシュプロパティを持つ
	- UITableViewCellといい感じに連携したい

# Diamond Collection
- Objective-C向けのコレクションクラス
- Backbone.Collectionにインスパイアされている

## Collectionは
- NSMutableArrayもしくはNSMutableOrdredSetと同じようなインターフェースを持つ
	- 後者のサブクラスでもいいと思う 
- 可変である
	- 順次読み込みを前提とする場合、必須
	- というか可変でないコレクションを使う場面がない 
- 並び順をもつ
	- 並び順をセットすることで並び替えできる
	- 並び替えの優先度をつけることができる
		- NSSortDescriptor 
- フィルタリングが可能である
	- フィルターを追加、削除できる 	
	- NSComparator, NSPredicate
	- データとしては保持していても走査に現れない
- 単一モデルクラスのインスタンスを保持する
	- セッタで弾くことができるし、走査の時に型を保証できる
	- モデルクラス以外のインスタンスは保持できない
		- 保持する必要がないから
	- 別のクラスのインスタンスを保持したい場合は抽象クラスかクラスクラスタを使う
- 内部のミューテーションを通知する
- add, remove, push, popのミューテーションメソッドを持つ
	-  追加／削除／挿入は通知させる
- JSONからインスタンス化可能でJSONにシリアライズ可能である
- NSCopying準拠である
- NSCoding準拠である
- 自身のリソースを持つ
	- fetchとsyncが可能である
	- pushも可能でもいいかもしれない
- リソースに対してオフセットが存在する場合、その値を保持する
	- どこまで読み込んだかを記憶しておき、getNextなどできるようにする 
- UITableViewと親和性を持つ
	- section-rowに優しい
		- 五十音順でセクション分けとか
		- objectAtIndexPath… 
		- NSFetchedResultsControllerみたいな
	- コレクションの変更をUITableViewに反映し、UITableViewの変更をコレクションに反映する

## 出来れば
- 並び順の変更もいい感じに通知する
- 内部のモデルのプロパティの変更を検知する
	- リカーシブ？ 一次まで？ 
- Underscore.mと合わせてFunctionalなアクセスを可能にする

## NSMutableArrayだと何が問題なのか？
- 内部のオブジェクトについてKVO出来ない
	- そもそもポインタだからオブジェクトのプロパティの変更は分からない
- 同じオブジェクト(isEqual:での同一性）が追加できてしまう
	- 内部的に同じオブジェクトを保持する必要はないはず 
- UITableViewと親和性が高くない
	- section分けた時とかにだめになる
- 集合でない
	- 和集合、積集合、差集合...   