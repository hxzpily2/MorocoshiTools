package project.tfp.canvas.grid 
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import net.morocoshi.air.components.minimal.Modal;
	import net.morocoshi.air.files.FileUtil;
	import net.morocoshi.air.menu.AirMenu;
	import net.morocoshi.common.graphics.Palette;
	import net.morocoshi.common.math.geom.ScaleMode;
	import net.morocoshi.common.text.TextUtil;
	import net.morocoshi.components.balloon.MouseOverLabel;
	import net.morocoshi.components.minimal.grid.DataGridEvent;
	import net.morocoshi.components.minimal.grid.DataGridItem;
	import net.morocoshi.components.minimal.grid.GridCellBitmap;
	import net.morocoshi.components.minimal.grid.GridCellButton;
	import net.morocoshi.components.minimal.grid.GridCellInputFile;
	import net.morocoshi.components.minimal.grid.GridCellText;
	import net.morocoshi.components.minimal.input.InputFile;
	import project.tfp.canvas.MainCanvas;
	import project.tfp.converter.AssetConverter;
	import project.tfp.converter.AssetListConverter;
	import project.tfp.data.AssetItem;
	import project.tfp.data.AssetSetting;
	import project.tfp.Document;
	import project.tfp.file.Asset;
	
	/**
	 * 書き出しGridの行
	 * 
	 * @author tencho
	 */
	
	public class ExportRow extends DataGridItem 
	{
		private var button:GridCellButton;
		private var folder:GridCellInputFile;
		private var _isConverting:Boolean;
		private var type:GridCellBitmap;
		private var _subfolder:Boolean;
		
		public var output:GridCellInputFile;
		public var onError:Function;
		
		/**
		 * コンストラクタ
		 */
		public function ExportRow() 
		{
			_subfolder = false;
			super( { check:false, button:"書き出し" } );
			_isConverting = false;
		}
		
		public function init():void
		{
			type = getComponent("type") as GridCellBitmap;
			type.bitmapClip.scaleMode = ScaleMode.NONE;
			type.bitmapClip.useMask = false;
			type.buttonMode = true;
			type.addEventListener(MouseEvent.CLICK, type_clickHandler);
			
			folder = getComponent("folder") as GridCellInputFile;
			folder.addEventListener(DataGridEvent.CHANGE, folder_changeHandler);
			folder.inputMode = InputFile.MODE_FOLDER;//___
			
			output = getComponent("tfp") as GridCellInputFile;
			output.inputMode = InputFile.MODE_FILE_SAVE;//___
			
			button = getComponent("button") as GridCellButton;
			button.addEventListener(MouseEvent.CLICK, export_clickHandler);
			
			var menu1:AirMenu = new AirMenu();
			menu1.addMenuItem("このフォルダを開く", "", null, menu_openFolderHandler, [folder]);
			folder.button.contextMenu = menu1;//___
			var menu2:AirMenu = new AirMenu();
			menu2.addMenuItem("このフォルダを開く", "", null, menu_openFileDirHandler, [output]);
			menu2.addMenuItem("このファイルを観覧", "", null, menu_previewHandler, [output]);
			output.button.contextMenu = menu2;
		}
		
		private function type_clickHandler(e:MouseEvent):void 
		{
			_subfolder = !_subfolder;
			if (_subfolder && Document.user.showSubfolderMessage)
			{
				Document.user.showSubfolderMessage = false;
				var xml:XML = <data>
				TFP化方式が「サブフォルダ一括TFP化モード」に変更されました。
				このモードになっているフォルダをTFP化すると、
				そのフォルダ直下にあるサブフォルダを全てTFP化するようになります。
				※指定フォルダそのものはTFP化されません。
				</data>
				Modal.alert(TextUtil.getXMLCode(xml));
			}
			updateSubfolderBitmap();
		}
		
		private function menu_previewHandler(input:GridCellInputFile):void 
		{
			var f:File = FileUtil.toFile(input.cellValue);
			if (!f || !f.exists)
			{
				Modal.alert("このデータは存在しません。");
				return;
			}
			Document.canvas.explorer.showFile(f);
			Document.canvas.show(MainCanvas.TAB_PREVIEW);
		}
		
		private function menu_openFileDirHandler(input:GridCellInputFile):void 
		{
			var f:File = FileUtil.toFile(input.cellValue);
			if (f)
			{
				if (!f.isDirectory && f.parent) f = f.parent;
				if (!f.exists) f = null;
			}
			if (f) f.openWithDefaultApplication();
			else Modal.alert("フォルダが開けません。");
		}
		
		private function menu_openFolderHandler(input:GridCellInputFile):void 
		{
			var f:File = FileUtil.toFile(input.cellValue);
			if (!f || !f.exists)
			{
				Modal.alert("このフォルダは存在しません。");
				return;
			}
			if (!f.isDirectory && f.parent) f = f.parent;
			f.openWithDefaultApplication();
		}
		
		private function folder_changeHandler(e:DataGridEvent = null):void 
		{
			var f:File = FileUtil.toFile(folder.cellValue) || File.desktopDirectory;
			var name:String = f.name || "asset";
			var target:File = f.parent ? f.parent : f;
			var file:File = target.resolvePath(name + ".tfp");
			output.defaultFile = file;
		}
		
		/**
		 * 書き出し先自動設定時の書き出しファイルを取得
		 * @return
		 */
		public function getOutputFile():File
		{
			if (_subfolder) return null;
			
			if (!Document.project.assetList.setting.autoOutputPath)
			{
				return FileUtil.toFile(output.cellValue);
			}
			
			var folder:File = FileUtil.toFile(folder.cellValue);
			if (!folder || !folder.name || !folder.parent) return null;
			
			return folder.parent.resolvePath(folder.name + "." + Document.user.config.extension);
		}
		
		private function export_clickHandler(e:MouseEvent):void 
		{
			//エラーチェック
			var error:String = getErrorText();
			if (error)
			{
				onError(error);
				return;
			}
			
			//上書き確認
			var outputFile:File = getOutputFile();
			if (Document.user.config.overwrite && outputFile && outputFile.exists)
			{
				Modal.confirm(outputFile.nativePath + "\nは既に存在しますが上書きしますか？", convert);
				return;
			}
			
			convert();
		}
		
		/**
		 * 書き出し処理開始
		 */
		public function convert():void 
		{
			_isConverting = true;
			button.enabled = false;
			var setting:AssetSetting = Document.project.assetList.setting;
			var threshold:Number = setting.useCompressThreshold? setting.compressThreshold * 0.01 : 1;
			
			var file:File = FileUtil.toFile(folder.cellValue);
			if (!file)
			{
				return;
			}
			
			var extension:String = Document.user.config.extension;
			
			if (_subfolder)
			{
				var converter:AssetListConverter = new AssetListConverter();
				converter.onError = converter_errorHandler;
				converter.onComplete = converter_completeHandler;
				converter.onProgress = converter_progressHandler;
				converter.convertSubFolder(file, extension, setting.ignoreExtension, getValue("zip"), threshold);
			}
			else
			{
				var conv:AssetConverter = new AssetConverter();
				conv.onError = converter_errorHandler;
				conv.onComplete = converter_completeHandler;
				conv.onProgress = converter_progressHandler;
				conv.convert(file, getOutputFile(), setting.ignoreExtension, getValue("zip"), threshold);
			}
		}
		
		/**
		 * 入力項目の不備を確認してエラーがあればエラー内容を返す。エラーがなければ空文字が返る。
		 * @return
		 */
		public function getErrorText():String
		{
			if (!FileUtil.exists(folder.cellValue))
			{
				return "アセットフォルダが存在しません。";
			}
			
			//サブフォルダ一括モードならエラーなし
			if (_subfolder) return "";
			
			if (Document.project.assetList.setting.autoOutputPath)
			{
				//サブフォルダ自動判別時
				if (!getOutputFile())
				{
					return "アセットフォルダを正しく入力してください。";
				}
			}
			else
			{
				//サブフォルダ指定時
				if (!output.cellValue)
				{
					return "書き出しファイルが指定されていません。";
				}
				if (!FileUtil.toFile(output.cellValue))
				{
					return "書き出し先が無効なファイルパスです。";
				}
			}
			return "";
		}
		
		public function setItemData(item:AssetItem):void 
		{
			setValue("folder", item.folder);
			setValue("tfp", item.output);
			setValue("zip", item.zip);
			_subfolder = item.subfolder;
			updateSubfolderBitmap();
			folder_changeHandler();
		}
		
		public function toAssetItem():AssetItem 
		{
			var assetItem:AssetItem = new AssetItem();
			assetItem.folder = getValue("folder");
			assetItem.output = getValue("tfp");
			assetItem.zip = getValue("zip");
			assetItem.memo = getValue("memo") || "";
			assetItem.subfolder = _subfolder;
			return assetItem;
		}
		
		private function updateSubfolderBitmap():void 
		{
			setValue("type", _subfolder? Asset.icons[33] : Asset.icons[0]);
			var color:ColorTransform = _subfolder? Palette.getMultiplyColor(0xA6C799, 1, 1) : new ColorTransform();
			type.panel.transform.colorTransform = color;
			output.enabled = !_subfolder;
			var help:String;
			if (_subfolder)
			{
				help = "サブフォルダを一括でTFP化します";
			}
			else
			{
				help = "指定フォルダのみTFP化します";
			}
			MouseOverLabel.instance.setLabel(type, help)
		}
		
		/**
		 * テキスト入力内のテキストを右端までスクロールする
		 */
		private function updateScrollH():void 
		{
			var tf1:TextField = folder.inputText.textField;
			var tf2:TextField = output.inputText.textField;
			tf1.scrollH = tf1.maxScrollH;
			tf2.scrollH = tf2.maxScrollH;
		}
		
		private function converter_errorHandler(text:String):void 
		{
			button.enabled = true;
			setStatus("エラー！");
			dispatchEvent(new Event(Event.CANCEL));
		}
		
		public function setRusultRate(text:String):void
		{
			GridCellText(getComponent("rate")).cellValue = text;
		}
		
		public function setStatus(text:String):void
		{
			GridCellText(getComponent("progress")).cellValue = text;
		}
		
		private function converter_progressHandler(per:Number):void 
		{
			setStatus(int(per * 100) + " %");
		}
		
		private function converter_completeHandler(rate:Number):void 
		{
			button.enabled = true;
			_isConverting = false;
			setStatus("完了！");
			var result:String;
			if (rate < 0)
			{
				result = "----";
			}
			else if (isNaN(rate))
			{
				result = "無圧縮";
			}
			else
			{
				result = (rate * 100).toFixed(1) + "%"
			}
			setRusultRate(result);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function get isConverting():Boolean 
		{
			return _isConverting;
		}
		
		public function get subfolder():Boolean 
		{
			return _subfolder;
		}
		
	}

}