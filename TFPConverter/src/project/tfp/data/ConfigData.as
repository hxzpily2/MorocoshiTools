package project.tfp.data 
{
	/**
	 * 環境設定のデータ
	 * 
	 * @author tencho
	 */
	public class ConfigData 
	{
		/**新しい行を追加する時に圧縮にチェックをいれる*/
		public var autoCompress:Boolean = true;
		/**上書きを確認する*/
		public var overwrite:Boolean = true;
		/**TFP拡張子*/
		public var extension:String = "tfp";
		
		public var imageExp:Array = ["jpg", "png", "gif"];
		public var soundExp:Array = ["mp3"];
		public var xmlExp:Array = ["xml", "dae"];
		public var textExp:Array = ["txt"];
		public var videoExp:Array = [];
		
		public function ConfigData() 
		{
		}
		
	}

}