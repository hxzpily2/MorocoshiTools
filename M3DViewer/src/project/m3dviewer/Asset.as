package project.m3dviewer 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	
	/**
	 * 素材
	 * 
	 * @author tencho
	 */
	public class Asset 
	{
		[Embed(source = "assets/folder.png")] static public var Folder:Class;
		[Embed(source = "assets/option.png")] static public var Option:Class;
		[Embed(source = "assets/play.png")] static public var Play:Class;
		[Embed(source = "assets/pause.png")] static public var Pause:Class;
		[Embed(source = "assets/tree.png")] static public var Tree:Class;
		[Embed(source = "assets/loop.png")] static public var Loop:Class;
		[Embed(source = "assets/stop.png")] static public var Stop:Class;
		[Embed(source = "assets/cube6s.png")] static public var Cube2:Class;
		[Embed(source = "assets/cube7s.png")] static public var Cube4:Class;
		[Embed(source = "assets/grid_s.png")] static public var Grid:Class;
		[Embed(source = "assets/image.png")] static public var Image:Class;
		[Embed(source = "assets/capture.png")] static public var Capture:Class;
		
		static public function image(value:Class, alpha:Number = 1):BitmapData
		{
			var result:BitmapData = Bitmap(new value()).bitmapData;
			result.colorTransform(result.rect, new ColorTransform(1, 1, 1, alpha));
			return result;
		}
		
	}

}