package project.tfp.canvas.explorer 
{
	import com.bit101.components.HBox;
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import net.morocoshi.air.components.minimal.Modal;
	import net.morocoshi.air.drop.DragDrop;
	import net.morocoshi.air.files.ClipData;
	import net.morocoshi.air.files.LocalFile;
	import net.morocoshi.air.menu.AirMenu;
	import net.morocoshi.common.loaders.tfp.TFPAssetType;
	import net.morocoshi.common.loaders.tfp.TFPExtention;
	import net.morocoshi.common.loaders.tfp.TFPFile;
	import net.morocoshi.common.loaders.tfp.TFPFolder;
	import net.morocoshi.common.loaders.tfp.TFPLoader;
	import net.morocoshi.common.loaders.tfp.TFPParser;
	import net.morocoshi.common.timers.FrameTimer;
	import net.morocoshi.components.minimal.BitmapClip;
	import net.morocoshi.components.minimal.buttons.BitmapButton;
	import net.morocoshi.components.minimal.layout.LayoutCell;
	import net.morocoshi.components.minimal.TreePanel;
	import net.morocoshi.components.tree.TreeLimb;
	import net.morocoshi.components.tree.TreeLimbEvent;
	import net.morocoshi.components.tree.TreeStyle;
	import project.tfp.converter.FolderImporter;
	import project.tfp.Document;
	import project.tfp.file.Asset;
	
	/**
	 * TFP観覧用エクスプローラ
	 * 
	 * @author tencho
	 */
	public class TFPExplorer extends LayoutCell
	{
		private var win:TreePanel;
		private var message:Label;
		private var panel:Panel;
		private var info:Label;
		private var dragDrop:DragDrop;
		private var dropped:Boolean = false;
		private var time:int;
		private var files:Vector.<TFPFile>;
		private var currentFile:File;
		private var reloadIcon:BitmapButton;
		private var copyIcon:BitmapButton;
		private var openIcon:BitmapButton;
		private var closeIcon:BitmapButton;
		private var configIcon:BitmapButton;
		
		public function TFPExplorer() 
		{
			super(null, 0, 0, ALIGN_TOP);
			var style:TreeStyle = new TreeStyle();
			style.closeIcon = style.openIcon = Asset.icons[0];
			style.icon[TFPAssetType.BYTEARRAY] = Asset.icons[1];
			style.icon[TFPAssetType.FOLDER] = Asset.icons[0];
			style.icon[TFPAssetType.IMAGE] = Asset.icons[2];
			style.icon[TFPAssetType.SOUND] = Asset.icons[4];
			style.icon[TFPAssetType.SWF] = Asset.icons[1];
			style.icon[TFPAssetType.TEXT] = Asset.icons[3];
			style.icon[TFPAssetType.TFP] = Asset.icons[1];
			style.icon[TFPAssetType.VIDEO] = Asset.icons[1];
			style.icon[TFPAssetType.XML] = Asset.icons[5];
			
			panel = new Panel();
			win = new TreePanel(null, 0, 0);
			win.scrollSpeed = 50;
			win.folder.setStyle(style);
			win.resizable = false;
			win.folder.addEventListener(TreeLimbEvent.CLICK_ITEM, tree_clickHandler);
			win.folder.addEventListener(TreeLimbEvent.WCLICK_ITEM, tree_wclickHandler);
			
			addCell(panel, "30px");
			addCell(win, "*");
			getSeparatorAt(0).enabled = false;
			
			dragDrop = new DragDrop();
			dragDrop.allowFile = true;
			dragDrop.onDragDrop = file_dropHandler;
			dragDrop.addDropTarget(win);
			
			message = new Label(this, 0, 0, "ここにTFPファイルをドロップするとプレビューできます。");
			message.alpha = 0;
			
			var box:HBox = new HBox(panel, 10, 7);
			box.spacing = 10;
			
			openIcon = new BitmapButton(box, 0, 0, Asset.icons[29], null, null, folder_openHandler);
			closeIcon = new BitmapButton(box, 0, 0, Asset.icons[30], null, null, folder_closeHandler);
			new BitmapClip(box, 0, 0, Asset.separater);
			configIcon = new BitmapButton(box, 0, 0, Asset.icons[20], null, null, config_clickHandler);
			copyIcon = new BitmapButton(box, 0, 0, Asset.icons[17], null, null, copy_clickHandler);
			reloadIcon = new BitmapButton(box, 0, 0, Asset.icons[31], null, null, reload_clickHandler);
			new BitmapClip(box, 0, 0, Asset.separater);
			info = new Label(box, 0, -2, "");
			
			for (var i:int = 0; i < box.numChildren; i++) 
			{
				var icon:BitmapButton = box.getChildAt(i) as BitmapButton;
				if (!icon) continue;
				icon.addEventListener(MouseEvent.ROLL_OVER, icon_rollEvent);
				icon.addEventListener(MouseEvent.ROLL_OUT, icon_rollEvent);
			}
			
			FrameTimer.setTimer(1, onTimesUp);
			updateIcons();
		}
		
		private function icon_rollEvent(e:MouseEvent):void 
		{
			if (e.type == MouseEvent.ROLL_OUT)
			{
				info.text = "";
				return;
			}
			switch(e.currentTarget)
			{
				case openIcon: info.text = "全てのフォルダを開く"; break;
				case closeIcon: info.text = "全てのフォルダを閉じる"; break;
				case configIcon: info.text = "TFPプレビューの設定"; break;
				case copyIcon: info.text = "全アセットパスの配列をコピー"; break;
				case reloadIcon: info.text = "再読み込み"; break;
			}
		}
		
		private function updateIcons():void
		{
			var enabled:Boolean = !!currentFile;
			reloadIcon.enabled = enabled;
			openIcon.enabled = enabled;
			closeIcon.enabled = enabled;
			reloadIcon.enabled = enabled;
			copyIcon.enabled = enabled;
		}
		
		private function reload_clickHandler(e:MouseEvent):void 
		{
			if (!currentFile) return;
			showFile(currentFile);
		}
		
		private function config_clickHandler(e:MouseEvent):void 
		{
			new ExplorerConfigWindow().open(Document.user.config, config_okHandler);
		}
		
		private function config_okHandler(e:Event):void 
		{
			ExplorerConfigWindow(e.currentTarget).setConfigData(Document.user.config);
		}
		
		private function folder_closeHandler(e:MouseEvent):void 
		{
			win.folder.close(true);
			win.folder.open();
		}
		
		private function folder_openHandler(e:MouseEvent):void 
		{
			win.folder.open(true);
		}
		
		private function copy_clickHandler(e:MouseEvent):void 
		{
			Modal.confirm("プレビュー中のTFPの全ファイルパスをクリップボードへコピーしますか？", copy_okHandler);
		}
		
		private function copy_okHandler():void 
		{
			if (!files) return;
			var list:Array = [];
			for each(var f:TFPFile in files)
			{
				list.push('"' + f.path + '"');
			}
			var str:String = "var pathList:Vector.<String> = Vector.<String>([" + list.join(",") + "])";
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, str);
			Modal.alert("クリップボードにコピーしました。");
		}
		
		override protected function updateLayout():void 
		{
			message.x = (win.width - message.width) / 2 | 0;
			message.y = 20 + (win.height - message.height) / 2 | 0;
			message.visible = !dropped  && win.height > 70;
		}
		
		private function onTimesUp():void 
		{
			message.alpha = 1;
		}
		
		private function tree_clickHandler(e:TreeLimbEvent):void 
		{
			var f:* = e.targetLimb.extra;
			if (f is TFPFile)
			{
				Document.canvas.viewer.preview(f);
			}
			if (f is TFPFolder) info.text = TFPFolder(f).path;
		}
		
		private function tree_wclickHandler(e:TreeLimbEvent):void 
		{
			var f:* = e.targetLimb.extra;
			if (f is TFPFile) Document.canvas.viewer.exe(f);
		}
		
		/**
		 * ビューワー領域に結合データをドロップした時
		 * @param	clip
		 */
		private function file_dropHandler(clip:ClipData):void 
		{
			showFile(clip.fileList[0]);
		}
		
		public function showFile(f:File):void
		{
			currentFile = f;
			updateIcons();
			dropped = true;
			panel.enabled = true;
			var data:ByteArray = LocalFile.readByteArray(f);
			if (!data)
			{
				Modal.alert("このファイルはプレビューできません。");
				return;
			}
			
			time = getTimer();
			
			var extension:TFPExtention = TFPLoader.extension;
			extension.image = Document.user.config.imageExp;
			extension.sound = Document.user.config.soundExp;
			extension.text = Document.user.config.textExp;
			extension.xml = Document.user.config.xmlExp;
			
			var loader:TFPParser = new TFPParser();
			loader.addEventListener(Event.COMPLETE, loader_completeHandler);
			loader.addEventListener(IOErrorEvent.IO_ERROR, loader_errorHandler);
			loader.parse(data, true);
		}
		
		private function removeEvents(loader:TFPParser):void
		{
			loader.removeEventListener(Event.COMPLETE, loader_completeHandler);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, loader_errorHandler);
		}
		
		private function loader_errorHandler(e:IOErrorEvent):void 
		{
			removeEvents(e.currentTarget as TFPParser);
			Modal.alert("このファイルはプレビューできません。");
		}
		
		private function loader_completeHandler(e:Event):void 
		{
			var loader:TFPParser = e.currentTarget as TFPParser;
			files = loader.files;
			removeEvents(e.currentTarget as TFPParser);
			var time:String = " (" + (getTimer() - time) + "ms)";
			new FolderImporter().importLibrary(win.folder, loader.root);
			for each(var limb:TreeLimb in win.folder.getChildLimbs(true, false))
			{
				if (limb.isFolder) continue;
				var menu:AirMenu = new AirMenu();
				var tfile:TFPFile = limb.extra as TFPFile;
				var path:String = tfile.path;
				menu.addMenuItem(path, "").enabled = false;
				menu.addMenuItem("パスをクリップボードにコピー", "", null, copyPath, [path]);
				limb.contextMenu = menu;
			}
			message.visible = false;
		}
		
		private function copyPath(path:String):void 
		{
			System.setClipboard(path);
		}
		
	}

}