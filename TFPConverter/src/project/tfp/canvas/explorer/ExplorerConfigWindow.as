package project.tfp.canvas.explorer 
{
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.VBox;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import net.morocoshi.air.components.minimal.Modal;
	import net.morocoshi.air.windows.WindowUtil;
	import net.morocoshi.components.minimal.buttons.ButtonHList;
	import project.tfp.data.ConfigData;
	
	/**
	 * エクスプローラー設定ウィンドウ
	 * 
	 * @author tencho
	 */
	public class ExplorerConfigWindow extends EventDispatcher
	{
		private var win:NativeWindow;
		private var box:VBox;
		private var buttons:ButtonHList;
		private var imageExpText:InputText;
		private var soundExpText:InputText;
		private var textExpText:InputText;
		private var xmlExpText:InputText;
		private var videoExpText:InputText;
		
		public function ExplorerConfigWindow() 
		{
		}
		
		public function open(config:ConfigData, select:Function):void
		{
			var option:NativeWindowInitOptions = WindowUtil.createOption(null, false, false, false);
			var msg:String = "ここでアセット別に拡張子を登録しておくと、\nTFPプレビュー時にデータの確認ができます。";
			win = Modal.confirm(msg, okHandler, null, true, 280, 400);
			win.title = "TFPプレビュー設定";
			
			box = new VBox(win.stage, 20, 65);
			new Label(box, 0, 0, "画像拡張子");
			imageExpText = new InputText(box, 0, 0, config.imageExp.join(","));
			new Label(box, 0, 0, "サウンド拡張子");
			soundExpText = new InputText(box, 0, 0, config.soundExp.join(","));
			new Label(box, 0, 0, "テキスト拡張子");
			textExpText = new InputText(box, 0, 0, config.textExp.join(","));
			new Label(box, 0, 0, "XML拡張子");
			xmlExpText = new InputText(box, 0, 0, config.xmlExp.join(","));
			new Label(box, 0, 0, "ビデオ拡張子").enabled = false;
			videoExpText = new InputText(box, 0, 0, config.videoExp.join(","));
			videoExpText.enabled = false;
			
			var w:Number = win.stage.stageWidth - 40;
			imageExpText.setSize(w, 25);
			soundExpText.setSize(w, 25);
			textExpText.setSize(w, 25);
			xmlExpText.setSize(w, 25);
			videoExpText.setSize(w, 25);
			
			addEventListener(Event.SELECT, select);
		}
		
		private function okHandler():void 
		{
			dispatchEvent(new Event(Event.SELECT));
		}
		
		public function setConfigData(config:ConfigData):void
		{
			config.imageExp = imageExpText.text.replace(/\s/g, "").split(",");
			config.soundExp = soundExpText.text.replace(/\s/g, "").split(",");
			config.textExp = textExpText.text.replace(/\s/g, "").split(",");
			config.xmlExp = xmlExpText.text.replace(/\s/g, "").split(",");
			config.videoExp = videoExpText.text.replace(/\s/g, "").split(",");
		}
		
	}

}