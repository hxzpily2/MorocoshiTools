package project.mp3viewer 
{
	import flash.filesystem.File;
	import net.morocoshi.air.files.FileUtil;
	import net.morocoshi.air.menu.AirMenu;
	import net.morocoshi.air.menu.RecentMenu;
	
	/**
	 * アプリメニュー
	 * 
	 * @author tencho
	 */
	public class AppMenu 
	{
		private var fileMenu:AirMenu;
		public var recentMenu:RecentMenu;
		public var menu:AirMenu;
		
		public function AppMenu() 
		{
			
		}
		
		public function init(user:UserFile):void
		{
			menu = new AirMenu();
			var subMenu:AirMenu;
			fileMenu = new AirMenu();
			recentMenu = new RecentMenu(user.recentPathList, 20);
			recentMenu.onChange = recent_changeHandler;
			recentMenu.onSelect = recent_selectHandler;
			recentMenu.update();
			recentMenu.addSubMenuTo(fileMenu, "最近開いたファイル");
			fileMenu.addSeparator();
			fileMenu.addMenuItem("終了", "", null, close_selectHandler);
			menu.addSubmenu(fileMenu, "ファイル")
		}
		
		private function recent_selectHandler(path:String):void 
		{
			var file:File = FileUtil.toFile(path);
			Main.current.loadFile(file);
		}
		
		private function recent_changeHandler():void 
		{
		}
		
		private function close_selectHandler():void 
		{
			Main.current.user.saveAndClose();
		}
		
	}

}