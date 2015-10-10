package project.tfp.canvas
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import net.morocoshi.components.minimal.buttons.BitmapButton;
	import net.morocoshi.components.minimal.layout.LayoutCell;
	import net.morocoshi.components.minimal.tab.TabBox;
	import project.tfp.canvas.drop.DropConverter;
	import project.tfp.canvas.explorer.AssetViewer;
	import project.tfp.canvas.explorer.TFPExplorer;
	import project.tfp.canvas.grid.ExportDataGrid;
	import project.tfp.Document;
	
	/**
	 * メイン画面
	 * 
	 * @author tencho
	 */
	public class MainCanvas
	{
		static public const TAB_GRID:String = "grid";
		static public const TAB_PREVIEW:String = "preview";
		static public const TAB_TOOL:String = "tool";
		
		private var tab:TabBox;
		private var explorCell:LayoutCell;
		private var rootCell:LayoutCell;
		private var bottomCell:LayoutCell;
		public var sprite:Sprite;
		public var grid:ExportDataGrid;
		public var viewer:AssetViewer;
		public var explorer:TFPExplorer;
		
		public function MainCanvas() 
		{
		}
		
		public function init():void
		{
			sprite = new Sprite();
			
			rootCell = new LayoutCell(null, 0, 0, LayoutCell.ALIGN_TOP);
			
			grid = new ExportDataGrid();
			viewer = new AssetViewer();
			explorer = new TFPExplorer();
			
			explorCell = new LayoutCell(null, 0, 0, LayoutCell.ALIGN_LEFT);
			explorCell.addCell(explorer, "75%");
			explorCell.addCell(viewer, "*");
			
			tab = new TabBox();
			tab.addTab("変換リスト", TAB_GRID, grid);
			tab.addTab("プレビュー", TAB_PREVIEW, explorCell);
			tab.addTab("ツール", TAB_TOOL, new DropConverter());
			tab.selectTabID(TAB_GRID);
			
			rootCell.addCell(tab);
			
			sprite.addChild(rootCell);
			
			for each(var obj:DisplayObject in getAllDisplayObject(sprite))
			{
				if (!(obj is BitmapButton)) continue;
				BitmapButton(obj).setOverOffsetColor(-70, -70, -70);
				BitmapButton(obj).normalColor = new ColorTransform();
			}
			
			Document.display.addEventListener(Event.RESIZE, stage_resizeHandler);
		}
		
		private function getAllDisplayObject(target:DisplayObjectContainer):Vector.<DisplayObject> 
		{
			var list:Vector.<DisplayObject> = Vector.<DisplayObject>([target]);
			var n:int = target.numChildren;
			for (var i:int = 0; i < n; i++) 
			{
				var obj:DisplayObject = target.getChildAt(i);
				if (obj is DisplayObjectContainer)
				{
					list = list.concat(getAllDisplayObject(obj as DisplayObjectContainer));
				}
				else
				{
					list.push(obj);
				}
			}
			return list;
		}
		
		public function show(id:String):void
		{
			tab.selectTabID(id);
		}
		
		private function stage_resizeHandler(e:Event):void 
		{
			var sw:Number = sprite.stage.stageWidth;
			var sh:Number = sprite.stage.stageHeight;
			rootCell.setSize(sw, sh);
		}
		
	}

}