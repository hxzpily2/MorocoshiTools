package project.m3dviewer 
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.ProgressBar;
	import com.bit101.components.PushButton;
	import flash.display.BitmapData;
	import flash.display.NativeWindow;
	import flash.display.PNGEncoderOptions;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import net.morocoshi.air.components.minimal.Modal;
	import net.morocoshi.air.files.FileUtil;
	import net.morocoshi.air.files.LocalFile;
	import net.morocoshi.air.windows.WindowUtil;
	import net.morocoshi.common.graphics.BitmapUtil;
	import net.morocoshi.common.timers.FrameTimer;
	import net.morocoshi.components.minimal.grid.DataGrid;
	import net.morocoshi.components.minimal.grid.DataGridEvent;
	import net.morocoshi.components.minimal.grid.DataGridItem;
	import net.morocoshi.components.minimal.grid.GridCellComboBox;
	import net.morocoshi.components.minimal.grid.GridCellText;
	import net.morocoshi.components.minimal.layout.LayoutCell;
	import net.morocoshi.moja3d.resources.ExternalTextureResource;
	import net.morocoshi.moja3d.resources.Resource;
	
	/**
	 * テクスチャリサイズ
	 * 
	 * @author tencho
	 */
	public class MaterialEditor extends NativeWindow
	{
		private var layout:LayoutCell;
		private var grid:DataGrid;
		private var progress:ProgressBar;
		
		private var isReady:Boolean;
		private var context3D:Context3D;
		private var tempFolder:File;
		private var exportItems:Vector.<DataGridItem>;
		private var m3dFile:File;
		private var buttonCell:LayoutCell;
		private var overrideMode:Boolean;
		
		public function MaterialEditor(owner:NativeWindow) 
		{
			super(WindowUtil.createOption(owner));
			title = "テクスチャのリサイズ";
			addEventListener(Event.CLOSING, closingHandler);
			
			stage.align = "TL";
			stage.scaleMode = "noScale";
			stage.addEventListener(Event.RESIZE, win_resizeHandler);
			stage.stageWidth = 550;
			stage.stageHeight = 400;
			
			
			grid = new DataGrid(null);
			grid.addColumn("name", "ファイル名", -1, GridCellText);
			grid.addColumn("size", "サイズ", 110, GridCellText);
			grid.addColumn("resize", "リサイズ", 110, GridCellComboBox);
			grid.addColumn("type", "形式", 60, GridCellText);
			
			progress = new ProgressBar();
			
			layout = new LayoutCell(stage, 0, 0, LayoutCell.ALIGN_TOP, false);
			layout.addCell(grid);
			layout.addCell(progress, "10px");
			buttonCell = new LayoutCell(null, 0, 0, LayoutCell.ALIGN_LEFT, false);
			buttonCell.addCell(new PushButton(null, 0, 0, "リサイズ画像をフォルダに書き出し", exportImages_clickHandler), "*");
			//buttonCell.addCell(new PushButton(null, 0, 0, "リサイズ画像をM3Dに上書き", overrideImages_clickHandler), "*");
			layout.addCell(buttonCell, "40px");
			
			win_resizeHandler(null);
		}
		
		private function closingHandler(e:Event):void 
		{
			layout.enabled = true;
			stage.removeEventListener(Event.ENTER_FRAME, exportTick);
			
			e.preventDefault();
			visible = false;
		}
		
		private function overrideImages_clickHandler(e:Event):void
		{
			if (grid.items.length == 0)
			{
				return;
			}
			
			layout.enabled = false;
			overrideMode = true;
			FrameTimer.setTimer(3, timesUpHandler);
		}
		
		private function exportImages_clickHandler(e:Event):void
		{
			if (grid.items.length == 0)
			{
				return;
			}
			
			layout.enabled = false;
			overrideMode = false;
			FrameTimer.setTimer(3, timesUpHandler);
		}
		
		private function timesUpHandler():void 
		{
			tempFolder = File.createTempDirectory();
			exportItems = grid.items.concat();
			stage.addEventListener(Event.ENTER_FRAME, exportTick);
		}
		
		private function exportTick(e:Event):void 
		{
			var time:int = getTimer();
			do
			{
				progress.value = (grid.items.length - exportItems.length) / grid.items.length;
				
				if (exportItems.length == 0)
				{
					completeExport();
					return;
				}
				
				var item:DataGridItem = exportItems.pop();
				var resource:ExternalTextureResource = item.extra.resource;
				var ba:ByteArray = resource.bitmapData.encode(resource.bitmapData.rect, new PNGEncoderOptions(false));
				var file:File = tempFolder.resolvePath(FileUtil.getFileName(item.getValue("name")));
				LocalFile.writeByteArray(file, ba);
			}
			while (getTimer() - time < 100);
		}
		
		private function completeExport():void 
		{
			layout.enabled = true;
			stage.removeEventListener(Event.ENTER_FRAME, exportTick);
			var newName:String = "resizedTextures_" + new Date().getTime();
			var target:File = m3dFile.parent.resolvePath(newName);
			tempFolder.copyTo(target, false);
			
			Modal.alert(target.nativePath + "\nにリサイズテクスチャを書き出しました。");
		}
		
		public function open(m3dFile:File, resources:Vector.<Resource>, context3D:Context3D):void
		{
			if (m3dFile == null) return;
			
			this.m3dFile = m3dFile;
			this.context3D = context3D;
			isReady = false;
			grid.removeAllItems();
			
			var cache:Object = { };
			var n:int = resources.length;
			for (var i:int = 0; i < n; i++) 
			{
				var r:Resource = resources[i];
				var etr:ExternalTextureResource = r as ExternalTextureResource;
				if (etr == null) continue;
				
				var image:BitmapData = etr.bitmapData;
				if (image == null || cache[etr.path]) continue;
				
				cache[etr.path] = true;
				var item:DataGridItem = grid.addItemByObject( { name:etr.path, size:image.width + "x" + image.height, type:"PNG"} );
				item.extra = { resource:etr, bitmap:etr.bitmapData.clone() };
				var cb:GridCellComboBox = item.getComponent("resize") as GridCellComboBox;
				cb.addEventListener(DataGridEvent.CHANGE, combo_changeHandler);
				var combo:ComboBox = cb.comboBox;
				combo.removeAll();
				var w:int = image.width;
				var h:int = image.height;
				var count:int = 0;
				while (w > 1 && h > 1)
				{
					combo.addItem( { "label": w + "x" + h, data:count } );
					count++;
					w >>= 1;
					h >>= 1;
				}
				combo.selectedIndex = 0;
			}
			grid.sort("name", false);
			
			isReady = true;
			activate();
		}
		
		private function combo_changeHandler(e:DataGridEvent):void 
		{
			if (isReady == false || e.cell == null) return;
			var combo:GridCellComboBox = e.cell as GridCellComboBox;
			var scale:int = combo.cellValue;
			var resource:ExternalTextureResource = combo.gridItem.extra.resource;
			var rawImage:BitmapData = combo.gridItem.extra.bitmap;
			var resizedImage:BitmapData = BitmapUtil.resize(rawImage, rawImage.width >> scale, rawImage.height >> scale, true);
			resource.setBitmapResource(resizedImage, true);
			resource.upload(context3D, false);
		}
		
		private function win_resizeHandler(e:Event):void 
		{
			var sw:Number = stage.stageWidth;
			var sh:Number = stage.stageHeight;
			if (grid)
			{
				layout.setSize(sw, sh);
			}
		}
		
	}

}