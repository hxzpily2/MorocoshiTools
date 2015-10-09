package project.m3dexporter 
{
	import com.bit101.components.TextArea;
	import net.morocoshi.components.minimal.layout.LayoutCell;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Tracer extends LayoutCell
	{
		private var isReady:Boolean = false;
		public var textArea:TextArea;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function Tracer() 
		{
			super();
			textArea = new TextArea(this);
			isReady = true;
		}
		
		public function clear():void
		{
			textArea.text = "";
		}
		
		public function logLines(...args):void
		{
			textArea.text += args.join(",") + "\n";
		}
		
		public function log(text:*, newline:Boolean = true):void 
		{
			textArea.text += String(text);
			if (newline)
			{
				textArea.text += "\n";
			}
		}
		/*
		private function timesUp():void 
		{
			var scroll:VScrollBar = textArea.getChildAt(2) as VScrollBar;
			scroll.value = scroll.maximum;
		}
		*/
		override public function setSize(w:Number, h:Number):void 
		{
			if (!isReady) return;
			
			super.setSize(w, h);
			textArea.setSize(w, h);
			textArea.visible = (w > 15 && h > 15);
		}
		
	}

}