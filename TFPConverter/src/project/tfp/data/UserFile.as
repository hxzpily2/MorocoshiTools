package project.tfp.data 
{
	import net.morocoshi.air.files.UserData;
	import net.morocoshi.common.loaders.ClassAliasUtil;
	
	/**
	 * ローカル保存用データ
	 * 
	 * @author tencho
	 */
	public class UserFile extends UserData 
	{
		/**環境設定*/
		public var config:ConfigData = new ConfigData();
		/**サブフォルダ一括TFP化モードの初回説明*/
		public var showSubfolderMessage:Boolean = true;
		
		public function UserFile() 
		{
			super("localdata.dat");
			ClassAliasUtil.register(AssetSetting);
			ClassAliasUtil.register(AssetItem);
			ClassAliasUtil.register(AssetList);
			ClassAliasUtil.register(ConfigData);
			ClassAliasUtil.register(Vector.<AssetItem>);
		}
		
	}

}