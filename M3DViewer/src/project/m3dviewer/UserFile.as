package project.m3dviewer 
{
	import net.morocoshi.air.files.UserData;
	
	/**
	 * 保存データ
	 * 
	 * @author tencho
	 */
	public class UserFile extends UserData 
	{
		public var recentPathList:Array = [];
		
		public function UserFile() 
		{
			super("userdata.dat");
		}
		
	}

}