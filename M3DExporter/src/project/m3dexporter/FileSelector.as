package project.m3dexporter 
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.Component;
	import com.bit101.components.HBox;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.VBox;
	import flash.events.Event;
	import net.morocoshi.components.balloon.MouseOverLabel;
	import net.morocoshi.components.minimal.input.InputFile;
	import net.morocoshi.components.minimal.input.InputNumber;
	import net.morocoshi.components.minimal.layout.PaddingBox;
	import net.morocoshi.moja3d.loader.exporters.M3DExportOption;
	import project.m3dexporter.data.UserFile;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FileSelector extends Component 
	{
		public var convertButton:PushButton;
		
		public var onConvert:Function;
		public var onReloadF3D:Function;
		
		private var isReady:Boolean;
		private var outputFile:InputFile;
		private var materialFolder:InputText;
		private var padding:PaddingBox;
		private var exportModel:CheckBox;
		private var exportAnimation:CheckBox;
		private var exportImage:CheckBox;
		private var fixImage:CheckBox;
		private var fixLabel:Label;
		private var fixThreshold:InputNumber;
		private var extensionLabel:Label;
		private var removeDirectory:CheckBox;
		
		public function FileSelector() 
		{
			isReady = false;
			
			super(null);
			
			padding = new PaddingBox(this, 0, 0, null, 10, 10, 10, 10);
			
			var vbox:VBox = new VBox(padding, 0, 0);
			var hbox1:HBox = new HBox(vbox, 0, 0);
			
			exportModel = new CheckBox(hbox1, 0, 5, "モデル");
			exportAnimation = new CheckBox(hbox1, 0, 5, "アニメーション");
			exportImage = new CheckBox(hbox1, 0, 5, "画像", updateEnabled);
			
			fixImage = new CheckBox(hbox1, 0, 5, "透過PNGを調整", updateEnabled);
			fixLabel = new Label(hbox1, 0, 1, "閾値");
			fixThreshold = new InputNumber(hbox1, 0, 0, 0);
			fixThreshold.setSize(35, 20);
			fixThreshold.minValue = 0x00;
			fixThreshold.maxValue = 0xff;
			fixThreshold.step = 1;
			exportModel.selected = true;
			exportAnimation.selected = false;
			exportImage.selected = false;
			fixImage.selected = false;
			
			new Component(vbox).height = 5;
			
			var hbox2:HBox = new HBox(vbox, 0, 0);
			new Label(hbox2, 0, 0, "モデルファイル(FBX,DAE)");
			outputFile = new InputFile(hbox2, 0, 0, InputFile.MODE_FILE_OPEN);
			outputFile.setAllowExtension(["fbx", "dae"]);
			outputFile.setSize(140, 20);
			
			removeDirectory = new CheckBox(vbox, 0, 0, "マテリアルパスのフォルダを削る", updateEnabled);
			
			var hbox3:HBox = new HBox(vbox, 0, 0);
			new Label(hbox3, 0, 0, "マテリアルフォルダ");
			materialFolder = new InputText(hbox3, 0, 0, "../material");
			materialFolder.setSize(140, 20);
			
			convertButton = new PushButton(vbox, 0, 0, "変換", convert_clickHandler);
			convertButton.setSize(100, 30);
			
			isReady = true;
			
			MouseOverLabel.instance.setLabel(fixImage, "diffuseに設定されている透過を含んだPNG画像からopacityマップを分離して、\ndiffuse画像の透過領域のフチの色を引き延ばして黒ずみを軽減します。");
			MouseOverLabel.instance.setLabel(materialFolder, "マテリアル画像が格納されているフォルダを\nモデルファイルからの相対or絶対パスで指定します。");
		}
		
		private function updateEnabled(...args):void 
		{
			fixImage.enabled = exportImage.selected;
			fixLabel.enabled = fixThreshold.enabled = exportImage.selected && fixImage.selected;
			materialFolder.enabled = removeDirectory.selected;
		}
		
		public function get filePath():String 
		{
			return outputFile.value;
		}
		
		public function set filePath(value:String):void 
		{
			outputFile.value = value;
		}
		
		public function get materialPath():String 
		{
			return materialFolder.text;
		}
		
		public function set materialPath(value:String):void 
		{
			materialFolder.text = value;
		}
		
		private function convert_clickHandler(e:Event):void 
		{
			onConvert();
		}
		
		public function loadUserData(user:UserFile):void 
		{
			filePath = user.fbxPath;
			materialPath = user.materialPath;
			var option:M3DExportOption = user.option;
			removeDirectory.selected = option.removeDirectory;
			exportModel.selected = option.exportModel;
			exportAnimation.selected = option.exportAnimation;
			exportImage.selected = option.exportImage;
			fixImage.selected = option.fixImage;
			fixThreshold.value = option.fixImageThreshold;
			updateEnabled();
		}
		
		/**
		 * 
		 * @param	option
		 */
		public function applyOption(option:M3DExportOption):void
		{
			option.removeDirectory = removeDirectory.selected;
			option.exportModel = exportModel.selected;
			option.exportAnimation = exportAnimation.selected;
			option.exportImage = exportImage.selected;
			option.fixImage = fixImage.selected;
			option.fixImageThreshold = fixThreshold.value;
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			if (!isReady) return;
			super.setSize(w, h);
			padding.setSize(w, h);
			var pw:Number = w - 20;
			
			outputFile.width = pw - outputFile.x;
			materialFolder.width = pw - materialFolder.x;
		}
		
	}

}