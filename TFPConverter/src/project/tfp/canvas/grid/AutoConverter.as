package project.tfp.canvas.grid 
{
	import flash.events.Event;
	import net.morocoshi.air.components.minimal.Modal;
	import net.morocoshi.components.minimal.grid.DataGridItem;
	import project.tfp.Document;
	
	/**
	 * 一括書き出し
	 * 
	 * @author tencho
	 */
	public class AutoConverter 
	{
		private var grid:ExportDataGrid;
		private var stock:Vector.<ExportRow>;
		
		public function AutoConverter(grid:ExportDataGrid) 
		{
			this.grid = grid;
			stock = new Vector.<ExportRow>;
		}
		
		/**
		 * 一括書き出し開始
		 */
		public function startConvert():void
		{
			var errorList:Vector.<String> = new Vector.<String>;
			var items:Vector.<DataGridItem> = grid.grid.items;
			
			var numExsist:int = 0;
			stock.length = 0;
			for (var i:int = 0; i < items.length; i++) 
			{
				var row:ExportRow = items[i] as ExportRow;
				if (row.isConverting)
				{
					Modal.alert("現在書き出し中のファイルがあります。");
					return;
				}
				var error:String = row.getErrorText();
				if (error)
				{
					errorList.push(error);
				}
				else
				{
					if (!row.subfolder && row.getOutputFile().exists) numExsist++;
				}
				stock.push(row);
			}
			
			if (errorList.length)
			{
				Modal.alert(errorList.length + "箇所のファイルパスが不正です");
				return;
			}
			if (numExsist && Document.user.config.overwrite)
			{
				Modal.confirm(numExsist + "個のファイルが上書きされますがよろしいですか？", convert);
				return;
			}
			convert();
		}
		
		private function convert():void 
		{
			grid.enabled = false;
			convertNext();
		}
		
		private function convertNext():void 
		{
			if (!stock.length)
			{
				grid.enabled = true;
				Modal.alert("全ての処理が完了しました。");
				return;
			}
			var row:ExportRow = stock.shift();
			row.addEventListener(Event.COMPLETE, row_completeHandler);
			row.addEventListener(Event.CANCEL, row_errorHandler);
			row.convert();
		}
		
		private function row_errorHandler(e:Event):void 
		{
			var row:ExportRow = e.currentTarget as ExportRow;
			row.removeEventListener(Event.COMPLETE, row_completeHandler);
			row.removeEventListener(Event.CANCEL, row_errorHandler);
			convertNext();
		}
		
		private function row_completeHandler(e:Event):void 
		{
			var row:ExportRow = e.currentTarget as ExportRow;
			row.removeEventListener(Event.COMPLETE, row_completeHandler);
			row.removeEventListener(Event.CANCEL, row_errorHandler);
			convertNext();
		}
		
	}

}