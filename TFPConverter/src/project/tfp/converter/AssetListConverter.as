package project.tfp.converter 
{
	import flash.filesystem.File;
	import net.morocoshi.air.files.FileUtil;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class AssetListConverter 
	{
		private var stock:Vector.<File>;
		private var extension:String;
		private var ignoreExtension:Array;
		private var compress:Boolean;
		private var threshold:Number;
		private var converter:AssetConverter;
		private var completeCount:int;
		private var maxCount:int;
		
		public var onComplete:Function;
		public var onProgress:Function;
		public var onError:Function;
		
		public function AssetListConverter() 
		{
		}
		
		/**
		 * 複数フォルダをまとめてTFP化します。ファイルの保存先とTFPファイル名は自動決定されます。
		 * @param	file	このフォルダ内の全データが結合される
		 * @param	extension	書き出すTFPの拡張子
		 * @param	compress	圧縮するか
		 * @param	threshold	compress=true時に圧縮率がこの値を超えていたら圧縮しない。1で必ず圧縮する（@@@圧縮率1超えもあるのでこの条件を後でなんとかする）
		 */
		public function convertFolderList(fileList:Vector.<File>, extension:String, ignoreExtension:Array, compress:Boolean, threshold:Number = 1):void
		{
			this.extension = extension;
			this.compress = compress;
			this.ignoreExtension = ignoreExtension;
			this.threshold = threshold;
			stock = fileList.concat();
			
			completeCount = 0;
			maxCount = stock.length;
			next();
		}
		
		/**
		 * 指定フォルダ直下にあるサブフォルダをまとめてTFP化する
		 * @param	file
		 * @param	extension
		 * @param	ignoreExtension
		 * @param	compress
		 * @param	threshold
		 */
		public function convertSubFolder(file:File, extension:String, ignoreExtension:Array, compress:Boolean, threshold:Number):void 
		{
			var files:Vector.<File> = FileUtil.scanDirectory(file, false, 0);
			if (!files.length)
			{
				onComplete(-1);
				return;
			}
			convertFolderList(files, extension, ignoreExtension, compress, threshold);
		}
		
		/**
		 * ファイル1個を取り出してTFP化開始
		 */
		private function next():void
		{
			if (!stock.length)
			{
				complete();
				return;
			}
			
			var file:File = stock.shift();
			var output:File = file.parent.resolvePath(file.name + "." + extension);
			
			converter = new AssetConverter();
			converter.onError = converter_errorHandler;
			converter.onProgress = converter_progressHandler;
			converter.onComplete = converter_completeHandler;
			converter.convert(file, output, ignoreExtension, compress, threshold);
		}
		
		/**
		 * 全ての処理が完了した時
		 */
		private function complete():void 
		{
			converter = null;
			onComplete(-1);
		}
		
		private function converter_completeHandler(rate:Number):void 
		{
			completeCount++;
			next();
		}
		
		private function converter_errorHandler(text:String):void 
		{
			onError(text);
		}
		
		private function converter_progressHandler(per:Number):void 
		{
			var rate:Number = (completeCount + per) / maxCount;
			onProgress(rate);
		}
		
	}

}