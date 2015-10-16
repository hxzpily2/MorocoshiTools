package project.m3dexporter.asset 
{
	import flash.display.BitmapData;
	import net.morocoshi.common.graphics.BitmapUtil;
	import net.morocoshi.common.graphics.Palette;
	
	/**
	 * 素材
	 * 
	 * @author tencho
	 */
	public class Asset 
	{
		[Embed(source = "animation.png")] static public var Animation:Class;
		[Embed(source = "image.png")] static public var Image:Class;
		[Embed(source = "model.png")] static public var Model:Class;
		[Embed(source = "timer.png")] static public var TIMER:Class;
		[Embed(source = "error.png")] static public var ERROR:Class;
		[Embed(source = "ok.png")] static public var OK:Class;
		[Embed(source = "caution.png")] static public var CAUTION:Class;
		
		static public var loadingIcon:BitmapData;
		static public var errorIcon:BitmapData;
		static public var successIcon:BitmapData;
		static public var cautionIcon:BitmapData;
		
		static public function init():void
		{
			var iconSize:int = 16;
			loadingIcon = getImage(TIMER, iconSize, iconSize, 0x000000);
			errorIcon = getImage(ERROR, iconSize, iconSize, 0xff0000);
			successIcon = getImage(OK, iconSize, iconSize, 0x00aa44);
			cautionIcon = getImage(CAUTION, iconSize, iconSize, 0xff8800);
		}
		
		static public function getImage(cls:Class, width:int = 0, height:int = 0, rgb:uint = 0x0):BitmapData
		{
			var image:BitmapData = new cls().bitmapData;
			image.colorTransform(image.rect, Palette.getFillColor(rgb, 1, 1));
			return (width == 0 && height == 0)? image : BitmapUtil.resize(image, width, height);
		}
		
	}

}