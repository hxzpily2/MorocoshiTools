package project.m3dviewer 
{
	import net.morocoshi.moja3d.materials.preset.FillMaterial;
	import net.morocoshi.moja3d.objects.Line3D;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.objects.UnionMesh;
	import net.morocoshi.moja3d.primitives.Cube;
	import net.morocoshi.moja3d.resources.LineSegment;
	
	/**
	 * 手抜きグリッド
	 * 
	 * @author tencho
	 */
	public class GridMesh extends Line3D 
	{
		
		public function GridMesh(width:Number, height:Number, segmentW:int, segmentH:int, thickness:Number) 
		{
			super();
			var rgb:uint = 0xaaaaaa;
			var line:LineSegment;
			for (var ix:int = 0; ix < segmentW + 1; ix++)
			{
				var px:Number = width * (ix / segmentW - 0.5);
				line = lineGeometry.addSegment(thickness);
				line.addPoint(px, -height/2, 0, rgb, 1);
				line.addPoint(px, height/2, 0, rgb, 1);
			}
			for (var iy:int = 0; iy < segmentH + 1; iy++)
			{
				var py:Number = height * (iy / segmentH - 0.5);
				line = lineGeometry.addSegment(thickness);
				line.addPoint(-width/2, py, 0, rgb, 1);
				line.addPoint(width/2, py, 0, rgb, 1);
			}
		}
		
	}

}