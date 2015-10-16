package project.m3dexporter.data 
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import net.morocoshi.air.files.UserData;
	import net.morocoshi.common.loaders.ClassAliasUtil;
	import net.morocoshi.moja3d.loader.exporters.M3DExportOption;
	
	/**
	 * 保存データ
	 * 
	 * @author tencho
	 */
	public class UserFile extends UserData 
	{
		public var commonOption:M3DExportOption;
		public var checkOverride:Boolean;
		public var itemList:Vector.<ConvertItem>;
		public var outputMode:int;
		public var outputFolder:String;
		public var showTraceWindow:Boolean;
		
		public function UserFile() 
		{
			super("userdata.dat");
			
			ClassAliasUtil.register(Vector3D);
			ClassAliasUtil.register(Matrix3D);
			ClassAliasUtil.register(ConvertItem);
			ClassAliasUtil.register(M3DExportOption);
			ClassAliasUtil.register(Vector.<ConvertItem>);
			
			itemList = new Vector.<ConvertItem>;
			commonOption = new M3DExportOption();
			checkOverride = true;
			showTraceWindow = true;
			outputMode = 0;
			outputFolder = "";
		}
		
	}

}