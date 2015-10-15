package project.mp3viewer 
{
	import flash.display.Stage;
	import flash.display3D.Context3DProfile;
	import flash.events.Event;
	import net.morocoshi.air.components.minimal.Modal;
	import net.morocoshi.air.files.FileUtil;
	import net.morocoshi.common.loaders.tfp.events.TFPErrorEvent;
	import net.morocoshi.moja3d.agal.AGALCache;
	import net.morocoshi.moja3d.config.LightSetting;
	import net.morocoshi.moja3d.objects.AmbientLight;
	import net.morocoshi.moja3d.objects.Camera3D;
	import net.morocoshi.moja3d.objects.DirectionalLight;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.resources.ExternalTextureResource;
	import net.morocoshi.moja3d.resources.Resource;
	import net.morocoshi.moja3d.resources.TextureResourceLoader;
	import net.morocoshi.moja3d.view.Scene3D;
	
	/**
	 * 3D画面
	 * 
	 * @author tencho
	 */
	public class View
	{
		private var isReady:Boolean = false;
		private var stage:Stage;
		
		public var scene:Scene3D;
		public var onInit:Function;
		private var _gridVisible:Boolean;
		
		private var modelContainer:Object3D;
		private var lightContainer:Object3D;
		private var sunLight:DirectionalLight;
		private var subLight:DirectionalLight;
		private var ambientLight:AmbientLight;
		private var gridMesh:GridMesh;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function View(stage:Stage) 
		{
			this.stage = stage;
			isReady = false;
			_gridVisible = true;
			
			LightSetting.numDirectionalLights = 2;
			LightSetting.numDirectionalShadow = 0;
			LightSetting.numOmniLights = 0;
			
			scene = new Scene3D();
			scene.view.antiAlias = 3;
			scene.view.backgroundColor = 0x303030;
			scene.view.startAutoResize(stage);
			//scene.setFPVController(Main.current.background, false, 10, 500, -500, 500);
			scene.setTPVController(Main.current.background, -45, 30, 500);
			scene.camera.zNear = 0.2;
			scene.camera.zFar = 100000;
			
			//var outline:OutlineFilter3D = new OutlineFilter3D();
			//outline.addElement(MaskLayer.RED, 0xff0000, 1);
			//scene.filters.push(outline);
			
			build();
		}
		
		public function init():void 
		{
			scene.addEventListener(Event.COMPLETE, scene_completeHandler);
			scene.init(stage.stage3Ds[0], "auto", Context3DProfile.BASELINE_EXTENDED);
		}
		
		private function scene_completeHandler(e:Event):void 
		{
			scene.removeEventListener(Event.COMPLETE, scene_completeHandler);
			
			scene.root.upload(scene.context3D, true, false);
			scene.startRendering();
			
			onInit();
		}
		
		private function setCamera(camera:Camera3D):void
		{
			//scene.tpv.position = camera.getPosition();
			//scene.tpv.gazeAt(scene.tpv.position.subtract(camera.getWorldAxisZ(false)), true);
			
			scene.camera.fovY = camera.fovY;
			scene.camera.fovX = camera.fovX;
		}
		
		/**
		 * 初期化
		 * @param	stage
		 */
		public function build():void
		{
			modelContainer = new Object3D();
			modelContainer.name = "Object Container";
			lightContainer = new Object3D();
			lightContainer.name = "Light Container";
			gridMesh = new GridMesh(1000, 1000, 10, 10, 1);
			
			ambientLight = new AmbientLight(0xffffff, 0.5);
			sunLight = new DirectionalLight(0xffffff, 1.3);
			sunLight.setPositionXYZ(100, 150, 120);
			sunLight.lookAtXYZ(0, 0, 0, null);
			subLight = new DirectionalLight(0xffffff, 0.3);
			subLight.setPositionXYZ(-100, -150, 120);
			subLight.lookAtXYZ(0, 0, 0, null);
			
			lightContainer.addChild(ambientLight);
			lightContainer.addChild(sunLight);
			lightContainer.addChild(subLight);
			
			scene.root.addChild(modelContainer);
			scene.root.addChild(lightContainer);
			scene.root.addChild(gridMesh);
			
		}
		
		/**
		 * モデルデータを渡して、パース開始ボタンを表示する
		 */
		public function setModelData(modelData:ModelData):void 
		{
			disposeModels();
			AGALCache.clear();
			
			scene.camera.fovX = 90 / 180 * Math.PI;
			scene.camera.fovY = 75 / 180 * Math.PI;
			gridMesh.setScale(modelData.maxBound / 1000 * 1.5);
			gridMesh.setPosition3D(modelData.bounds.getCenterPoint());
			gridMesh.z = 0;
			scene.camera.zFar = modelData.maxBound * 12;
			scene.camera.zNear = scene.camera.zFar * 0.00001;
			
			for each(var object:Object3D in modelData.parser.hierarchy)
			{
				modelContainer.addChild(object);
			}
			
			var resources:Vector.<Resource> = modelContainer.getResources(true, ExternalTextureResource);
			
			if (modelData.parser.resourcePack == null)
			{
				var basePath:String = FileUtil.url(modelData.file.parent);
				var loader:TextureResourceLoader = new TextureResourceLoader();
				loader.addEventListener(TFPErrorEvent.INSTANTIATION_ERROR, instantiation_errorHandler);
				loader.addEventListener(TFPErrorEvent.LOAD_ERROR, material_errorHandler);
				loader.upload(basePath, scene.context3D, resources, false);
			}
			
			scene.tpv.gazeAt(modelData.bounds.getCenterPoint(), false);
			scene.tpv.distance.min = 0.01;
			scene.tpv.distance.max = modelData.maxBound * 1.0 * 10;
			scene.tpv.setDistance(modelData.maxBound * 1.0);
			scene.tpv.notify();
			//setCamera(modelData.parser.cameras[0]);
			//scene.fpv.moveSpeed = modelData.maxBound * 0.02;
			scene.root.upload(scene.context3D, true, false);
		}
		
		private function instantiation_errorHandler(e:TFPErrorEvent):void 
		{
			Modal.alert("マテリアル画像のインスタンス化に失敗しました！");
		}
		
		private function material_errorHandler(e:TFPErrorEvent):void 
		{
			//onLog("マテリアル画像の読み込みに失敗したファイルが" + e.errorEventList.length + "個あります。");
		}
		
		private function disposeModels():void 
		{
			while (modelContainer.children)
			{
				var child:Object3D = modelContainer.children;
				child.remove();
				child.dispose(true);
			}
			scene.billboard.removeAllObject();
		}
		
		public function setSize(w:int, h:int):void 
		{
			if (!isReady) return;
			
			scene.stats.x = w - scene.stats.width;
		}
		
		public function set lightEnabled(value:Boolean):void 
		{
			if (sunLight)
			{
				sunLight.visible = value;
				subLight.visible = value;
				ambientLight.intensity = value? 0.4 : 1.0;
			}
		}
		
		public function get gridVisible():Boolean 
		{
			return _gridVisible;
		}
		
		public function set gridVisible(value:Boolean):void 
		{
			gridMesh.visible = _gridVisible = value;
		}
	}

}