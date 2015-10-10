package project.tfp.converter 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import net.morocoshi.air.files.FileUtil;
	import net.morocoshi.air.files.LocalFile;
	import net.morocoshi.common.loaders.tfp.TFPConverter;
	import net.morocoshi.common.loaders.tfp.TFPFile;
	import net.morocoshi.common.loaders.tfp.TFPFolder;
	import net.morocoshi.common.loaders.tfp.TFPLibrary;
	
	/**
	 * [Air] Fileオブジェクトの構成をAssetFolder/AssetFileオブジェクトに変換→AMF化して保存
	 * 
	 * @author tencho
	 */
	public class AssetConverter 
	{
		private var assets:Vector.<TFPFile>;
		private var currentAsset:TFPFile;
		private var lib:TFPLibrary;
		private var outputFile:File;
		private var totalNum:int;
		private var ignoreExtension:Array;
		private var compress:Boolean;
		private var threshold:Number;
		/**引数は[圧縮率0～1くらい(非圧縮=NaN)]*/
		public var onComplete:Function;
		/**引数は[進行割合0～1]*/
		public var onProgress:Function;
		/**引数は[エラーテキスト]*/
		public var onError:Function;
		
		public function AssetConverter() 
		{
			assets = new Vector.<TFPFile>;
		}
		
		/**
		 * 
		 * @param	file	このフォルダ内の全データが結合される
		 * @param	output	結合ファイルの保存先ファイル
		 * @param	compress	圧縮するか
		 * @param	threshold	compress=true時に圧縮率がこの値を超えていたら圧縮しない。1で必ず圧縮する（@@@圧縮率1超えもあるのでこの条件を後でなんとかする）
		 */
		public function convert(file:File, output:File, ignoreExtension:Array, compress:Boolean, threshold:Number = 1):void
		{
			this.compress = compress;
			this.ignoreExtension = ignoreExtension;
			this.threshold = threshold;
			outputFile = output;
			lib = new TFPLibrary();
			assets.length = 0;
			lib.root.name = file.name;
			scanFolder(lib.root, file);
			totalNum = assets.length;
			next();
		}
		
		private function next():void 
		{
			if (onProgress != null)
			{
				onProgress(1 - assets.length / totalNum);
			}
			if (!assets.length)
			{
				complete();
				return;
			}
			currentAsset = assets.shift();
			
			var l:URLLoader = new URLLoader();
			l.dataFormat = URLLoaderDataFormat.BINARY;
			l.addEventListener(Event.COMPLETE, data_completeHandler);
			l.addEventListener(IOErrorEvent.IO_ERROR, data_errorHandler);
			l.load(new URLRequest(currentAsset.local));
		}
		
		private function data_errorHandler(e:IOErrorEvent):void 
		{
			if (onError == null) return;
			onError(e.text);
		}
		
		private function data_completeHandler(e:Event):void 
		{
			currentAsset.local = null;
			currentAsset.byteArray = URLLoader(e.currentTarget).data;
			next();
		}
		
		private function complete():void 
		{
			var converter:TFPConverter = new TFPConverter();
			var data:ByteArray = converter.export(lib, compress);
			if (!data)
			{
				onError("エラーが発生しました。");
				return;
			}
			var rate:Number = NaN;
			//圧縮率のチェック
			if (compress)
			{
				var rawData:ByteArray = converter.export(lib, false);
				rate = rawData.bytesAvailable? data.bytesAvailable / rawData.bytesAvailable : 1;
				//非圧縮閾値を超えていたら圧縮しない
				if (threshold < 1 && rate > threshold)
				{
					data = rawData;
					rate = NaN;
				}
			}
			
			LocalFile.writeByteArray(outputFile, data);
			
			if (onComplete != null)
			{
				onComplete(rate);
			}
		}
		
		private function scanFolder(tfolder:TFPFolder, file:File):void
		{
			if (!file.isDirectory) return;
			for each(var f:File in file.getDirectoryListing())
			{
				if (f.isDirectory)
				{
					//フォルダ
					var dir:TFPFolder = new TFPFolder(f.name);
					tfolder.folders.push(dir);
					scanFolder(dir, f);
				}
				else
				{
					//ファイル
					var name:String = toLowerExtension(f.name);
					var fl:TFPFile = new TFPFile(name, null);
					fl.local = FileUtil.url(f);
					if (checkIgnore(f.extension)) continue;
					tfolder.files.push(fl);
					assets.push(fl);
				}
			}
		}
		
		/**
		 * ファイル拡張子を小文字化したファイル名を取得
		 * @param	name
		 * @return
		 */
		private function toLowerExtension(name:String):String 
		{
			if (name.indexOf(".") != -1) return name;
			var list:Array = name.split(".");
			var ext:String = String(list.pop()).toLowerCase();
			return list.join(".") + ext;
		}
		
		/**
		 * 拡張子で書き出しを無視するか判別する。無視拡張子リストと一致すればtrueを返す。
		 * @param	extension
		 * @return
		 */
		private function checkIgnore(extension:String):Boolean
		{
			var ext:String = extension? extension.toLowerCase() : "";
			if (ignoreExtension.indexOf(ext) != -1) return true;
			return false;
		}
		
	}

}