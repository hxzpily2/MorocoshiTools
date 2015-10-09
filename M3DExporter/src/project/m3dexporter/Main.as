package project.m3dexporter
{
	import com.bit101.components.ProgressBar;
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.InvokeEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import net.morocoshi.air.application.ApplicationData;
	import net.morocoshi.air.components.minimal.Modal;
	import net.morocoshi.air.files.FileUtil;
	import net.morocoshi.air.files.LocalFile;
	import net.morocoshi.common.timers.FrameTimer;
	import net.morocoshi.components.balloon.MouseOverLabel;
	import net.morocoshi.components.minimal.layout.LayoutCell;
	import net.morocoshi.components.minimal.layout.LayoutData;
	import net.morocoshi.components.minimal.style.Coloration;
	import net.morocoshi.moja3d.loader.exporters.M3DExportOption;
	import project.m3dexporter.data.UserFile;
	import project.m3dexporter.Settings;
	import project.m3dexporter.viewer.View;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Main extends Sprite 
	{
		public var user:UserFile;
		public var menu:AppMenu;
		public var converter:Converter;
		public var tracer:Tracer;
		public var view:View;
		public var setting:Settings;
		public var rootCell:LayoutCell;
		public var progressBar:ProgressBar;
		public var fileSelector:FileSelector;
		
		private var currentFile:File;
		private var outputFile:File;
		private var isConverting:Boolean;
		
		static public var current:Main;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function Main():void 
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
			
			stage.align = "TL";
			stage.scaleMode = "noScale";
			
			stage.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, globalErrorHandlere);
			Coloration.setStyle(Coloration.STYLE_LIGHT);
			
			var app:ApplicationData = new ApplicationData();
			stage.nativeWindow.title = app.name + " " + app.version;
			
			user = new UserFile();
			user.onBeforeSave = savingCallback;
			user.init(stage.nativeWindow);
			user.load();
			
			converter = new Converter();
			view = new View();
			setting = new Settings();
			tracer = new Tracer();
			fileSelector = new FileSelector();
			progressBar = new ProgressBar();
			
			rootCell = new LayoutCell(this, 0, 0, LayoutCell.ALIGN_RIGHT, false);
			
			var convert:LayoutCell = new LayoutCell(null, 0, 0, LayoutCell.ALIGN_TOP, false);
			convert.addCell(progressBar, "10px", LayoutData.PIXEL);
			convert.addCell(fileSelector, "145px");
			convert.addCell(tracer, "*");
			
			var right:LayoutCell = new LayoutCell(null, 0, 0, LayoutCell.ALIGN_TOP);
			right.addCell(convert, "300px");
			right.addCell(view);
			
			rootCell.addCell(setting, "270px", LayoutData.PIXEL);
			rootCell.addCell(right);
			
			view.onLog = tracer.log;
			view.build(stage, scene_completeHandler);
			
			converter.onComplete = f3d_completeHandler;
			converter.onProgress = progressHandler;
			converter.onLog = tracer.log;
			
			setting.load(user);
			fileSelector.onConvert = confirmConvert;
			//fileSelector.onReloadF3D = onReloadF3D;
			
			view.setConvertedFiles(user.convertedFiles);
			
			fileSelector.loadUserData(user);
			
			menu = new AppMenu();
			menu.init(user);
			stage.nativeWindow.menu = menu.menu;
			
			stage.addChild(MouseOverLabel.instance.container);
			stage.addEventListener(Event.RESIZE, resizeHandler);
			resizeHandler();
			
			FrameTimer.setTimer(3, aciveate);
		}
		
		private function aciveate():void 
		{
			stage.nativeWindow.activate();
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, invokeHandler);
		}
		
		/**
		 * なんかうまくいかない
		 * @param	e
		 */
		private function globalErrorHandlere(e:UncaughtErrorEvent):void 
		{
			tracer.log(e);
			tracer.log(e.text);
			e.preventDefault();
		}
		
		//--------------------------------------------------------------------------
		//
		//  内部処理
		//
		//--------------------------------------------------------------------------
		
		private function f3d_completeHandler(ba:ByteArray):void 
		{
			LocalFile.writeByteArray(outputFile, ba, true);
			tracer.log(outputFile.nativePath + "に保存しました。");
			view.setF3DByteArray(outputFile, fileSelector.materialPath, false);
			
			user.addConvertedFile(FileUtil.url(outputFile));
			view.setConvertedFiles(user.convertedFiles);
			
			fileSelector.enabled = true;
			isConverting = false;
		}
		
		private function progressHandler(per:Number):void 
		{
			progressBar.value = per;
		}
		
		private function scene_completeHandler():void 
		{
			//fpv.setCameraMatrix(user.cameraMatrix);
		}
		
		/**
		 * 必要なら変換していいかどうかチェックする
		 */
		private function confirmConvert():void 
		{
			if (isConverting) return;
			
			currentFile = FileUtil.toFile(fileSelector.filePath);
			outputFile = FileUtil.changeExtension(currentFile, "m3d");
			
			if (user.menuOption.checkOverride && outputFile.exists)
			{
				isConverting = true;
				Modal.confirm(outputFile.nativePath + "は既に存在しています。\n　上書きしますか？", convert, convert_cancelHandler);
				return;
			}
			convert();
		}
		
		private function convert_cancelHandler():void
		{
			isConverting = false;
			fileSelector.enabled = true;
		}
		
		/**
		 * 事前に設定しておいたcurrentFileを変換する
		 */
		private function convert():void
		{
			isConverting = true;
			fileSelector.enabled = false;
			
			tracer.clear();
			var option:M3DExportOption = setting.getOption();
			
			if (option.exportTangent4 && (!option.exportUV || !option.exportNormal))
			{
				Modal.alert("接線＆従法線を書き出す場合は、UVと頂点法線も書き出してください。");
				return;
			}
			
			fileSelector.applyOption(option);
			var materialDir:File = currentFile.parent.resolvePath(fileSelector.materialPath);
			converter.convert(currentFile, option, materialDir);
		}
		
		/**
		 * 終了直前に実行される
		 */
		private function savingCallback():void 
		{
			//保存データ
			setting.save(user);
			user.fbxPath = fileSelector.filePath;
			user.materialPath = fileSelector.materialPath;
			user.cameraMatrix = view.scene.camera.matrix.clone();
			fileSelector.applyOption(user.option);
		}
		
		/**
		 * 関連付けたファイルを実行した時
		 * @param	e
		 */
		private function invokeHandler(e:InvokeEvent):void 
		{
			if (!e.arguments.length) return;
			
			var file:File = FileUtil.toFile(e.arguments[0]);
			if (file == null) return;
			
			var ext:String = file.extension? file.extension.toLowerCase() : "";
			
			if (ext == "m3d")
			{
				view.setF3DByteArray(file, "", true);
			}
			
			if (ext == "fbx" || ext == "dae")
			{
				fileSelector.filePath = FileUtil.url(file);
				stage.nativeWindow.activate();
				
				//自動でパースする場合
				if (user.menuOption.autoParse)
				{
					confirmConvert();
				}
			}
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