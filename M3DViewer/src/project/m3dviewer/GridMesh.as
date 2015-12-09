package project.m3dviewer 
{
	import net.morocoshi.moja3d.materials.preset.FillMaterial;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.objects.UnionMesh;
	import net.morocoshi.moja3d.primitives.Cube;
	
	/**
	 * 手抜きグリッド
	 * 
	 * @author tencho
	 */
	public class GridMesh extends UnionMesh 
	{
		
		public function GridMesh(width:Number, height:Number, segmentW:int, segmentH:int, thickness:Number) 
		{
			super();
			var line:Cube;
			var fill:FillMaterial = new FillMaterial(0xaaaaaa, 1, true);
			for (var ix:int = 0; ix < segmentW + 1; ix++)
			{
				line = new Cube(thickness, height, thickness, 1, 1, 1, fill);
				line.x = (width - thickness) * (ix / (segmentW) - 0.5);
				addChild(line);
			}
			for (var iy:int = 0; iy < segmentH + 1; iy++) 
			{
				line = new Cube(width, thickness, thickness, 1, 1, 1, fill);
				line.y = (height - thickness) * (iy / (segmentH) - 0.5);
				addChild(line);
			}
			
			updateSurface();
		}
		
	}

}