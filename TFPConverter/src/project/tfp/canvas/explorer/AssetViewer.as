package project.tfp.canvas.explorer 
{
	import com.bit101.components.Panel;
	import com.bit101.components.TextArea;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import net.morocoshi.common.loaders.tfp.TFPFile;
	import net.morocoshi.components.minimal.BitmapClip;
	import project.tfp.file.Asset;
	
	/**
	 * TFPデータプレビュー画面
	 * 
	 * @author tencho
	 */
	public class AssetViewer extends Panel
	{
		private var imageCanvas:BitmapClip;
		private var soundIcon1:BitmapClip;
		private var soundIcon2:BitmapClip;
		private var text:TextArea
		private var isInit:Boolean = false;
		private var sound:SoundChannel;
		private var currentFile:TFPFile;
		
		public function AssetViewer() 
		{
			super();
			imageCanvas = new BitmapClip(this, 0, 0, null, true);
			soundIcon1 = new BitmapClip(this, 0, 0, Asset.icons[12], false);
			soundIcon2 = new BitmapClip(this, 0, 0, Asset.icons[11], false);
			soundIcon1.setSize(32, 32);
			soundIcon2.setSize(32, 32);
			soundIcon1.addEventListener(MouseEvent.CLICK, sound_playHandler);
			soundIcon2.addEventListener(MouseEvent.CLICK, sound_stopHandler);
			soundIcon1.buttonMode = true;
			soundIcon2.buttonMode = true;
			soundIcon1.visible = false;
			soundIcon2.visible = false;
			text = new TextArea(this, 0, 0);
			text.visible = false;
			isInit = true;
			updateSize();
		}
		
		private function sound_stopHandler(e:MouseEvent = null):void 
		{
			if (sound) sound.stop();
		}
		
		private function sound_playHandler(e:MouseEvent = null):void 
		{
			if (sound) sound.stop();
			sound = Sound(currentFile.asset).play(0, 1);
		}
		
		public function exe(file:TFPFile):void
		{
			if (file.error || !file.asset) return;
			currentFile = file;
			if (file.asset is Sound)
			{
				sound_playHandler();
				return;
			}
		}
		
		public function preview(file:TFPFile):void
		{
			if (file.error || !file.asset)
			{
				return;
			}
			currentFile = file;
			text.text = "";
			imageCanvas.visible = file.asset is BitmapData;
			soundIcon1.visible = file.asset is Sound;
			soundIcon2.visible = file.asset is Sound;
			text.visible = file.asset is String || file.asset is XML;
			if (file.asset is BitmapData)
			{
				imageCanvas.bitmapData = file.asset;
				return;
			}
			if (file.asset is String || file.asset is XML)
			{
				var str:String = String(file.asset);
				if (str.length > 3000)
				{
					str = str.substr(0, 3000) + "\n\n（以下省略）";
				}
				text.text = str;
			}
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			super.setSize(w, h);
			updateSize();
		}
		
		override public function set height(value:Number):void 
		{
			super.height = value;
			updateSize();
		}
		
		override public function set width(value:Number):void 
		{
			super.width = value;
			updateSize();
		}
		
		private function updateSize():void 
		{
			if (!isInit) return;
			soundIcon1.x = (_width - soundIcon1.width) / 2 - 16 | 0;
			soundIcon2.x = (_width - soundIcon2.width) / 2 + 16 | 0;
			soundIcon1.y = (_height - soundIcon1.height) / 2 | 0;
			soundIcon2.y = (_height - soundIcon2.height) / 2 | 0;
			imageCanvas.setSize(_width, _height);
			text.setSize(_width, _height);
		}
		
	}

}