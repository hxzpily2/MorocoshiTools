package project.tfp.canvas.grid 
{
	import com.bit101.components.PushButton;
	import flash.events.Event;
	import flash.filesystem.File;
	import net.morocoshi.air.components.minimal.Modal;
	import net.morocoshi.air.files.ClipData;
	import net.morocoshi.air.files.FileUtil;
	import net.morocoshi.components.minimal.buttons.BitmapButton;
	import net.morocoshi.components.minimal.grid.ColumnData;
	import net.morocoshi.components.minimal.grid.DataGrid;
	import net.morocoshi.components.minimal.grid.DataGridEvent;
	import net.morocoshi.components.minimal.grid.DataGridItem;
	import net.morocoshi.components.minimal.grid.GridCellBitmap;
	import net.morocoshi.components.minimal.grid.GridCellButton;
	import net.morocoshi.components.minimal.grid.GridCellCheckBox;
	import net.morocoshi.components.minimal.grid.GridCellInputFile;
	import net.morocoshi.components.minimal.grid.GridCellText;
	import net.morocoshi.components.minimal.layout.LayoutCell;
	import project.tfp.canvas.setting.SettingCell;
	import project.tfp.data.AssetItem;
	import project.tfp.data.AssetList;
	import project.tfp.data.AssetSetting;
	import project.tfp.Document;
	import project.tfp.tools.ConfigWindow;
	
	/**
	 * TFP書き出し用GridData
	 * 
	 * @author tencho
	 */
	public class ExportDataGrid extends LayoutCell
	{
		public var tool:GridTool;
		public var grid:DataGrid;
		private var removeButton:BitmapButton;
		private var outputColumn:ColumnData;
		private var compressColumn:ColumnData;
		private var bottomCell:LayoutCell;
		private var autoConverter:AutoConverter;
		private var settingCell:SettingCell;
		
		public function ExportDataGrid() 
		{
			super(null, 0, 0, "top");
			
			//ツールバー
			tool = new GridTool(this);
			
			//GridData
			grid = new DataGrid();
			grid.addColumn("check", "", 32, GridCellCheckBox);
			grid.addColumn("type", "", 32, GridCellBitmap);
			grid.addColumn("folder", "アセットフォルダ", -1, GridCellInputFile);
			outputColumn = grid.addColumn("tfp", "書き出しファイル", -1, GridCellInputFile);
			compressColumn = grid.addColumn("zip", "圧縮", 45, GridCellCheckBox);
			grid.addColumn("button", "", 80, GridCellButton);
			grid.addColumn("progress", "進行状況", 100, GridCellText);
			grid.addColumn("rate", "圧縮率", 80, GridCellText);
			grid.setSortEnabled(false);
			grid.addEventListener(DataGridEvent.CHANGE, grid_changeHandler);
			
			settingCell = new SettingCell(null, 0, 0);
			
			bottomCell = new LayoutCell(null, 0, 0, LayoutCell.ALIGN_LEFT);
			bottomCell.addCell(settingCell);
			bottomCell.addCell(new PushButton(null, 0, 0, "一括書き出し", output_clickHandler), "120px");
			bottomCell.getSeparatorAt(0).enabled = false;
			addCell(tool.sprite, "30px");
			addCell(grid, "*");
			addCell(bottomCell, "115px");
			
			getSeparatorAt(0).enabled = false;
			getSeparatorAt(1).enabled = false;
			
			checkGrid();
			
			autoConverter = new AutoConverter(this);
		}
		
		private function output_clickHandler(e:Event):void 
		{
			Modal.confirm("全てのフォルダを書き出しますか？", autoConverter.startConvert);
		}
		
		/**
		 * フォルダドロップ
		 * @param	clip
		 */
		public function dropDirectories(clip:ClipData):void 
		{
			for each(var file:File in clip.fileList)
			{
				if (!file.isDirectory) continue;
				
				var url:String = FileUtil.url(file);
				//既に同じフォルダがあればスキップ
				if (grid.match("folder", url).length) continue;
				
				var row:ExportRow = addItem();
				var item:AssetItem = new AssetItem();
				item.folder = url;
				item.zip = Document.user.config.autoCompress;
				row.setItemData(item);
			}
		}
		
		/**
		 * 選択を削除するか確認
		 */
		public function askRemoveSelected():void
		{
			var selectNum:int = 0;
			for each(var item:DataGridItem in grid.items)
			{
				if (item.getValue("check")) selectNum++;
			}
			Modal.confirm("選択している" + selectNum + "個のアイテムを削除しますか？", removeSelected);
		}
		
		/**
		 * 全削除の確認
		 */
		public function askRemoveAll():void 
		{
			Modal.confirm("リストの全アイテムを削除しますか？", removeAll);
		}
		
		/**
		 * リストをチェックしてツールアイコンの表示を更新する
		 */
		public function checkGrid():void
		{
			var selectNum:int = 0;
			for each(var item:DataGridItem in grid.items)
			{
				if (item.getValue("check")) selectNum++;
			}
			tool.removeButton.enabled = (selectNum > 0);
		}
		
		private function grid_changeHandler(e:DataGridEvent):void 
		{
			checkGrid();
		}
		
		/**
		 * 現在のリストのデータを取得
		 * @return
		 */
		public function getAssetList():Vector.<AssetItem>
		{
			var list:Vector.<AssetItem> = new Vector.<AssetItem>;
			for each(var item:DataGridItem in grid.items)
			{
				list.push(ExportRow(item).toAssetItem());
			}
			return list;
		}
		
		/**
		 * AssetListデータを渡してリストを生成
		 * @param	assetItem
		 */
		public function importAssetList(assetItem:AssetList):void
		{
			removeAll();
			for each(var item:AssetItem in assetItem.items)
			{
				var row:ExportRow = addItem();
				row.setItemData(item);
			}
			settingCell.setSetting(assetItem.setting);
			applySetting(assetItem.setting);
		}
		
		public function applySetting(setting:AssetSetting):void 
		{
			outputColumn.enabled = !setting.autoOutputPath;
			compressColumn.enabled = !setting.useCompressThreshold;
			grid.update();
		}
		
		/**
		 * 新規の行を追加
		 * @return
		 */
		public function addItem():ExportRow 
		{
			var item:ExportRow = new ExportRow();
			grid.addItem(item);
			item.init();
			item.onError = item_errorHandler;
			return item;
		}
		
		private function item_errorHandler(text:String):void 
		{
			Modal.alert(text);
		}
		
		/**
		 * 全ての行を削除
		 */
		public function removeAll():void
		{
			grid.removeAllItems();
		}
		
		/**
		 * 選択行を削除
		 */
		public function removeSelected():void 
		{
			var removes:Vector.<DataGridItem> = new Vector.<DataGridItem>;
			for each(var item:DataGridItem in grid.items)
			{
				if (item.getValue("check")) removes.push(item);
			}
			while (removes.length)
			{
				grid.removeItem(removes.pop());
			}
		}
		
		/**
		 * 
		 */
		public function openConfig():void 
		{
			new ConfigWindow().open(Document.user.config, config_okHandler);
		}
		
		public function dropFilePathList(pathList:Array):void 
		{
			for (var i:int = 0; i < pathList.length; i++) 
			{
				var path:String = pathList[i].replace(/\s/g, "");
				if (!path) continue;
				var row:ExportRow = addItem();
				var item:AssetItem = new AssetItem();
				item.folder = path;
				item.zip = Document.user.config.autoCompress;
				row.setItemData(item);
			}
		}
		
		private function config_okHandler(e:Event):void 
		{
			ConfigWindow(e.currentTarget).setConfigData(Document.user.config);
		}
		
	}

}