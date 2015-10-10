package project.tfp.menu 
{
	import net.morocoshi.air.components.minimal.Modal;
	import net.morocoshi.air.menu.AirMenu;
	import project.tfp.Document;
	import project.tfp.file.Asset;
	import project.tfp.tools.VersionWindow;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class AppMenu extends AirMenu
	{
		
		public function AppMenu() 
		{
			var sub:AirMenu;
			sub = new AirMenu();
			sub.addMenuItem("新規作成", "", null, Document.project.newFile, [false]);
			sub.addMenuItem("開く", "", null, Document.project.browse);
			sub.addSeparator();
			sub.addMenuItem("保存", "", null, Document.project.trySave);
			sub.addMenuItem("名前をつけて保存", "", null, Document.project.saveAs);
			sub.addSeparator();
			sub.addMenuItem("閉じる", "", null, Document.project.tryExit);
			addSubmenu(sub, "ファイル");
			
			sub = new AirMenu();
			sub.addMenuItem("環境設定", "", null, Document.canvas.grid.openConfig);
			addSubmenu(sub, "編集");
			
			sub = new AirMenu();
			sub.addMenuItem(Asset.application.name + "について", "", null, new VersionWindow().open);
			addSubmenu(sub, "ヘルプ");
		}
		
	}

}