package project.m3dviewer 
{
	import flash.display3D.Context3DProfile;
	import net.morocoshi.air.files.UserData;
	
	/**
	 * 保存データ
	 * 
	 * @author tencho
	 */
	public class UserFile extends UserData 
	{
		public var recentPathList:Array = [];
		public var profileType:String = Context3DProfile.BASELINE;
		
		public function UserFile() 
		{
			super("userdata.dat");
		}
		
	}

}