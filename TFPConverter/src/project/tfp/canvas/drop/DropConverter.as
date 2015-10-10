package project.tfp.canvas.drop 
{
	import com.bit101.components.Panel;
	import flash.filesystem.File;
	import net.morocoshi.air.components.minimal.MessageDialog;
	import net.morocoshi.air.components.minimal.Modal;
	import net.morocoshi.air.drop.DragDrop;
	import net.morocoshi.air.files.ClipData;
	import net.morocoshi.air.files.FileUtil;
	import net.morocoshi.components.minimal.text.TextLabel;
	import project.tfp.converter.AssetConverter;
	import project.tfp.Document;
	
	/**
	 * 簡易TFP化ツール
	 * 
	 * @author tencho
	 */
	public class DropConverter extends Panel
	{
		private var tfpLabel:String = "ここにフォルダをドロップすると\nすぐにTFP化します。";
		private var label:TextLabel;
		private var dropedList:Vector.<File>;
		private var fileStock:Vector.<File>;
		private var compressMode:Boolean;
		private var isConverting:Boolean;
		
		public function DropConverter() 
		{
			super(null);
			
			dropedList = new Vector.<File>;
			fileStock = new Vector.<File>;
			label = new TextLabel(this, 0, 0, tfpLabel);
			var dd:DragDrop = new DragDrop();
			dd.allowFolder = true;
			dd.onDragDrop = tfp_dropHandler;
			dd.addDropTarget(this);
		}
		
		private function tfp_dropHandler(clip:ClipData):void 
		{
			if (checkConfrict()) return;
			
			dropedList.length = 0;
			
			for each(var file:File in clip.fileList)
			{
				if (!file.isDirectory) continue;
				
				dropedList.push(file);
			}
			if (!dropedList.length) return;
			
			var text:String = dropedList.length + "個のフォルダがドロップされました。これらのフォルダをTFP化しますか？";
			text += "\n※TFPはフォルダと同じ階層に保存されます。";
			text += "\n※同名ファイルがある場合は上書きされます。";
			Modal.detail(text, ["圧縮してTFP化", "圧縮せずTFP化", "キャンセル"], [], confirm_clickHandler, null, true, 110);
		}
		
		private function checkConfrict():Boolean 
		{
			if (isConverting)
			{
				Modal.alert("現在TFP化中です。しばらくお待ちください。");
				return true;
			}
			return false;
		}
		
		private function confirm_clickHandler(index:int):void 
		{
			if (index == 2 || checkConfrict()) return;
			
			isConverting = true;
			fileStock = dropedList.concat();
			compressMode = (index == 0);
			
			convertNext();
		}
		
		private function convertNext():void 
		{
			if (!fileStock.length)
			{
				Modal.alert("全ての処理が完了しました。");
				label.text = tfpLabel;
				isConverting = false;
				return;
			}
			
			var file:File = fileStock.pop();
			var id:String = FileUtil.getNumberingName(File.desktopDirectory, file.name);
			var output:File = file.parent.resolvePath(FileUtil.getFileID(file.name) + ".tfp");
			
			var converter :AssetConverter = new AssetConverter();
			converter.onError = converter_errorHandler;
			converter.onComplete = convert_completeHandler;
			converter.onProgress = converter_progressHandler;
			converter.convert(file, output, Document.project.assetList.setting.ignoreExtension, compressMode);
		}
		
		private function convert_completeHandler(rate:Number):void 
		{
			convertNext();
		}
		
		private function converter_progressHandler(per:Number):void 
		{
			label.text = "(残り" + fileStock.length + "個) " + int(per * 100) + "%";
		}
		
		private function converter_errorHandler(text:String):void 
		{
			new MessageDialog().open(text);
			label.text = tfpLabel;
			isConverting = false;
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			super.setSize(w, h);
			if (label)
			{
				label.x = (w - label.width) * 0.5;
				label.y = (h - label.height) * 0.5;
			}
		}
		
	}

}