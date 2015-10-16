package project.m3dexporter 
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.Component;
	import com.bit101.components.HBox;
	import com.bit101.components.Label;
	import com.bit101.components.ProgressBar;
	import com.bit101.components.PushButton;
	import com.bit101.components.Style;
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import net.morocoshi.air.application.ApplicationData;
	import net.morocoshi.air.drop.DragDrop;
	import net.morocoshi.air.drop.DropEvent;
	import net.morocoshi.air.files.FileUtil;
	import net.morocoshi.air.files.LocalFile;
	import net.morocoshi.common.graphics.Palette;
	import net.morocoshi.common.timers.FrameTimer;
	import net.morocoshi.components.balloon.MouseOverLabel;
	import net.morocoshi.components.minimal.Bit101Util;
	import net.morocoshi.components.minimal.grid.DataGridItem;
	import net.morocoshi.components.minimal.input.InputFile;
	import net.morocoshi.components.minimal.layout.LayoutCell;
	import net.morocoshi.components.minimal.layout.LayoutData;
	import net.morocoshi.components.minimal.layout.PaddingBox;
	import net.morocoshi.components.minimal.style.Coloration;
	import project.m3dexporter.asset.Asset;
	import project.m3dexporter.converter.Converter;
	import project.m3dexporter.converter.ConvertManager;
	import project.m3dexporter.data.ConvertItem;
	import project.m3dexporter.data.UserFile;
	import project.m3dexporter.grid.FileGrid;
	import project.m3dexporter.grid.RowItem;
	import project.m3dexporter.menu.AppMenu;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Main extends Sprite
	{
		static public var current:Main;
		
		public var rootCell:LayoutCell;
		public var fileGrid:FileGrid;
		public var user:UserFile;
		public var appMenu:AppMenu;
		public var progressBar:ProgressBar;
		public var tracer:Tracer;
		public var convertManager:ConvertManager;
		
		private var outputCombo:ComboBox;
		private var outputFolder:InputFile;
		
		
		public function Main() 
		{
			current = this;
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		//--------------------------------------------------------------------------
		//
		//  初期化
		//
		//--------------------------------------------------------------------------
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			Coloration.setStyle(Coloration.STYLE_LIGHT);
			Style.fontName = "Meiryo";
			Style.fontSize = 12;
			Asset.init();
			
			stage.scaleMode = "noScale";
			stage.align = "TL";
			stage.quality = StageQuality.BEST;
			stage.frameRate = 30;
			stage.color = 0xcccccc;
			
			var app:ApplicationData = new ApplicationData();
			stage.nativeWindow.title = app.getTitleAndVersion();
			
			user = new UserFile();
			user.onBeforeSave = savingCallback;
			user.init(stage.nativeWindow);
			user.load();
			
			tracer = new Tracer();
			fileGrid = new FileGrid();
			progressBar = new ProgressBar();
			convertManager = new ConvertManager();
			//setting = new Settings();
			//fileSelector = new FileSelector();
			
			rootCell = new LayoutCell(this, 0, 0, LayoutCell.ALIGN_TOP, false);
			
			//var convert:LayoutCell = new LayoutCell(null, 0, 0, LayoutCell.ALIGN_TOP, false);
			var box:HBox = new HBox();
			var size:int = 26;
			PushButton(box.addChild(new PushButton(null, 0, 0, "行を追加", addLine))).setSize(120, size);
			PushButton(box.addChild(new PushButton(null, 0, 0, "選択を削除", deleteSelected))).setSize(120, size);
			PushButton(box.addChild(new PushButton(null, 0, 0, "全て削除", deleteAll))).setSize(120, size);
			var tool:PaddingBox = new PaddingBox(null, 0, 0, box, 5, 5, 5, 5);
			rootCell.addCell(tool, "36px", LayoutData.PIXEL);
			rootCell.addCell(progressBar, "10px", LayoutData.PIXEL);
			rootCell.addCell(fileGrid.grid, "*");
			
			outputCombo = new ComboBox();
			outputCombo.addItem("ソースと同じ場所");
			outputCombo.addItem("フォルダを指定");
			outputCombo.addEventListener(Event.SELECT, combo_selectHandler);
			Bit101Util.adjustComboList(outputCombo, 10, false);
			outputFolder = new InputFile();
			outputFolder.inputMode = InputFile.MODE_FOLDER;
			
			outputFolder.value = user.outputFolder;
			outputCombo.selectedIndex = user.outputMode;
			
			var output:LayoutCell = new LayoutCell(this, 0, 0, LayoutCell.ALIGN_LEFT, false);
			output.addCell(new PaddingBox(null, 0, 0, new Label(null, 0, 0, "書き出し先"), 5, 0, 0, 5), "80px");
			output.addCell(outputCombo, "150px");
			output.addCell(new Component(), "5px");
			output.addCell(outputFolder, "*");
			output.addCell(new Component(), "5px");
			output.addCell(new PushButton(null, 0, 0, "一括変換", convertAll), "140px").transform.colorTransform = Palette.getMultiplyColor(0xffdd77, 1);
			
			rootCell.addCell(tracer, "200px");
			rootCell.addCell(output, "30px");
			
			appMenu = new AppMenu();
			appMenu.init(user);
			stage.nativeWindow.menu = appMenu.menu;
			fileGrid.setUser(user);
			
			stage.addChild(MouseOverLabel.instance.container);
			
			stage.addEventListener(Event.RESIZE, resizeHandler);
			resizeHandler();
			
			FrameTimer.setTimer(3, activate);
		}
		
		private function convertAll(e:Event):void 
		{
			Main.current.tracer.clear();
			for each(var item:DataGridItem in fileGrid.grid.items)
			{
				convertManager.addRow(item.extra);
			}
		}
		
		private function deleteAll(e:Event):void
		{
			fileGrid.grid.removeAllItems();
		}
		
		private function deleteSelected(e:Event):void 
		{
			for each(var item:DataGridItem in fileGrid.grid.match("select", true))
			{
				fileGrid.grid.removeItem(item);
			}
		}
		
		private function addLine(e:Event):void 
		{
			fileGrid.addItem(null, null, true);
		}
		
		private function combo_selectHandler(e:Event):void 
		{
			outputFolder.enabled = (outputCombo.selectedIndex == 1);
		}
		
		private function activate():void 
		{
			stage.nativeWindow.activate();
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, invokeHandler);
		}
		
		//--------------------------------------------------------------------------
		//
		//  内部処理
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 終了直前に実行される
		 */
		private function savingCallback():void 
		{
			user.outputFolder = outputFolder.value;
			user.outputMode = outputCombo.selectedIndex;
			user.itemList.length = 0;
			var n:int = fileGrid.grid.items.length;
			for (var i:int = 0; i < n; i++) 
			{
				var row:RowItem = fileGrid.grid.items[i].extra;
				row.save();
				user.itemList.push(row.data);
			}
		}
		
		/**
		 * 関連付けたファイルを実行した時
		 * @param	e
		 */
		private function invokeHandler(e:InvokeEvent):void 
		{
			if (e.arguments.length == 0) return;
			
			var file:File = FileUtil.toFile(e.arguments[0]);
			if (file == null) return;
			
			var ext:String = file.extension? file.extension.toLowerCase() : "";
			
			if (ext == "fbx" || ext == "dae")
			{
				fileGrid.addItem(null, file, true);
				stage.nativeWindow.activate();
			}
		}
		
		public function getOutputFolder(item:ConvertItem):File
		{
			
			if (outputCombo.selectedIndex == 0)
			{
				var file:File = FileUtil.toFile(item.sourceFile);
				if (file == null) return null;
				return file.parent;
			}
			
			var folder:File = FileUtil.toFile(outputFolder.value);
			if (folder == null || folder.isDirectory == false) return null;
			
			return folder;
		}
		
		//--------------------------------------------------------------------------
		//
		//  リサイズ
		//
		//--------------------------------------------------------------------------
		
		/**
		 * ウィンドウリサイズ時
		 * @param	e
		 */
		private function resizeHandler(e:Event = null):void 
		{
			var sw:Number = stage.stageWidth;
			var sh:Number = stage.stageHeight;
			rootCell.setSize(sw, sh);
		}
		
	}

}