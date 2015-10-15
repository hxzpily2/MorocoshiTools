package project.mp3viewer
{
	import com.bit101.components.Style;
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.StageQuality;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.filesystem.File;
	import net.morocoshi.air.application.ApplicationData;
	import net.morocoshi.air.components.minimal.Modal;
	import net.morocoshi.air.drop.DragDrop;
	import net.morocoshi.air.drop.DropEvent;
	import net.morocoshi.air.files.FileUtil;
	import net.morocoshi.common.graphics.Draw;
	import net.morocoshi.components.minimal.style.Coloration;
	
	/**
	 * M3Dビューア
	 * 
	 * @author tencho
	 */
	public class Main extends Sprite 
	{
		public var background:Sprite;
		public var view:View;
		public var tool:ToolPanel;
		public var user:UserFile;
		public var loader:Loader;
		public var application:ApplicationData;
		public var menu:AppMenu;
		
		static public var current:Main;
		
		public function Main() 
		{
			current = this;
			
			Coloration.setStyle(Coloration.STYLE_LIGHT);
			Style.fontName = "Meiryo";
			Style.fontSize = 11;
			
			stage.scaleMode = "noScale";
			stage.align = "TL";
			stage.quality = StageQuality.BEST;
			stage.frameRate = 60;
			
			background = new Sprite();
			
			user = new UserFile();
			user.init(stage.nativeWindow, true, true, true);
			user.load();
			menu = new AppMenu();
			menu.init(user);
			tool = new ToolPanel();
			loader = new Loader();
			loader.onParse = loader_parseHandler;
			view = new View(stage);
			view.onInit = view_initHandler;
			view.init();
			
			application = new ApplicationData();
			stage.nativeWindow.title = application.getTitleAndVersion();
			stage.nativeWindow.menu = menu.menu;
			
			stage.addChild(background);
			stage.addChild(tool.container);
			stage.addChild(view.scene.stats);
			stage.addEventListener(Event.RESIZE, stage_resizeHandler);
			
			var dd:DragDrop = new DragDrop();
			dd.addEventListener(DropEvent.DRAG_DROP, stage_dropHandler);
			dd.allowFile = true;
			dd.allowExtensions = ["m3d"];
			dd.addDropTarget(stage);
			
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, app_invokeHadnler);
		}
		
		private function app_invokeHadnler(e:InvokeEvent):void 
		{
			if (e.arguments.length == 0) return;
			var path:String = e.arguments[0] as String;
			loadFile(FileUtil.toFile(path));
			
			stage.nativeWindow.alwaysInFront = true;
			stage.nativeWindow.alwaysInFront = false;
		}
		
		private function loader_parseHandler(modelData:ModelData):void 
		{
			var path:String = FileUtil.url(modelData.file);
			stage.nativeWindow.title = application.getTitleAndVersion() + " - " + path + " ( " + modelData.parseTime + "ms )";
			view.setModelData(modelData);
			tool.setModelData(modelData);
		}
		
		private function view_initHandler():void 
		{
			tool.init();
		}
		
		private function stage_dropHandler(e:DropEvent):void 
		{
			if (e.clipData.fileList.length == 0) return;
			
			loadFile(e.clipData.fileList[0]);
		}
		
		public function loadFile(file:File):void
		{
			if (loader.isLoading) return;
			
			var path:String = FileUtil.url(file);
			if (file.exists == false)
			{
				Modal.alert("ファイルが見つかりません！");
				menu.recentMenu.removeFile(path);
				return;
			}
			menu.recentMenu.addFile(path);
			stage.nativeWindow.title = application.getTitleAndVersion() + " - " + path;
			loader.load(file);
		}
		
		private function stage_resizeHandler(e:Event):void 
		{
			var w:int = stage.stageWidth;
			var h:int = stage.stageHeight;
			background.graphics.clear();
			Draw.box(background.graphics, 0, 0, w, h, 0, 0);
			view.setSize(w, h - 52);
			tool.setSize(w, 52);
			tool.container.y = h - 52;
		}
		
	}
	
}