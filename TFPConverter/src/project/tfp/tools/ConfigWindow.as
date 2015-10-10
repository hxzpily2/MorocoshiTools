package project.tfp.tools 
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.Component;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.VBox;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import net.morocoshi.air.windows.ModalManager;
	import net.morocoshi.air.windows.PlainWindow;
	import net.morocoshi.air.windows.WindowUtil;
	import net.morocoshi.components.minimal.buttons.ButtonHList;
	import net.morocoshi.components.minimal.buttons.ButtonListEvent;
	import project.tfp.data.ConfigData;
	
	/**
	 * 環境設定ウィンドウ
	 * 
	 * @author tencho
	 */
	public class ConfigWindow extends EventDispatcher
	{
		private var win:NativeWindow;
		private var box:VBox;
		private var overwrite:CheckBox;
		private var buttons:ButtonHList;
		private var autoCompress:CheckBox;
		private var extensionText:InputText;
		
		public function ConfigWindow() 
		{
		}
		
		public function open(config:ConfigData, select:Function):void
		{
			var option:NativeWindowInitOptions = WindowUtil.createOption(null, false, false, false);
			win = new PlainWindow().open(null, 400, 180);
			win.title = "環境設定";
			ModalManager.activate(win);
			
			box = new VBox(win.stage, 20, 20);
			overwrite = new CheckBox(box, 0, 0, "TFP書き出し時に上書きを確認する");
			
			new Component(box, 0, 0).height = 3;
			autoCompress = new CheckBox(box, 0, 0, "リストの行を追加する時、デフォルトで圧縮にチェックを入れる");
			
			new Component(box, 0, 0).height = 3;
			
			new Label(box, 0, 0, "TFPファイルの拡張子");
			extensionText = new InputText(box, 0, 0, config.extension);
			extensionText.setSize(100, 25);
			
			overwrite.selected = config.overwrite;
			autoCompress.selected = config.autoCompress;
			
			buttons = new ButtonHList(win.stage, ["OK", "キャンセル"], ["ok", "cancel"], 0, 0, buttons_clickHandler);
			buttons.setButtonSize(75, 25);
			buttons.update();
			buttons.x = (win.stage.stageWidth - buttons.width) / 2 | 0;
			buttons.y = win.stage.stageHeight - buttons.height - 15;
			addEventListener(Event.SELECT, select);
		}
		
		public function setConfigData(config:ConfigData):void
		{
			config.overwrite = overwrite.selected;
			config.autoCompress = autoCompress.selected;
			config.extension = extensionText.text.replace(/\s/g, "");
		}
		
		private function buttons_clickHandler(e:ButtonListEvent):void 
		{
			if (e.id == "ok") dispatchEvent(new Event(Event.SELECT));
			win.close();
		}
		
	}

}