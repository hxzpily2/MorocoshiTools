package project.m3dviewer 
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	import net.morocoshi.air.components.minimal.Modal;
	import net.morocoshi.air.files.LocalFile;
	import net.morocoshi.moja3d.bounds.BoundingBox;
	import net.morocoshi.moja3d.loader.M3DParser;
	import net.morocoshi.moja3d.materials.preset.FillMaterial;
	import net.morocoshi.moja3d.objects.Bone;
	import net.morocoshi.moja3d.objects.Mesh;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.primitives.Cube;
	
	/**
	 * M3D読み込み＆パース
	 * 
	 * @author tencho
	 */
	public class Loader 
	{
		public var onParse:Function;
		
		private var boneMesh:Cube;
		private var modelData:ModelData;
		private var parser:M3DParser;
		private var tempTime:int;
		private var _isLoading:Boolean;
		
		public function Loader() 
		{
			_isLoading = false;
			boneMesh = new Cube(1, 1, 1, 1, 1, 1, new FillMaterial(0xffee00, 1, true));
		}
		
		public function load(file:File):void
		{
			_isLoading = true;
			tempTime = getTimer();
			modelData = new ModelData();
			modelData.file = file;
			
			parser = modelData.parser = new M3DParser();
			parser.addEventListener(ErrorEvent.ERROR, parser_errorHandler);
			parser.addEventListener(Event.COMPLETE, parser_completeHandler);
			parser.bezierCurveInterval = 1.0 / 15;
			parser.parse(LocalFile.readByteArray(file));
		}
		
		private function parser_errorHandler(e:ErrorEvent):void 
		{
			_isLoading = false;
			Modal.alert(e.text);
		}
		
		private function parser_completeHandler(e:Event):void 
		{
			parser.removeEventListener(Event.COMPLETE, parser_completeHandler);
			
			var i:int;
			var n:int;
			
			var obj:Object3D;
			var boneThicknessList:Array = [];
			var topBoneList:Vector.<Mesh> = new Vector.<Mesh>;
			
			//Objectのユーザーデータを取得して表示に反映
			
			var container:Object3D = new Object3D();
			n = parser.hierarchy.length;
			for (i = 0; i < n; i++) 
			{
				container.addChild(parser.hierarchy[i]);
			}
			
			n = parser.objects.length;
			for (i = 0; i < n; i++) 
			{
				obj = parser.objects[i];
				/*
				var userData:Object = obj.userData;
				
				if (userData.billboard)
				{
					var fAxis:String;
					var tAxis:String;
					if (userData.axis)
					{
						fAxis = userData.axis.substr(0, 2);
						tAxis = userData.axis.substr(2);
					}
					else
					{
						onLog(obj, "がビルボード化されていますが、axisプロパティがありません！");
						fAxis = "-y";
						tAxis = "+z";
					}
					var pivot:Boolean = false;
					var plane:Boolean = true;
					switch(userData.billboard)
					{
						case "pivotPlane":
							pivot = true;
							plane = true;
							break;
						case "pivotPoint":
							pivot = true;
							plane = false;
							break;
						case "cameraPlane":
							pivot = false;
							plane = true;
							break;
						case "cameraPoint":
							pivot = false;
							plane = false;
							break;
						default:
							onLog(obj + "がビルボード化されていますが、「" + userData.billboard + "」は有効な値ではありません！");
					}
					//scene.billboard.addObject(obj, pivot, plane, fAxis, tAxis);
				}
				*/
				if (obj is Bone && !parser.hasModel)
				{
					var children:Vector.<Object3D> = obj.getChildren(false, false, Bone);
					if (children.length > 0)
					{
						for each (var item:Object3D in children) 
						{
							var bone:Mesh = boneMesh.reference() as Mesh;
							obj.addChild(bone);
							
							var position:Vector3D = item.getPosition();
							position.scaleBy(0.5);
							bone.setPosition3D(position);
							bone.lookAt3D(item.getPosition());
							bone.scaleY = position.length * 2;
							var boneThickness:Number = bone.scaleY * 0.2;
							bone.scaleX = boneThickness;
							bone.scaleZ = boneThickness;
							boneThicknessList.push(boneThickness);
						}
					}
					else
					{
						var bone2:Mesh = boneMesh.reference() as Mesh;
						obj.addChild(bone2);
						topBoneList.push(bone2);
					}
				}
			}
			
			var avaThickness:Number = 0;
			for each(var thickness:Number in boneThicknessList)
			{
				avaThickness += thickness;
			}
			avaThickness /= boneThicknessList.length;
			for each(var topBone:Mesh in topBoneList)
			{
				topBone.setScale(avaThickness);
			}
			
			//ばうんでぃんぐぼっくすからカメラ位置計算
			var boundsList:Vector.<BoundingBox> = new Vector.<BoundingBox>;
			n = parser.objects.length;
			for each(var mesh:Mesh in container.getChildren(false, true, Mesh))
			{
				mesh.updateBounds();
				boundsList.push(mesh.boundingBox);
			}
			var total:BoundingBox = BoundingBox.getUniondSphereBox(boundsList);
			if (total == null)
			{
				total = new BoundingBox();
				total.setSphere(100);
			}
			modelData.bounds = total;
			modelData.maxBound = Math.max(modelData.bounds.maxX - modelData.bounds.minX, modelData.bounds.maxY - modelData.bounds.minY, modelData.bounds.maxZ - modelData.bounds.minZ);
			modelData.createDefaultCamera();
			modelData.parseTime = getTimer() - tempTime;
			
			_isLoading = false;
			onParse(modelData);
		}
		
		public function get isLoading():Boolean 
		{
			return _isLoading;
		}
	}

}