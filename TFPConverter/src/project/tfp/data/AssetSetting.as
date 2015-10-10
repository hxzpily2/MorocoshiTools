package project.tfp.data 
{
	import net.morocoshi.common.text.XMLUtil;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class AssetSetting 
	{
		/**TFP書き出し場所をフォルダと同階層にする*/
		public var autoOutputPath:Boolean = true;
		/**圧縮閾値を使用するか*/
		public var useCompressThreshold:Boolean = true;
		/**圧縮閾値（圧縮率がこの値%を上回ったら圧縮されない）*/
		public var compressThreshold:Number = 80;
		/***/
		public var ignoreExtension:Array = ["tfp"];
		
		public function AssetSetting() 
		{
		}
		
		public function clone():AssetSetting 
		{
			var setting:AssetSetting = new AssetSetting();
			setting.autoOutputPath = autoOutputPath;
			setting.useCompressThreshold = useCompressThreshold;
			setting.compressThreshold = compressThreshold;
			setting.ignoreExtension = ignoreExtension.concat();
			return setting;
		}
		
		public function toXML():XML
		{
			var xml:XML = new XML(<setting />);
			xml.compress.@enabled = useCompressThreshold;
			xml.compress.@threshold = compressThreshold;
			xml.ignore = ignoreExtension.join(",");
			xml.autoOutputPath = autoOutputPath;
			return xml;
		}
		
		public function parse(setting:XML):void
		{
			useCompressThreshold = XMLUtil.getAttrBoolean(setting.compress, "enabled", true);
			compressThreshold = XMLUtil.getAttrNumber(setting.compress, "threshold", 80);
			ignoreExtension = XMLUtil.getNodeString(setting.ignore, "tfp").split(",");
			autoOutputPath = XMLUtil.getNodeBoolean(setting.autoOutputPath, true);
		}
		
		public function clear():void 
		{
			autoOutputPath = true;
			useCompressThreshold = true;
			compressThreshold = 80;
			ignoreExtension = ["tfp"];
		}
		
	}

}