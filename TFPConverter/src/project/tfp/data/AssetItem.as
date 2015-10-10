package project.tfp.data 
{
	import net.morocoshi.common.text.XMLUtil;
	
	/**
	 * アセット書き出し用アイテム
	 * 
	 * @author tencho
	 */
	public class AssetItem 
	{
		public var folder:String = "";
		public var output:String = "";
		public var memo:String = "";
		public var zip:Boolean = false;
		public var subfolder:Boolean = false;
		
		public function AssetItem() 
		{
		}
		
		public function clone():AssetItem 
		{
			var item:AssetItem = new AssetItem();
			item.folder = folder;
			item.output = output;
			item.memo = memo;
			item.zip = zip;
			return item;
		}
		
		public function toXML():XML 
		{
			var xml:XML = new XML(<item />);
			xml.@path = folder;
			xml.@output = output;
			xml.@compress = String(zip);
			xml.@subfolder = String(subfolder);
			return xml;
		}
		
		public function parse(xml:XML):void
		{
			folder = xml.@path;
			output = xml.@output;
			subfolder = XMLUtil.getAttrBoolean(xml, "subfolder", false);
			zip = XMLUtil.getAttrBoolean(xml, "compress", false);
			memo = "";
		}
		
	}

}