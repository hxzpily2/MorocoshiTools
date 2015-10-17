package project.m3dexporter.grid 
{
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.geom.ColorTransform;
	import net.morocoshi.air.components.minimal.Modal;
	import net.morocoshi.air.files.FileUtil;
	import net.morocoshi.air.menu.AirMenu;
	import net.morocoshi.common.graphics.Palette;
	import net.morocoshi.common.math.geom.ScaleMode;
	import net.morocoshi.common.timers.FrameTimer;
	import net.morocoshi.components.balloon.MouseOverLabel;
	import net.morocoshi.components.minimal.grid.DataGridEvent;
	import net.morocoshi.components.minimal.grid.DataGridItem;
	import net.morocoshi.components.minimal.grid.GridCellBitmap;
	import net.morocoshi.components.minimal.grid.GridCellButton;
	import net.morocoshi.components.minimal.grid.GridCellCheckBox;
	import net.morocoshi.components.minimal.grid.GridCellInputFile;
	import net.morocoshi.components.minimal.grid.GridCellInputText;
	import net.morocoshi.components.minimal.input.InputFile;
	import net.morocoshi.moja3d.loader.exporters.M3DExportOption;
	import project.m3dexporter.asset.Asset;
	import project.m3dexporter.data.ConvertItem;
	import project.m3dexporter.Main;
	import project.m3dexporter.setting.Settings;
	/**
	 * ...
	 * @author tencho
	 */
	public class RowItem 
	{
		private var item:DataGridItem;
		public var data:ConvertItem;
		
		private var exportModel:GridCellBitmap;
		private var exportImage:GridCellBitmap;
		private var exportAnimation:GridCellBitmap;
		private var selectCheck:GridCellCheckBox;
		private var status:GridCellBitmap;
		private var option:GridCellButton;
		private var convert:GridCellButton;
		private var ignoreFolder:GridCellCheckBox;
		private var materialFolder:GridCellInputFile;
		private var sourceFile:GridCellInputFile;
		private var fixPNG:GridCellCheckBox;
		private var threshold:GridCellInputText;
		private var previewButton:GridCellButton;
		private var offAlpha:Number = 0.1;
		private var errorList:Array = [];
		
		public function RowItem(item:DataGridItem, convertItem:ConvertItem) 
		{
			this.item = item;
			this.data = convertItem;
			
			item.extra = this;
			exportModel = item.getComponent("exportModel") as GridCellBitmap;
			exportImage = item.getComponent("exportImage") as GridCellBitmap;
			exportAnimation = item.getComponent("exportAnimation") as GridCellBitmap;
			ignoreFolder = item.getComponent("ignoreFolder") as GridCellCheckBox;
			materialFolder = item.getComponent("materialFolder") as GridCellInputFile;
			sourceFile = item.getComponent("source") as GridCellInputFile;
			status = item.getComponent("status") as GridCellBitmap;
			selectCheck = item.getComponent("select") as GridCellCheckBox;
			option = item.getComponent("option") as GridCellButton;
			convert = item.getComponent("convert") as GridCellButton;
			fixPNG = item.getComponent("fixPNG") as GridCellCheckBox;
			threshold = item.getComponent("threshold") as GridCellInputText;
			previewButton = item.getComponent("preview") as GridCellButton;
			convert.transform.colorTransform = Palette.getMultiplyColor(0xffdd77, 1);
			
			materialFolder.inputMode = InputFile.MODE_FOLDER;
			sourceFile.inputMode = InputFile.MODE_FILE_OPEN;
			ignoreFolder.addEventListener(DataGridEvent.CHANGE, ignore_selectHandler);
			selectCheck.addEventListener(DataGridEvent.CHANGE, cehck_selectHandler);
			fixPNG.addEventListener(DataGridEvent.CHANGE, fix_selectHandler);
			option.addEventListener(MouseEvent.CLICK, option_clickHandler);
			convert.addEventListener(MouseEvent.CLICK, convert_clickHandler);
			previewButton.addEventListener(MouseEvent.CLICK, preview_clickHandler);
			status.addEventListener(MouseEvent.CLICK, status_clickHandler);
			var menu:AirMenu = new AirMenu();
			menu.addMenuItem("共通設定", "", null, commonOptionHandler);
			menu.addMenuItem("個別設定", "", null, localOptionHandler);
			option.contextMenu = menu;
			
			for each(var bitmap:GridCellBitmap in [exportModel, exportImage, exportAnimation])
			{
				bitmap.scaleMode = ScaleMode.NONE;
				bitmap.buttonMode = true;
				bitmap.addEventListener(MouseEvent.CLICK, export_clickHandler);
			}
			status.scaleMode = ScaleMode.NONE;
			
			ignoreFolder.cellValue = data.ignoreFolder;
			materialFolder.cellValue = data.materialFolder;
			sourceFile.cellValue = data.sourceFile;
			exportModel.bitmapClip.alpha = data.exportModel? 1 : 0.1;
			exportImage.bitmapClip.alpha = data.exportImage? 1 : 0.1;
			exportAnimation.bitmapClip.alpha = data.exportAnimation? 1 : 0.1;
			fixPNG.cellValue = data.fixPngEdge;
			threshold.cellValue = String(data.threshold);
			option.cellValue = data.useCommon ? "共有設定" : "個別設定";
			ignore_selectHandler(null);
			fix_selectHandler(null);
			
			var menu2:AirMenu;
			menu2 = new AirMenu();
			menu2.addMenuItem("このフォルダを開く", "", null, openFolderHandler, [materialFolder]);
			materialFolder.button.contextMenu = menu2;
			menu2 = new AirMenu();
			menu2.addMenuItem("このフォルダを開く", "", null, openFolderHandler, [sourceFile]);
			sourceFile.button.contextMenu = menu2;
			
			//FrameTimer.setTimer(1, updatePreviewButton);
			
			MouseOverLabel.instance.setLabel(ignoreFolder, "マテリアルパスのフォルダを削る");
			MouseOverLabel.instance.setLabel(fixPNG, "透過PNGの縁の黒ずみを修正する（重い）");
			MouseOverLabel.instance.setLabel(threshold, "透過PNGの透明度がこの値以下のピクセルを\n透過領域として黒ずみ修正する");
			MouseOverLabel.instance.setLabel(exportModel, "モデルを書き出す");
			MouseOverLabel.instance.setLabel(exportImage, "画像を書き出す");
			MouseOverLabel.instance.setLabel(exportAnimation, "アニメーションを書き出す\nこれだけにチェックをつけるとモーションファイルになる");
		}
		
		private function openFolderHandler(folder:GridCellInputFile):void 
		{
			var file:File = FileUtil.toFile(folder.cellValue);
			if (file == null) return;
			
			if (file.isDirectory)
			{
				file.openWithDefaultApplication();
				return;
			}
			
			file.parent.openWithDefaultApplication();
		}
		
		private function localOptionHandler():void
		{
			option.label = "個別設定";
			data.useCommon = false;
		}
		
		private function commonOptionHandler():void 
		{
			option.label = "共有設定";
			data.useCommon = true;
		}
		
		private function status_clickHandler(e:MouseEvent):void 
		{
			if (errorList.length == 0) return;
			Modal.alert(errorList.join("\n"));
		}
		
		private function preview_clickHandler(e:MouseEvent):void 
		{
			var file:File = getOutputFile();
			if (file)
			{
				if (file.exists)
				{
					file.openWithDefaultApplication();
				}
				else
				{
					Modal.alert(file.nativePath + " が見つかりません！");
				}
				return;
			}
			
			Modal.alert("対応するM3Dファイルが見つかりません！");
		}
		
		private function updatePreviewButton():void 
		{
			previewButton.enabled = getOutputFile() != null;
		}
		
		private function fix_selectHandler(e:DataGridEvent):void 
		{
			threshold.enabled = fixPNG.cellValue;
		}
		
		private function ignore_selectHandler(e:DataGridEvent):void 
		{
			materialFolder.enabled = ignoreFolder.cellValue;
		}
		
		public function save():void
		{
			data.exportAnimation = exportAnimation.bitmapClip.alpha == 1;
			data.exportImage = exportImage.bitmapClip.alpha == 1;
			data.exportModel = exportModel.bitmapClip.alpha == 1;
			data.materialFolder = materialFolder.cellValue;
			data.ignoreFolder = ignoreFolder.cellValue;
			data.sourceFile = sourceFile.cellValue;
			data.fixPngEdge = fixPNG.cellValue;
			data.threshold = uint(threshold.cellValue);
			if (data.threshold > 0xff) data.threshold = 0xff;
		}
		
		private function convert_clickHandler(e:MouseEvent):void 
		{
			var me:RowItem = this;
			var output:File = getOutputFile();
			if (Main.current.user.checkOverride && output && output.exists)
			{
				Modal.confirm(output.nativePath + "\nは既に存在するファイルですが上書きしますか？", function():void
				{
					Main.current.tracer.clear();
					Main.current.convertManager.addRow(me);
				});
			}
			else
			{
				Main.current.tracer.clear();
				Main.current.convertManager.addRow(this);
			}
		}
		
		public function setEnabled(enabled:Boolean):void 
		{
			item.sprite.mouseEnabled = enabled;
			item.sprite.mouseChildren = enabled;
			item.sprite.alpha = enabled? 1 : 0.5;
		}
		
		/**
		 * 書き出し先ファイルを取得する
		 * @return
		 */
		public function getOutputFile():File 
		{
			var output:File = Main.current.getOutputFolder(data);
			if (output == null) return null;
			
			var source:File = getSourceFile();
			if (source == null) return null;
			
			return FileUtil.changeExtension(output.resolvePath(source.name), "m3d");
		}
		
		public function getSourceFile():File 
		{
			return FileUtil.toFile(sourceFile.cellValue);
		}
		
		public function getMaterialFolder():File 
		{
			var source:File = getSourceFile();
			return source? source.parent.resolvePath(materialFolder.cellValue) : null;
		}
		
		public function loading():void
		{
			status.cellValue = Asset.loadingIcon;
			status.buttonMode = false;
			errorList = [];
		}
		
		public function success():void
		{
			status.cellValue = Asset.successIcon;
			status.buttonMode = false;
			errorList = [];
		}
		
		public function error(list:Array):void 
		{
			status.cellValue = Asset.errorIcon;
			status.buttonMode = true;
			errorList = list? list.concat() : [];
		}
		
		public function caution(list:Array):void 
		{
			status.cellValue = Asset.cautionIcon;
			status.buttonMode = true;
			errorList = list? list.concat() : [];
		}
		
		private function option_clickHandler(e:MouseEvent):void 
		{
			var option:M3DExportOption = data.useCommon? Main.current.user.commonOption : data.localOption;
			new Settings().open(option);
		}
		
		private function cehck_selectHandler(e:DataGridEvent):void 
		{
			if (selectCheck.checkBox.selected)
			{
				item.sprite.transform.colorTransform = Palette.getMultiplyColor(0x77aaee, 1);
			}
			else
			{
				item.sprite.transform.colorTransform = new ColorTransform();
			}
		}
		
		private function export_clickHandler(e:MouseEvent):void 
		{
			var bitmap:GridCellBitmap = e.currentTarget as GridCellBitmap;
			bitmap.bitmapClip.alpha = bitmap.bitmapClip.alpha == 1? offAlpha : 1;
		}
		
	}

}