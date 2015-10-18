package project.m3dexporter.data 
{
	import net.morocoshi.moja3d.loader.exporters.M3DExportOption;
	import project.m3dexporter.Main;
	
	/**
	 * 行データ
	 * 
	 * @author tencho
	 */
	public class ConvertItem 
	{
		public var useCommon:Boolean = true;
		public var localOption:M3DExportOption;
		public var sourceFile:String;
		public var materialFolder:String;
		public var ignoreFolder:Boolean = true;
		
		public var exportModel:Boolean = true;
		public var exportImage:Boolean = true;
		public var exportAnimation:Boolean = true;
		public var fixPngEdge:Boolean = false;
		public var threshold:uint = 10;
		
		public function ConvertItem() 
		{
			localOption = new M3DExportOption();
		}
		
		public function getOption():M3DExportOption 
		{
			var option:M3DExportOption = useCommon? Main.current.user.commonOption : localOption;
			option.exportAnimation = exportAnimation;
			option.exportModel = exportModel;
			option.exportImage = exportImage;
			option.fixImage = fixPngEdge;
			option.fixImageThreshold = threshold;
			option.removeDirectory = ignoreFolder;
			return option;
		}
		
		public function applyFrom(item:ConvertItem):void 
		{
			exportAnimation = item.exportAnimation;
			exportImage = item.exportImage;
			exportModel = item.exportModel;
			materialFolder = item.materialFolder;
			ignoreFolder = item.ignoreFolder;
			fixPngEdge = item.fixPngEdge;
			threshold = item.threshold;
		}
		
	}

}