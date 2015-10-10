package project.tfp.canvas.drop 
{
	import com.bit101.components.Component;
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import flash.display.DisplayObjectContainer;
	import net.morocoshi.air.drop.DragDrop;
	import net.morocoshi.components.minimal.text.TextLabel;
	
	/**
	 * ファイルをドロップさせる領域
	 * 
	 * @author tencho
	 */
	public class DropArea extends Component 
	{
		private var panel:Panel;
		private var label:Label;
		private var dd:DragDrop;
		private var onDrop:Function;
		
		public function DropArea(parent:DisplayObjectContainer, labelText:String, onDrop:Function) 
		{
			super(parent, 0, 0);
			
			panel = new Panel(this);
			label = new TextLabel(this, 0, 0, labelText);
			this.onDrop = onDrop;
			dd = new DragDrop();
			dd.allowFolder = true;
			dd.onDragDrop = onDrop;
			dd.init(panel);
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			super.setSize(w, h);
			panel.setSize(w, h);
			label.x = (w - label.width) * 0.5 | 0;
			label.y = (h - label.height) * 0.5 | 0;
		}
		
	}

}