package project.tfp.file 
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import net.morocoshi.air.application.ApplicationData;
	import net.morocoshi.common.graphics.BitmapUtil;
	
	/**
	 * 埋め込みアセット
	 * 
	 * @author tencho
	 */
	public class Asset 
	{
		[Embed(source="../../../../assets/Images.png")]
		private static var Images:Class;
		[Embed(source="../../../../assets/icons.png")]
		private static var Icon:Class;
		[Embed(source="../../../../bin/icons/036.png")]
		private static var AppIcon:Class;
		
		/**16x16アイコンリスト*/
		public static var icons:Vector.<BitmapData>;
		/**アイコンリスト*/
		public static var images:Vector.<BitmapData>;
		/**アプリアイコン*/
		public static var appIcon:BitmapData;
		/**区切り線*/
		public static var separater:BitmapData;
		/**アプリデータ*/
		public static var application:ApplicationData;
		
		/**
		 * コンストラクタ
		 */
		public function Asset() 
		{
		}
		
		/**
		 * アセット生成
		 */
		public static function create():void
		{
			separater = new BitmapData(2, 16, false, 0xBDBDBD);
			separater.fillRect(new Rectangle(1, 0, 1, 16), 0xFFFFFF);
			icons = BitmapUtil.split(new Icon().bitmapData, 16, 16);
			images = BitmapUtil.split(new Images().bitmapData, 16, 16, 16);
			appIcon = new AppIcon().bitmapData;
			application = new ApplicationData();
		}
		
	}

}