package project.m3dexporter.data 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import net.morocoshi.air.files.UserData;
	import net.morocoshi.common.loaders.ClassAliasUtil;
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.moja3d.loader.exporters.M3DExportOption;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class UserFile extends UserData 
	{
		public var menuOption:MenuOption;
		public var option:M3DExportOption;
		public var fbxPath:String = "";
		public var cameraMatrix:Matrix3D = new Matrix3D();
		public var convertedFiles:Array = [];
		public var materialPath:String = "material/";
		/**ユーザーデータとして抽出するFBXオブジェクト追加プロパティ一覧*/
		public var objectParamList:Array = [];
		
		public function UserFile() 
		{
			super("userdata.dat");
			ClassAliasUtil.register(MenuOption);
			ClassAliasUtil.register(M3DExportOption);
			ClassAliasUtil.register(Vector3D);
			ClassAliasUtil.register(Matrix3D);
			option = new M3DExportOption();
			menuOption = new MenuOption();
		}
		
		public function addConvertedFile(url:String):void 
		{
			if (convertedFiles == null)
			{
				convertedFiles = [];
			}
			
			VectorUtil.deleteItem(convertedFiles, url);
			
			convertedFiles.unshift(url);
			if (convertedFiles.length > 10)
			{
				convertedFiles.length = 10;
			}
		}
		
	}

}