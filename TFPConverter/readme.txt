
TFP Converterについて

--------------------------------------------------------------------------
|
|	概要
|
--------------------------------------------------------------------------

このツールは指定のフォルダを内部のサブフォルダ構造を保ったまま
1つのファイルに結合するツールです。
結合したTFPファイルは、net.morocoshi.common.loaders.tfp.TFPLoaderクラスで
FP11コンテンツ上で中の素材を取り出す事ができます。
素材が多量にあってもダウンロード回数が抑えられるので、
サーバーリクエスト数を減らすことができます。


--------------------------------------------------------------------------
|
|	書き出し先について
|
--------------------------------------------------------------------------

初期設定ではTFPデータの書き出し先はアセットフォルダと同じ階層になります。

hoge/moja/asset/
を結合した場合、
hoge/moja/asset.tfp
に保存されます。

このTFPファイルの位置はTFPLoaderでアセットを読み込む際に重要で、
結合したフォルダと同じ階層に置いておく必要があります。
もし書き出し先を指定したい場合は、環境設定から変更してください。


--------------------------------------------------------------------------
|
|	データの圧縮について
|
--------------------------------------------------------------------------

TFPデータを書き出す際に圧縮のチェックをいれておくと
TFPファイルの容量を小さくする事ができますが、
圧縮したTFPをFlashで読み込む際に解凍に時間がかかる場合があります。


--------------------------------------------------------------------------
|
|	TFPのプレビュー
|
--------------------------------------------------------------------------

TFPConverterのプレビュー領域に書き出したTFPファイルをドロップするか、
TFPConverterに関連付けたTFPファイルを実行する事で、
TFPファイルの中身を表示する事ができます。


--------------------------------------------------------------------------
|
|	TFPLoaderについて
|
--------------------------------------------------------------------------

net.morocoshi.common.loaders.tfp.TFPLoader.as
を使うとTFPConverterで結合したTFPデータから素材を読み込む事ができます。

hoge/moja/asset/image/image001.png
hoge/moja/asset/sound/beep.mp3
hoge/moja/asset/xml/info.xml
これらの素材を
hoge/moja/asset.tfp
と結合していた場合は、

var assetList:Vector.<String> = Vector.<String>([
"hoge/moja/asset/image/image001.png", 
"hoge/moja/asset/sound/beep.mp3",
"hoge/moja/asset/xml/info.xml"
]);
var loader:TFPLoader = new TFPLoader();
loader.addEventListener(Event.COMPLETE, completeHandler);
loader.load(assetList);

上記のように結合前の素材パスの配列を渡してロードさせます。

ロード完了後、データを取得するには、

function completeHandler(e:Event):void
{
	var bmd:BitmapData = loader.getAsset("hoge/moja/asset/image/image001.png");
	var sound:Sound = loader.getAsset("hoge/moja/asset/sound/beep.mp3");
	var xml:XML = loader.getAsset("hoge/moja/asset/xml/info.xml");
}

getAsset()の引数に素材のフルパスを渡してデータを取得してください。
素材に合った型で返してほしい場合は
getXMLAsset()、getSoundAsset()などを使ってください。


--------------------------------------------------------------------------
|
|	TFPLoaderの読み込みモードの切り替えについて
|
--------------------------------------------------------------------------

TFPLoaderは、結合したtfpファイルの読み込みと、
結合前の元素材の通常読み込みを設定で切り替える事ができます。

hoge/moja/asset/image/image001.png
hoge/moja/asset/sound/beep.mp3
hoge/moja/asset/xml/info.xml
これらの素材を
hoge/moja/asset.tfp
と結合していた場合に

TFPLoader.addTFPDirectory("hoge/moja/");
とディレクトリを追加しておくと、
この登録したディレクトリ内にある素材はtfpから読み込むようになります。
(逆にaddTFPDirectory()しないと元の素材を読みに行くようになる)
