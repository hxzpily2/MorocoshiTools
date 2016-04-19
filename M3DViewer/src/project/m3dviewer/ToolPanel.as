package project.m3dviewer 
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.HBox;
	import flash.display.BitmapData;
	import flash.display.PNGEncoderOptions;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filters.GlowFilter;
	import net.morocoshi.air.files.FileUtil;
	import net.morocoshi.air.files.LocalFile;
	import net.morocoshi.common.graphics.Create;
	import net.morocoshi.common.graphics.Palette;
	import net.morocoshi.common.timers.Stopwatch;
	import net.morocoshi.components.balloon.MouseOverLabel;
	import net.morocoshi.components.minimal.Bit101Util;
	import net.morocoshi.components.minimal.BitmapCheckBox;
	import net.morocoshi.components.minimal.buttons.BitmapButton;
	import net.morocoshi.components.minimal.color.ColorSelector;
	import net.morocoshi.moja3d.animation.AnimationPlayer;
	import net.morocoshi.moja3d.resources.TextureResource;
	
	/**
	 * ツールメニュー
	 * 
	 * @author tencho
	 */
	public class ToolPanel 
	{
		public var container:Sprite;
		
		private var isPlaying:Boolean;
		private var background:Sprite;
		private var currentData:ModelData;
		private var currentPlayer:AnimationPlayer;
		private var timer:Stopwatch;
		
		private var playerBox:HBox;
		private var treeIcon:BitmapButton;
		private var lightIcon:BitmapCheckBox;
		private var playIcon:BitmapCheckBox;
		private var loopIcon:BitmapCheckBox;
		private var folderIcon:BitmapButton;
		private var gridIcon:BitmapCheckBox;
		private var cameraComboBox:ComboBox;
		private var resizeIcon:BitmapButton;
		private var colorSelector:ColorSelector;
		private var stopIcon:BitmapButton;
		private var captureIcon:BitmapButton;
		
		public function ToolPanel() 
		{
			isPlaying = false;
			timer = new Stopwatch();
			container = new Sprite();
			container.visible = false;
			background = Create.box(0, 0, 10, 10, 0x111111, 1);
			container.addChild(background);
			
			var box:HBox = new HBox(container, 14, 14);
			box.spacing = 14;
			
			folderIcon = new BitmapButton(box, 0, 0, new Asset.Folder, null, null, folder_clickHandler);
			treeIcon = new BitmapButton(box, 0, 0, new Asset.Tree, null, null, tree_clickHandler);
			lightIcon = new BitmapCheckBox(box, 0, 0, new Asset.Cube4, new Asset.Cube2, light_clickHandler);
			gridIcon = new BitmapCheckBox(box, 0, 0, Asset.image(Asset.Grid, 0.3), new Asset.Grid, grid_clickHandler);
			resizeIcon = new BitmapButton(box, 0, 0, new Asset.Image, null, null, resize_clickHandler);
			captureIcon = new BitmapButton(box, 0, 0, new Asset.Capture, null, null, capture_clickHandler);
			
			cameraComboBox = new ComboBox(box, 0, 0, "カメラ選択", []);
			cameraComboBox.width = 140;
			cameraComboBox.height = 24;
			cameraComboBox.addEventListener(Event.SELECT, camera_selectHandler);
			cameraComboBox.addItem( { label:"回転モード", camera:null, mode:CameraMode.ROTATE } );
			cameraComboBox.addItem( { label:"飛行モード", camera:null, mode:CameraMode.FLY } );
			Bit101Util.adjustComboList(cameraComboBox, 10, true);
			
			playerBox = new HBox(box);
			playerBox.spacing = 14;
			playIcon = new BitmapCheckBox(playerBox, 0, 0, new Asset.Play, new Asset.Pause, play_clickHandler);
			stopIcon = new BitmapButton(playerBox, 0, 0, new Asset.Stop, null, null, stop_clickHandler);
			loopIcon = new BitmapCheckBox(playerBox, 0, 0, Asset.image(Asset.Loop, 0.3), new Asset.Loop, loop_clickHandler);
			colorSelector = new ColorSelector(box, 0, 5, 0x303030, color_selectHadnler);
			colorSelector.filters = [new GlowFilter(0xcccccc, 1, 2, 2, 100)];
			
			for each(var bb:BitmapButton in BitmapButton.getAllBitmapButton(container))
			{
				bb.setSize(24, 24);
				bb.transform.colorTransform = Palette.getFillColor(0xffffff, 1);
				bb.normalColor = Palette.getFillColor(0xffffff, 1);
				bb.overColor = Palette.getFillColor(0xccddee, 1);
				bb.downColor = Palette.getFillColor(0x458A9B, 1);
			}
			
			playerBox.enabled = false;
			folderIcon.enabled = false;
			
			MouseOverLabel.instance.setLabel(folderIcon, "ファイルの場所を開く");
			MouseOverLabel.instance.setLabel(treeIcon, "モデルの階層構造");
			MouseOverLabel.instance.setLabel(lightIcon, "陰影切替");
			MouseOverLabel.instance.setLabel(gridIcon, "グリッドの表示");
			MouseOverLabel.instance.setLabel(resizeIcon, "リソース画像書出");
			MouseOverLabel.instance.setLabel(loopIcon, "ループ");
			MouseOverLabel.instance.setLabel(playIcon, "再生/一時停止");
			MouseOverLabel.instance.setLabel(stopIcon, "停止");
			MouseOverLabel.instance.setLabel(colorSelector, "背景色");
		}
		
		private function capture_clickHandler(e:Event):void 
		{
			var grid:Boolean = Main.current.view.gridVisible;
			Main.current.view.gridVisible = false;
			var bmd:BitmapData = Main.current.view.scene.capture(true, false, false);
			var id:String = FileUtil.getNumberingName(File.desktopDirectory, "capture");
			var file:File = File.desktopDirectory.resolvePath(id + ".png");
			LocalFile.writeByteArray(file, bmd.encode(bmd.rect, new PNGEncoderOptions(false)), false);
			Main.current.view.gridVisible = grid;
		}
		
		private function color_selectHadnler(e:Event):void 
		{
			Main.current.view.scene.view.backgroundColor = colorSelector.value;
		}
		
		private function resize_clickHandler(e:Event):void 
		{
			if (currentData == null) return;
			
			new MaterialEditor(Main.current.stage.nativeWindow).open(currentData.file, Main.current.view.scene.root.getResources(true, TextureResource), Main.current.view.scene.context3D);
		}
		
		public function init():void 
		{
			container.visible = true;
			lightIcon.selected = true;
			loopIcon.selected = true;
			gridIcon.selected = true;
			resizeIcon.enabled = false;
			cameraComboBox.selectedIndex = 0;
		}
		
		public function setSize(w:Number, h:Number):void
		{
			background.width = w;
			background.height = h;
		}
		
		public function setModelData(modelData:ModelData):void 
		{
			currentData = modelData;
			currentPlayer = modelData.parser.animationPlayer;
			currentPlayer.interpolationEnabled = false;
			folderIcon.enabled = true;
			resizeIcon.enabled = true;
			playerBox.enabled = (currentPlayer && currentPlayer.keyAnimations.length > 0);
			stop();
			playIcon.selected = false;
			if (currentPlayer)
			{
				playIcon.selected = true;
				play();
			}
		}
		
		public function stop():void 
		{
			playIcon.selected = false;
			pause();
			timer.reset();
			tick();
		}
		
		public function pause():void
		{
			if (currentPlayer == null) return;
			
			isPlaying = false;
			timer.stop();
			container.removeEventListener(Event.ENTER_FRAME, tick);
			tick();
		}
		
		public function play():void 
		{
			if (currentPlayer == null) return;
			
			isPlaying = true;
			var time:Number = timer.time / 1000;
			if (time >= currentPlayer.timeLength)
			{
				timer.reset();
			}
			timer.start();
			container.addEventListener(Event.ENTER_FRAME, tick);
		}
		
		private function tick(e:Event = null):void 
		{
			if (currentPlayer)
			{
				var time:Number = timer.time / 1000;
				if (loopIcon.selected)
				{
					if (time > currentPlayer.timeLength)
					{
						timer.time = (time % currentPlayer.timeLength) * 1000;
						time = timer.time / 1000;
					}
				}
				else
				{
					if (time > currentPlayer.timeLength && isPlaying)
					{
						playIcon.selected = false;
						pause();
					}
				}
				currentPlayer.setTime(time + currentPlayer.startTime);
			}
		}
		
		private function stop_clickHandler(e:Event):void 
		{
			stop();
		}
		
		private function loop_clickHandler(e:Event):void 
		{
			if (currentPlayer)
			{
				currentPlayer.loop = loopIcon.selected;
			}
		}
		
		private function grid_clickHandler(e:Event):void 
		{
			Main.current.view.gridVisible = gridIcon.selected;
		}
		
		private function camera_selectHandler(e:Event):void 
		{
			var data:Object = cameraComboBox.selectedItem;
			Main.current.view.setCamera(data.camera, data.mode);
		}
		
		private function play_clickHandler(e:Event):void 
		{
			playIcon.selected? play() : pause();
		}
		
		private function light_clickHandler(e:Event):void 
		{
			Main.current.view.lightEnabled = lightIcon.selected;
		}
		
		private function folder_clickHandler(e:Event):void 
		{
			if (currentData && currentData.file)
			{
				currentData.file.parent.openWithDefaultApplication();
			}
		}
		
		private function tree_clickHandler(e:Event):void 
		{
			var win:TreeWindow = new TreeWindow();
			win.setObject3DTree(Main.current.view.scene.root);
			win.activate();
		}
		
	}

}