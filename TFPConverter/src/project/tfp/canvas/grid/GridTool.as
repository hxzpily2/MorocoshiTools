package project.tfp.canvas.grid 
{
	import com.bit101.components.HBox;
	import com.bit101.components.Panel;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import net.morocoshi.components.balloon.MouseOverLabel;
	import net.morocoshi.components.minimal.buttons.BitmapButton;
	import project.tfp.data.AssetItem;
	import project.tfp.Document;
	import project.tfp.file.Asset;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class GridTool 
	{
		public var sprite:Panel;
		public var removeButton:BitmapButton;
		private var parent:ExportDataGrid;
		private var addButton:BitmapButton;
		private var newButton:BitmapButton;
		private var configButton:BitmapButton;
		private var saveButton:BitmapButton;
		private var openButton:BitmapButton;
		private var saveAsButton:BitmapButton;
		private var removeAllButton:BitmapButton;
		
		public function GridTool(parent:ExportDataGrid) 
		{
			this.parent = parent;
			sprite = new Panel();
			var box:HBox = new HBox(sprite, 10, 7);
			box.spacing = 10;
			
			saveButton = new BitmapButton(box, 0, 0, Asset.images[168], null, null, save_clickHandler);
			openButton = new BitmapButton(box, 0, 0, Asset.images[214], null, null, open_clickHandler);
			newButton = new BitmapButton(box, 0, 0, Asset.images[275], null, null, new_clickHandler);
			
			box.addChild(new Bitmap(Asset.separater, "auto", true));
			
			addButton = new BitmapButton(box, 0, 0, Asset.images[33], null, null, add_clickHandler);
			removeButton = new BitmapButton(box, 0, 0, Asset.images[153], null, null, remove_clickHandler);
			removeAllButton = new BitmapButton(box, 0, 0, Asset.images[91], null, null, removeAll_clickHandler);
			
			box.addChild(new Bitmap(Asset.separater, "auto", true));
			
			configButton = new BitmapButton(box, 0, 0, Asset.images[481], null, null, config_clickHandler);
			
			box.addChild(new Bitmap(Asset.separater, "auto", true));
			
			sprite.addEventListener(Event.RESIZE, tool_resizeHandler);
			
			MouseOverLabel.instance.setLabel(openButton, "開く");
			MouseOverLabel.instance.setLabel(saveButton, "保存");
			MouseOverLabel.instance.setLabel(newButton, "新規作成");
			
			MouseOverLabel.instance.setLabel(addButton, "新しい行を追加");
			MouseOverLabel.instance.setLabel(removeButton, "選択している行を削除");
			MouseOverLabel.instance.setLabel(removeAllButton, "全ての行を削除");
			MouseOverLabel.instance.setLabel(configButton, "環境設定");
		}
		
		private function saveAs_clickHandler(e:Event):void 
		{
			Document.project.saveAs();
		}
		
		private function new_clickHandler(e:Event):void
		{
			Document.project.newFile(false);
		}
		
		private function removeAll_clickHandler(e:Event):void 
		{
			parent.askRemoveAll();
		}
		
		private function config_clickHandler(e:MouseEvent):void 
		{
			parent.openConfig();
		}
		
		private function open_clickHandler(e:MouseEvent):void 
		{
			Document.project.browse();
		}
		
		private function save_clickHandler(e:MouseEvent):void 
		{
			Document.project.trySave();
		}
		
		private function remove_clickHandler(e:MouseEvent):void 
		{
			parent.askRemoveSelected();
		}
		
		private function add_clickHandler(e:MouseEvent):void 
		{
			var item:AssetItem = new AssetItem();
			item.zip = Document.user.config.autoCompress;
			parent.addItem().setItemData(item);
		}
		
		private function tool_resizeHandler(e:Event):void 
		{
		}
		
	}

}