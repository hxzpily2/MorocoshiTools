package project.tfp.tools 
{
	import com.bit101.components.Label;
	import flash.display.NativeWindow;
	import net.morocoshi.air.components.minimal.MessageDialog;
	import net.morocoshi.air.windows.ModalManager;
	import net.morocoshi.components.minimal.BitmapClip;
	import project.tfp.file.Asset;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class VersionWindow 
	{
		private var win:NativeWindow;
		
		public function VersionWindow() 
		{
		}
		
		public function open():void
		{
			var text:String = Asset.application.name + " " + Asset.application.version;
			text += "\nDevelopment: tencho";
			var title:String = Asset.application.name + "について";
			win = new MessageDialog().open("", null, null, null, true, 25, 210);
			ModalManager.activate(win);
			new BitmapClip(win.stage, 20, 17, Asset.appIcon, true).setSize(36, 36);
			new Label(win.stage, 70, 15, text);
		}
		
	}

}