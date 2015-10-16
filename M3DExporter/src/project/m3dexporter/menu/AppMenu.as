package project.m3dexporter.menu 
{
	import flash.display.NativeMenuItem;
	import net.morocoshi.air.menu.AirMenu;
	import project.m3dexporter.data.UserFile;
	import project.m3dexporter.Main;
	/**
	 * ...
	 * @author tencho
	 */
	public class AppMenu 
	{
		private var user:UserFile;
		private var checkOverride:NativeMenuItem;
		private var showTraceWindow:NativeMenuItem;
		
		public var menu:AirMenu;
		
		public function AppMenu() 
		{			
		}
		
		public function init(user:UserFile):void
		{
			this.user = user;
			
			menu = new AirMenu();
			
			var menuItem:AirMenu;
			
			menuItem = new AirMenu();
			menuItem.addMenuItem("閉じる", "", null, Main.current.user.saveAndClose);
			menu.addSubmenu(menuItem, "ファイル");
			
			menuItem = new AirMenu();
			checkOverride = menuItem.addMenuItem("同名ファイルの上書きを確認する", "", null, selectCheckOverride);
			menu.addSubmenu(menuItem, "設定");
			
			menuItem = new AirMenu();
			showTraceWindow = menuItem.addMenuItem("トレースウィンドウ", "", null, selectTraceWindow);
			menu.addSubmenu(menuItem, "表示");
			
			updateCheck();
		}
		
		private function selectTraceWindow():void 
		{
			user.showTraceWindow = !user.showTraceWindow;
			updateCheck();
		}
		
		private function selectCheckOverride():void 
		{
			user.checkOverride = !user.checkOverride;
			updateCheck();
		}
		
		public function updateCheck():void
		{
			checkOverride.checked = user.checkOverride;
			showTraceWindow.checked = user.showTraceWindow;
			Main.current.tracer.visible = user.showTraceWindow;
			Main.current.rootCell.update();
		}
		
	}

}