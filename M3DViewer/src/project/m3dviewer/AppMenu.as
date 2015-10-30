package project.m3dviewer 
{
	import flash.display.NativeMenuItem;
	import flash.display3D.Context3DProfile;
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
		private var profileMenu:AirMenu;
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
			menu.addSubmenu(fileMenu, "ファイル");
			
			profileMenu = new AirMenu();
			profileMenu.addMenuItem("BASELINE_CONSTRAINED", "", null, profile_selectHandler, [Context3DProfile.BASELINE_CONSTRAINED]);
			profileMenu.addMenuItem("BASELINE", "", null, profile_selectHandler, [Context3DProfile.BASELINE]);
			profileMenu.addMenuItem("BASELINE_EXTENDED", "", null, profile_selectHandler, [Context3DProfile.BASELINE_EXTENDED]);
			profileMenu.addMenuItem("STANDARD_CONSTRAINED", "", null, profile_selectHandler, [Context3DProfile.STANDARD_CONSTRAINED]);
			profileMenu.addMenuItem("STANDARD", "", null, profile_selectHandler, [Context3DProfile.STANDARD]);
			profileMenu.addMenuItem("STANDARD_EXTENDED", "", null, profile_selectHandler, [Context3DProfile.STANDARD_EXTENDED]);
			menu.addSubmenu(profileMenu, "プロファイル");
			updateMenuSelect();
		}
		
		private function updateMenuSelect():void 
		{
			for each(var item:NativeMenuItem in profileMenu.items)
			{
				item.checked = Context3DProfile[item.label] == Main.current.user.profileType;
			}
		}
		
		private function profile_selectHandler(profile:String):void 
		{
			Main.current.user.profileType = profile;
			updateMenuSelect();
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