package project.tfp
{
	import com.bit101.components.Style;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.filesystem.File;
	import net.morocoshi.air.drop.DragDrop;
	import net.morocoshi.air.files.ClipData;
	import net.morocoshi.air.files.FileUtil;
	import net.morocoshi.air.files.LocalFile;
	import net.morocoshi.common.text.TextUtil;
	import net.morocoshi.components.balloon.MouseOverLabel;
	import project.tfp.canvas.MainCanvas;
	import project.tfp.data.ProjectData;
	import project.tfp.data.UserFile;
	import project.tfp.file.Asset;
	import project.tfp.menu.AppMenu;
	
	/**
	 * ファイル結合ツールのドキュメントクラス
	 * 
	 * @author tencho
	 */
	[SWF(width="800", height="650", backgroundColor="0xffffff", frameRate="30")] 
	public class Document extends Sprite 
	{
		public static var sprite:Sprite;
		public static var display:Stage;
		public static var user:UserFile;
		public static var canvas:MainCanvas;
		public static var project:ProjectData;
		public static var window:NativeWindow;
		
		/**
		 * コンストラクタ
		 */
		public function Document():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			window = stage.nativeWindow;
			
			sprite = this;
			display = stage;
			stage.scaleMode = "noScale";
			stage.align = "TL";
			Asset.create();
			
			setWindowTitle("");
			
			user = new UserFile();
			user.onBeforeSave = user_savingHandler;
			user.init(display.nativeWindow, true, true, true);
			user.load();
			
			Style.embedFonts = false;
			Style.fontSize = 12;
			Style.fontName = "Arial";
			Style.LABEL_TEXT = 0;
			Style.BACKGROUND = 0x666666;
			Style.INPUT_TEXT = 0xFFFFFF;
			Style.PANEL = 0xF8F8F8;
			
			canvas = new MainCanvas();
			canvas.init();
			
			project = new ProjectData(canvas.grid);
			project.newFile(true);
			
			addChild(canvas.sprite);
			addChild(MouseOverLabel.instance.container);
			
			var dd:DragDrop = new DragDrop();
			dd.allowExtensions = ["tfproj", "txt"];
			dd.allowFile = true;
			dd.allowFolder = true;
			dd.onDragDrop = dropHandler;
			dd.addDropTarget(canvas.grid);
			
			window.menu = new AppMenu();
			window.addEventListener(Event.CLOSING, window_closingHandler);
			
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, invokeHandler); 
		}
		
		private function window_closingHandler(e:Event):void 
		{
			e.preventDefault();
			project.tryExit();
		}
		
		/**
		 * リストエリアにファイルをドロップした時
		 * @param	clip
		 */
		private function dropHandler(clip:ClipData):void 
		{
			if (!clip.fileList.length) return;
			
			var file:File = clip.fileList[0];
			if (file.isDirectory)
			{
				canvas.grid.dropDirectories(clip);
				return;
			}
			if (file.extension.toLowerCase() == "tfproj")
			{
				project.loadFile(file, false);
				canvas.show(MainCanvas.TAB_GRID);
				return;
			}
			if (file.extension.toLowerCase() == "txt")
			{
				var txt:String = LocalFile.readUTFBytes(file);
				TextUtil.fixNewline(txt);
				var pathList:Array = txt.split("\n");
				canvas.grid.dropFilePathList(pathList);
			}
			
		}
		
		/**
		 * コマンドライン引数を受け取った
		 * @param	e
		 */
		static private function invokeHandler(e:InvokeEvent):void 
		{
			if (!e.arguments.length) return;
			
			var path:String = e.arguments[0];
			var file:File = FileUtil.toFile(path);
			if (!file) return;
			
			var ext:String = file.extension.toLowerCase();
			if (ext == "tfproj")
			{
				project.loadFile(file, false);
				Document.canvas.show(MainCanvas.TAB_GRID);
			}
			else
			{
				canvas.explorer.showFile(file);
				canvas.show(MainCanvas.TAB_PREVIEW);
			}
		}
		
		static public function setWindowTitle(title:String):void 
		{
			window.title = Asset.application.getTitleAndVersion() + " - " + title;
		}
		
		/**
		 * 自動保存直前の処理
		 */
		static private function user_savingHandler():void 
		{
		}
		
		
		
	}
	
}