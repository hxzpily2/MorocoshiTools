package project.tfp.data 
{
	import com.bit101.components.List;
	
	/**
	 * アセット書き出しデータのリスト
	 * 
	 * @author tencho
	 */
	public class AssetList 
	{
		static public const XMLID:String = "TFPAssetList";
		
		public var items:Vector.<AssetItem> = new Vector.<AssetItem>;
		public var setting:AssetSetting = new AssetSetting();
		
		public function AssetList() 
		{
		}
		
		public function clear():void
		{
			items.length = 0;
			setting.clear();
		}
		
		public function clone():AssetList 
		{
			var list:AssetList = new AssetList();
			for each (var item:AssetItem in items) 
			{
				list.items.push(item.clone());
			}
			list.setting = setting.clone();
			return list;
		}
		
		public function toXML():XML
		{
			var xml:XML = new XML(<data id={XMLID}></data>);
			xml.setting = setting.toXML();
			xml.items = new XML();
			for (var i:int = 0; i < items.length; i++) 
			{
				xml.items.appendChild(items[i].toXML());
			}
			return xml;
		}
		
		public function parse(xml:XML):void
		{
			setting.parse(xml.setting[0]);
			items.length = 0;
			for each(var node:XML in xml.items.item)
			{
				var item:AssetItem = new AssetItem();
				item.parse(node);
				items.push(item);
			}
		}
		
		public function getKey():String
		{
			return String(toXML());
		}
		
	}

}