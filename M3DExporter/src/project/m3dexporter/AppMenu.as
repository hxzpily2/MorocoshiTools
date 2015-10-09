package project.m3dexporter 
{
	import flash.display.NativeMenuItem;
	import net.morocoshi.air.menu.AirMenu;
	import project.m3dexporter.data.UserFile;
	/**
	 * ...
	 * @author tencho
	 */
	public class AppMenu 
	{
		private var user:UserFile;
		private var autoParse:NativeMenuItem;
		private var checkOverride:NativeMenuItem;
		private var autoResetCamera:NativeMenuItem;
		
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
			autoParse = menuItem.addMenuItem("ショートカット起動時にファイルをパースして保存する", "", null, selectAutoParse);
			checkOverride = menuItem.addMenuItem("同名ファイルの上書きを確認する", "", null, selectCheckOverride);
			autoResetCamera = menuItem.addMenuItem("プレビュー時に毎回カメラを初期位置に戻す", "", null, selectAutoResetCamera);
			menu.addSubmenu(menuItem, "設定");
			
			updateCheck();
		}
		
		private function selectAutoResetCamera():void 
		{
			user.menuOption.autoResetCamera = !user.menuOption.autoResetCamera;
			updateCheck();
		}
		
		private function selectCheckOverride():void 
		{
			user.menuOption.checkOverride = !user.menuOption.checkOverride;
			updateCheck();
		}
		
		private function selectAutoParse():void 
		{
			user.menuOption.autoParse = !user.menuOption.autoParse;
			updateCheck();
		}
		
		public function updateCheck():void
		{
			autoParse.checked = user.menuOption.autoParse;
			checkOverride.checked = user.menuOption.checkOverride;
			autoResetCamera.checked = user.menuOption.autoResetCamera
		}
		
	}

}