package project.mp3viewer 
{
	import flash.filesystem.File;
	import net.morocoshi.moja3d.bounds.BoundingBox;
	import net.morocoshi.moja3d.loader.M3DParser;
	import net.morocoshi.moja3d.objects.Camera3D;
	
	/**
	 * パース済みのモデルデータとかまとめたもの
	 * 
	 * @author tencho
	 */
	public class ModelData 
	{
		public var file:File;
		public var parser:M3DParser;
		public var bounds:BoundingBox;
		public var maxBound:Number;
		public var parseTime:int;
		
		public function ModelData() 
		{
		}
		
		public function createDefaultCamera():void
		{
			var px:Number = (bounds.minX + bounds.maxX) / 2;
			var py:Number = (bounds.minY + bounds.maxY) / 2;
			var pz:Number = (bounds.minZ + bounds.maxZ) / 2;
			var tx:Number = ((bounds.maxX - bounds.minX) / 2 + 0.01) * 1.5;
			var ty:Number = ((bounds.maxY - bounds.minY) / 2 + 0.01) * 1.5;
			var tz:Number = ((bounds.maxZ - bounds.minZ) / 2 + 0.01) * 1.5;
			var max:Number = Math.max(tx, ty, tz);
			
			var camera:Camera3D = new Camera3D();
			camera.name = "初期カメラ";
			camera.setPositionXYZ(px + max, py - max, pz + max);
			camera.lookAtXYZ(px, py, pz);
			camera.fovX = 90 / 180 * Math.PI;
			camera.fovY = 75 / 180 * Math.PI;
			
			parser.objects.push(camera);
			parser.cameras.unshift(camera);
		}
		
	}

}