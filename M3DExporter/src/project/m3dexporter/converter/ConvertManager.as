package project.m3dexporter.converter 
{
	import flash.filesystem.File;
	import project.m3dexporter.Main;
	import project.m3dexporter.data.ConvertItem;
	import project.m3dexporter.grid.RowItem;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ConvertManager 
	{
		private var isRunning:Boolean;
		private var rowList:Vector.<RowItem>;
		private var current:RowItem;
		private var converter:Converter;
		
		public function ConvertManager() 
		{
			isRunning = false;
			rowList = new Vector.<RowItem>;
		}
		
		public function addRow(row:RowItem):void
		{
			if (rowList.indexOf(row) != -1) return;
			
			rowList.push(row);
			row.setEnabled(false);
			if (isRunning == false)
			{
				next();
			}
		}
		
		private function next():void 
		{
			isRunning = true;
			if (rowList.length == 0)
			{
				complete();
				return;
			}
			
			current = rowList.shift();
			current.save();
			
			var output:File = Main.current.getOutputFolder(current.data);
			if (output == null)
			{
				current.setEnabled(true);
				next();
				return;
			}
			
			converter = new Converter();
			
			var item:ConvertItem = current.data;
			var file:File = current.getSourceFile();
			if (file == null || file.exists == false)
			{
				current.error(["ソースファイルが見つかりません！"]);
				
				current.setEnabled(true);
				next();
				return;
			}
			
			var ext:String = String(file.extension).toLowerCase();
			if (["dae", "fbx"].indexOf(ext) == -1)
			{
				current.error(["ソースファイルの拡張子は未対応です！"]);
				
				current.setEnabled(true);
				next();
				return;
			}
			
			converter.onLog = Main.current.tracer.log;
			converter.onError = convert_errorHandler;
			converter.onProgress = convert_progressHandler;
			converter.onComplete = convert_completeHandler;
			
			current.loading();
			converter.convert(file, item.getOption(), current.getMaterialFolder(), current.getOutputFile());
		}
		
		private function convert_errorHandler():void 
		{
			current.setEnabled(true);
			next();
		}
		
		private function convert_progressHandler(per:Number):void 
		{
			Main.current.progressBar.value = per;
		}
		
		private function convert_completeHandler():void 
		{
			if (converter.errorList.length == 0)
			{
				current.success();
			}
			else
			{
				current.caution(converter.errorList);
			}
			current.setEnabled(true);
			next();
		}
		
		private function complete():void 
		{
			current = null;
			isRunning = false;
		}
		
	}

}