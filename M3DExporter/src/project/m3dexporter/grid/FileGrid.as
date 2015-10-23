package project.m3dexporter.grid 
{
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.filesystem.File;
	import net.morocoshi.air.drop.DragDrop;
	import net.morocoshi.air.drop.DropEvent;
	import net.morocoshi.air.files.FileUtil;
	import net.morocoshi.common.graphics.Create;
	import net.morocoshi.common.math.geom.ScaleMode;
	import net.morocoshi.components.minimal.grid.DataGrid;
	import net.morocoshi.components.minimal.grid.DataGridItem;
	import net.morocoshi.components.minimal.grid.GridCellBitmap;
	import net.morocoshi.components.minimal.grid.GridCellButton;
	import net.morocoshi.components.minimal.grid.GridCellCheckBox;
	import net.morocoshi.components.minimal.grid.GridCellInputFile;
	import net.morocoshi.components.minimal.grid.GridCellInputText;
	import project.m3dexporter.asset.Asset;
	import project.m3dexporter.data.ConvertItem;
	import project.m3dexporter.data.UserFile;
	/**
	 * ...
	 * @author tencho
	 */
	public class FileGrid 
	{
		private var bg:Sprite;
		public var grid:DataGrid;
		
		public function FileGrid() 
		{
			grid = new DataGrid();
			grid.itemHeight = 26;
			grid.addColumn("select", "選択", 40, GridCellCheckBox);
			grid.addColumn("source", "変換するファイル", -1, GridCellInputFile);
			grid.addColumn("ignoreFolder", "パス削", 50, GridCellCheckBox);
			grid.addColumn("materialFolder", "マテリアルフォルダ", -1, GridCellInputFile);
			grid.addColumn("exportModel", "物", 24, GridCellBitmap);
			grid.addColumn("exportImage", "絵", 24, GridCellBitmap);
			grid.addColumn("exportAnimation", "動", 24, GridCellBitmap);
			grid.addColumn("fixPNG", "縁整", 40, GridCellCheckBox);
			grid.addColumn("threshold", "閾値", 35, GridCellInputText);
			grid.addColumn("option", "書出設定", 65, GridCellButton);
			grid.addColumn("convert", "", 50, GridCellButton);
			grid.addColumn("status", "", 24, GridCellBitmap);
			grid.addColumn("preview", "", 50, GridCellButton);
			
			bg = Create.box(0, 0, 10, 10, 0x888888);
			grid.addChildAt(bg, 0);
			var dd:DragDrop = new DragDrop();
			dd.addDropTarget(grid.getChildAt(1) as InteractiveObject);
			dd.allowFile = true;
			dd.allowExtensions = ["dae", "fdx"];
			dd.addEventListener(DropEvent.DRAG_DROP, stage_dropHandler);
		}
		
		private function stage_dropHandler(e:DropEvent):void 
		{
			for each(var file:File in e.clipData.fileList)
			{
				var row:RowItem = getRowByURL(FileUtil.url(file));
				if (row)
				{
					row.highlight();
				}
				else
				{
					addItem(null, file, true);
				}
			}
		}
		
		public function addItem(item:ConvertItem, file:File, newLine:Boolean):void
		{
			if (item == null)
			{
				item = new ConvertItem();
			}
			if (file)
			{
				item.sourceFile = FileUtil.url(file);
			}
			if (newLine && grid.items.length >= 1)
			{
				var last:DataGridItem = grid.items[grid.items.length - 1];
				RowItem(last.extra).save();
				item.applyFrom(RowItem(last.extra).data);
			}
			
			var data:Object = { };
			data.check = false;
			data.same = true;
			data.source = "";
			data.output = "";
			data.option = "共通設定";
			data.convert = "変換";
			data.preview = "表示";
			data.status = null;
			data.exportModel = Asset.getImage(Asset.Model, 16, 16, 0x0044AA);
			data.exportImage = Asset.getImage(Asset.Image, 16, 16, 0x00AA00);
			data.exportAnimation = Asset.getImage(Asset.Animation, 16, 16, 0xAA4400);
			new RowItem(grid.addItemByObject(data), item);
		}
		
		public function setUser(user:UserFile):void 
		{
			var n:int = user.itemList.length;
			for (var i:int = 0; i < n; i++) 
			{
				addItem(user.itemList[i], null, false);
			}
		}
		
		public function getRowByURL(url:String):RowItem 
		{
			for each (var item:DataGridItem in grid.items) 
			{
				if (item.getValue("source") == url)
				{
					return item.extra;
				}
			}
			return null;
		}
		
	}

}