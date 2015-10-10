package project.tfp.tools 
{
	import com.bit101.components.TextArea;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.Stage;
	import flash.events.Event;
	import net.morocoshi.air.windows.WindowUtil;
	
	/**
	 * サンプルコードを表示するウィンドウ（今は使ってない）
	 * 
	 * @author tencho
	 */
	public class SampleWindow 
	{
		private var win:NativeWindow;
		private var text:TextArea;
		
		public function SampleWindow() 
		{
		}
		
		public function open():void
		{
			var option:NativeWindowInitOptions = WindowUtil.createOption(null, true, false, true);
			win = new NativeWindow(option);
			win.title = "サンプルコード";
			win.stage.scaleMode = "noScale";
			win.stage.align = "TL";
			win.stage.addEventListener(Event.RESIZE, resizeHandler);
			text = new TextArea(win.stage, 0, 0, "");
			resizeHandler();
		}
		
		private function resizeHandler(e:Event = null):void 
		{
			var stage:Stage = win.stage;
			text.setSize(stage.stageWidth, stage.stageHeight);
		}
		
	}

}