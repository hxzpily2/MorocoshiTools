package project.tfp.canvas.setting 
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.Component;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.bit101.components.VBox;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import net.morocoshi.air.components.minimal.Modal;
	import net.morocoshi.common.text.TextUtil;
	import net.morocoshi.components.minimal.layout.HContainer;
	import project.tfp.data.AssetSetting;
	import project.tfp.Document;
	
	/**
	 * TFP書き出し設定
	 * 
	 * @author tencho
	 */
	public class SettingCell extends Panel 
	{
		
		private var box:VBox;
		private var ignoreText:InputText;
		private var autoOutputPath:CheckBox;
		private var useCompressThreshold:CheckBox;
		private var compressThreshold:InputText;
		private var compressContainer:HContainer;
		private var setting:AssetSetting;
		
		public function SettingCell(parent:DisplayObjectContainer=null, xpos:Number=0, ypos:Number=0) 
		{
			super(parent, xpos, ypos);
			
			box = new VBox(this, 15, 15);
			box.spacing = 2;
			autoOutputPath = new CheckBox(box, 0, 0, "TFPの書き出し先をアセットフォルダと同じ階層にする", param_changeHandler);
			useCompressThreshold = new CheckBox(null, 0, 4, "", param_changeHandler);
			new Component(box).height = 3;
			compressThreshold = new InputText(null, 0, 2, "", param_changeHandler);
			compressThreshold.width = 50;
			compressContainer = new HContainer(null, 0, 0, [l("圧縮率が"), compressThreshold, l("%以下になるフォルダのみ圧縮する")], 0);
			new HContainer(box, 0, 0, [useCompressThreshold, compressContainer, s(5), b("？", 25, help_clickHandler)], 0);
			new Component(box).height = 3;
			var label:Label = new Label(box, -2, 0, "書き出さない拡張子リスト(「,」区切り)");
			ignoreText = new InputText(box, 0, 0, "", param_changeHandler);
			ignoreText.setSize(250, 24);
			update();
		}
		
		public function setSetting(setting:AssetSetting):void
		{
			this.setting = setting;
			ignoreText.text = setting.ignoreExtension.join(",");
			autoOutputPath.selected = setting.autoOutputPath;
			compressThreshold.text = String(setting.compressThreshold);
			useCompressThreshold.selected = setting.useCompressThreshold;
			update();
		}
		
		private function help_clickHandler(e:Event):void 
		{
			var xml:XML = <data>
			ここにチェックを入れると圧縮するかどうかが自動で判別されるようになり、
			ここで設定した圧縮率以下になるフォルダのみ圧縮されるようになります。
			
			「圧縮率とは」
			圧縮時に元のデータから何％のデータになったかを表す数値です。
			この値が高いほどあまり圧縮できないデータで
			この値が低いほどよく圧縮できるデータという事になります。
			JPG、PNGなどの既に圧縮されているデータはあまり圧縮できず、
			テキストデータなどはよく圧縮できる傾向にあります。
			</data>;
			Modal.alert(TextUtil.fixNewline(String(xml)).replace(/\t/g, ""));
		}
		
		private function param_changeHandler(e:Event):void 
		{
			if (!setting) return;
			
			setting.autoOutputPath = autoOutputPath.selected;
			setting.useCompressThreshold = useCompressThreshold.selected;
			setting.compressThreshold = Number(compressThreshold.text) || 0;
			setting.ignoreExtension = ignoreText.text.split(",");
			Document.canvas.grid.applySetting(setting);
			update();
		}
		
		private function update(e:Event = null):void 
		{
			compressContainer.enabled = useCompressThreshold.selected;
		}
		
		private function l(text:String):Label 
		{
			return new Label(null, 0, 0, text);
		}
		
		private function s(size:Number):Component 
		{
			var c:Component = new Component();
			c.width = size;
			return c;
		}
		
		private function b(label:String, size:Number, click:Function):PushButton
		{
			var button:PushButton = new PushButton(null, 0, 0, label, click);
			button.width = size;
			return button;
		}
		
	}

}