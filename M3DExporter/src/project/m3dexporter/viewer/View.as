package project.m3dexporter.viewer 
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.ComboBox;
	import com.bit101.components.HBox;
	import com.bit101.components.PushButton;
	import com.bit101.components.VBox;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display3D.Context3DProfile;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filters.GlowFilter;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import net.morocoshi.air.components.minimal.Modal;
	import net.morocoshi.air.files.FileUtil;
	import net.morocoshi.air.files.LocalFile;
	import net.morocoshi.common.graphics.Create;
	import net.morocoshi.common.graphics.Draw;
	import net.morocoshi.common.loaders.tfp.events.TFPErrorEvent;
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.common.optimization.frameskip.FrameSkipper;
	import net.morocoshi.components.minimal.Bit101Util;
	import net.morocoshi.components.minimal.layout.LayoutCell;
	import net.morocoshi.moja3d.agal.AGALCache;
	import net.morocoshi.moja3d.bounds.BoundingBox;
	import net.morocoshi.moja3d.config.LightSetting;
	import net.morocoshi.moja3d.filters.OutlineFilter3D;
	import net.morocoshi.moja3d.loader.animation.AnimationDebugger;
	import net.morocoshi.moja3d.loader.M3DParser;
	import net.morocoshi.moja3d.loader.materials.M3DMaterial;
	import net.morocoshi.moja3d.materials.Material;
	import net.morocoshi.moja3d.materials.preset.FillMaterial;
	import net.morocoshi.moja3d.objects.AmbientLight;
	import net.morocoshi.moja3d.objects.Bone;
	import net.morocoshi.moja3d.objects.Camera3D;
	import net.morocoshi.moja3d.objects.DirectionalLight;
	import net.morocoshi.moja3d.objects.Mesh;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.primitives.Cube;
	import net.morocoshi.moja3d.renderer.MaskLayer;
	import net.morocoshi.moja3d.resources.ExternalTextureResource;
	import net.morocoshi.moja3d.resources.Resource;
	import net.morocoshi.moja3d.resources.TextureResource;
	import net.morocoshi.moja3d.resources.TextureResourceLoader;
	import net.morocoshi.moja3d.view.Scene3D;
	import project.m3dexporter.viewer.MaterialEditor;
	import project.m3dexporter.Main;
	import project.m3dexporter.viewer.TreeWindow;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class View extends LayoutCell
	{
		private var isReady:Boolean = false;
		private var isInit:Boolean = false;
		private var complete:Function;
		private var currentData:ByteArray;
		private var parseButton:PushButton;
		
		private var parser:M3DParser;
		private var objects:Vector.<Object3D>;
		private var container:Object3D;
		private var lightContainer:Object3D;
		private var sunLight:DirectionalLight;
		private var subLight:DirectionalLight;
		private var ambientLight:AmbientLight;
		
		public var scene:Scene3D;
		public var onLog:Function;
		public var shaderManager:ShaderManager;
		
		private var debugger:AnimationDebugger;
		private var skipper:FrameSkipper;
		private var asset:Object;
		private var currentFile:File;
		private var materialPath:String;
		private var resentFiles:Array;
		
		private var time:Number = 0;
		private var tempTime:int;
		private var filesComboBox:ComboBox;
		private var mousePlane:Sprite;
		private var specularCheck:CheckBox;
		private var verteexColorCheck:CheckBox;
		private var lambertCheck:CheckBox;
		private var lightCheck:CheckBox;
		private var frameSkipper:FrameSkipper;
		private var cameraComboBox:ComboBox;
		private var firstMeshCamera:Camera3D;
		private var parseContainer:Sprite;
		private var materialManager:MaterialEditor;
		private var boneMesh:Mesh;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function View() 
		{
			super();
			
			boneMesh = new Cube(1, 1, 1, 1, 1, 1, new FillMaterial(0xff0000, 1, true));
			
			resentFiles = [];
			shaderManager = new ShaderManager();
			
			asset = { };
			skipper = new FrameSkipper();
			skipper.targetFPS = 60;
			skipper.enabled = false;
			
			debugger = new AnimationDebugger();
			debugger.sprite.y = 200;
			debugger.sprite.scaleY *= -1;
			
			LightSetting.numDirectionalLights = 4;
			scene = new Scene3D();
			parseContainer = new Sprite();
			parseButton = new PushButton(null, 0, 0, "モデルをパース", parseButton_clickHandler);
			parseButton.width = 120;
			parseButton.visible = false;
			
			mousePlane = Create.box(0, 0, 100, 100, 0, 0);
			scene.setFPVController(mousePlane, false, 10, 100, -100, 100);
			scene.fpv.lookAtXYZ(0, 0, 0);
			
			addChild(mousePlane);
			addChild(parseContainer);
			addChild(scene.stats);
			addChild(debugger.sprite);
			parseContainer.addChild(parseButton);
			
			isReady = true;
			objects = new Vector.<Object3D>;
			var box:HBox = new HBox(this, 5, 5);
			new PushButton(box, 0, 0, "ツリー構造", showTree_clickHandler).width = 100;
			new PushButton(box, 0, 0, "テクスチャリサイズ", materialManager_clickHandler).width = 135;
			
			var vbox:VBox = new VBox(this, 5, 35);
			vbox.spacing = 7;
			vbox.filters = [new GlowFilter(0xffffff, 1, 5, 5, 100, 1)];
			
			lightCheck = new CheckBox(vbox, 0, 0, "平行光源", updateShader);
			lightCheck.selected = true;
			scene.stats.addFrameSkipCheck(skipper)
			//scene.stats.addShaderCheck(shaderManager.lambert, "ランバート", true);
			//scene.stats.addShaderCheck(shaderManager.specular, "スペキュラ", false);
			//scene.stats.addShaderCheck(shaderManager.vertexColor, "頂点カラー", false);
			//refrectionCheck = scene.stats.addShaderListCheck(shaderManager.reflections, "鏡面反射", true);
			//refrectionCheck = scene.stats.addShaderListCheck(shaderManager.sphereMaps, "スフィアマップ", true);
			
			updateShader();
			
			filesComboBox = new ComboBox(box, 0, 0, "最近変換したファイル", []);
			filesComboBox.width = 150;
			filesComboBox.addEventListener(Event.SELECT, convertedFiled_selectHandler);
			
			cameraComboBox = new ComboBox(box, 0, 0, "カメラ", []);
			cameraComboBox.width = 120;
			cameraComboBox.addEventListener(Event.SELECT, camera_selectHandler);
			Bit101Util.adjustComboList(cameraComboBox, 10);
		}
		
		override public function set y(value:Number):void
		{
			super.y = value;
			if (scene)
			{
				scene.view.y = y;
				scene.view.x = parent.parent.x;
			}
		}
		
		private function materialManager_clickHandler(e:Event):void 
		{
			if (materialManager == null)
			{
				materialManager = new MaterialEditor(stage.nativeWindow);
			}
			materialManager.open(currentFile, scene.root.getResources(true, TextureResource), scene.context3D);
		}
		
		private function camera_selectHandler(e:Event):void 
		{
			if (cameraComboBox.selectedItem == null) return;
			
			setCamera(cameraComboBox.selectedItem.camera);
		}
		
		private function setCamera(camera:Camera3D):void
		{
			scene.fpv.position = camera.getPosition();
			scene.fpv.lookAt(scene.fpv.position.subtract(camera.getWorldAxisZ(false)));
			
			scene.camera.fovY = camera.fovY;
			scene.camera.fovX = camera.fovX;
		}
		
		private function updateShader(e:Event = null):void 
		{
			if (sunLight)
			{
				sunLight.visible = lightCheck.selected;
				subLight.visible = lightCheck.selected;
			}
		}
		
		private function convertedFiled_selectHandler(e:Event):void 
		{
			if (filesComboBox.selectedItem == null) return;
			
			var path:String = filesComboBox.selectedItem.path;
			var file:File = FileUtil.toFile(path);
			if (file == null || file.exists == false)
			{
				Modal.alert(path + "が見つかりません。");
				VectorUtil.deleteItem(resentFiles, path);
				setConvertedFiles(resentFiles);
				VectorUtil.copy(resentFiles, Main.current.user.convertedFiles);
				return;
			}
			
			onLog(path + "を開いています。");
			setF3DByteArray(file, Main.current.fileSelector.materialPath, true);
		}
		
		private function disposeModels_clickHandler(e:Event):void 
		{
			disposeModels();
		}
		
		/**
		 * アニメーション
		 * @param	e
		 */
		private function enterFrameHandler(e:Event):void 
		{
			skipper.calculate(calc);
			skipper.draw(render);
		}
		
		private function calc():void 
		{
			var step:Number = 1 / 60;
			time = (time + step);// % (200 * step);
		}
		
		private function render():void 
		{
			if (parser == null) return;
			
			parser.animationPlayer.setTime(time);
			scene.render();
		}
		
		/**
		 * 初期化
		 * @param	stage
		 * @param	complete
		 */
		public function build(stage:Stage, complete:Function):void
		{
			this.complete = complete;
			
			scene.addEventListener(Event.COMPLETE, completeHandler);
			scene.init(stage.stage3Ds[0], "auto", Context3DProfile.BASELINE_EXTENDED);
			scene.view.antiAlias = 2;
			scene.camera.zNear = 0.2;
			scene.camera.zFar = 100000;
			scene.camera.orthographic = false;
			scene.view.backgroundColor = 0x303030;
			
			firstMeshCamera = new Camera3D();
			
			var outline:OutlineFilter3D = new OutlineFilter3D();
			outline.addElement(MaskLayer.RED, 0xff0000, 1);
			scene.filters.push(outline);
			//scene.overlay.addChild(new Image2D(200, 200, scene.postEffect.maskTexture));
			
			container = new Object3D();
			container.name = "Object Container";
			lightContainer = new Object3D();
			lightContainer.name = "Light Container";
			
			ambientLight = new AmbientLight(0xffffff, 0.4);
			sunLight = new DirectionalLight(0xffffff, 0.8);
			sunLight.setPositionXYZ(100, 150, 120);
			sunLight.lookAtXYZ(0, 0, 0, null);
			subLight = new DirectionalLight(0xffffff, 0.3);
			subLight.setPositionXYZ(-100, -150, 120);
			subLight.lookAtXYZ(0, 0, 0, null);
			
			lightContainer.addChild(ambientLight);
			lightContainer.addChild(sunLight);
			lightContainer.addChild(subLight);
			updateShader();
			
			scene.root.addChild(container);
			scene.root.addChild(lightContainer);
		}
		
		/**
		 * Object3D階層表示
		 * @param	e
		 */
		private function showTree_clickHandler(e:Event):void 
		{
			var win:TreeWindow = new TreeWindow();
			win.setObject3DTree(scene.root);
			win.activate();
		}
		
		
		private function completeHandler(e:Event):void 
		{
			isInit = true;
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			complete();
		}
		
		/**
		 * モデルデータを渡して、パース開始ボタンを表示する
		 * @param	ba
		 * @param	basePath
		 * @param	autoParse
		 */
		public function setF3DByteArray(modelFile:File, materialPath:String, autoParse:Boolean):void 
		{
			if (!isInit) return;
			
			this.materialPath = materialPath;
			currentFile = modelFile;
			currentData = LocalFile.readByteArray(modelFile);
			parseButton.visible = true;
			if (autoParse)
			{
				parse();
			}
		}
		
		/**
		 * currentData（ByteArray）でパース開始
		 */
		private function parse():void 
		{
			parseButton.visible = false;
			
			disposeModels();
			
			tempTime = getTimer();
			
			scene.camera.fovX = 80 / 180 * Math.PI;
			scene.camera.fovY = 60 / 180 * Math.PI;
			shaderManager.sphereMaps.length = 0;
			parser = new M3DParser();
			parser.addEventListener(Event.COMPLETE, parser_completeHandler);
			parser.bezierCurveInterval = 1.0 / 15;
			parser.parse(currentData);
		}
		
		/**
		 * 
		 */
		private function disposeModels():void 
		{
			while (container.children)
			{
				var child:Object3D = container.children;
				child.remove();
				child.dispose(true);
			}
			scene.billboard.removeAllObject();
		}
		
		private function parser_completeHandler(e:Event):void 
		{
			M3DParser(e.currentTarget).removeEventListener(Event.COMPLETE, parser_completeHandler);
			
			onLog("パースに" + String(getTimer() - tempTime) + "ミリ秒かかりました。");
			
			var i:int;
			var n:int;
			var mesh:Mesh;
			
			cameraComboBox.removeAll();
			cameraComboBox.addItem( { label:"初期位置", camera:firstMeshCamera } );
			
			var boundsList:Vector.<BoundingBox> = new Vector.<BoundingBox>;
			n = parser.objects.length;
			for (i = 0; i < n; i++) 
			{
				var object:Object3D = parser.objects[i];
				if (object is Camera3D)
				{
					cameraComboBox.addItem( { label:object.name, camera:object } );
				}
				
				if (object is Mesh)
				{
					mesh = object as Mesh;
					if (mesh.name.indexOf("!") != -1)
					{
						mesh.renderable = false;
					}
					mesh.updateBounds();
					boundsList.push(mesh.boundingBox);
				}
			}
			Bit101Util.adjustComboList(cameraComboBox, 10);
			cameraComboBox.selectedIndex = -1;
			
			var total:BoundingBox = BoundingBox.getUniondSphereBox(boundsList);
			if (total)
			{
				calcFiestMeshCamera(total);
				var boundSize:Vector3D = new Vector3D(total.maxX - total.minX, total.maxY - total.minY, total.maxZ - total.minZ);
				var maxSize:Number = Math.max(boundSize.x, boundSize.y, boundSize.z);
				scene.fpv.moveSpeed = maxSize * 0.01;
			}
			else
			{
				scene.fpv.moveSpeed = 5;
			}
			
			var obj:Object3D;
			n = parser.hierarchy.length;
			for (i = 0; i < n; i++) 
			{
				obj = parser.hierarchy[i];
				container.addChild(obj);
			}
			
			shaderManager.reflections.length = 0;
			
			//Objectのユーザーデータを取得して表示に反映
			n = parser.objects.length;
			for (i = 0; i < n; i++) 
			{
				obj = parser.objects[i];
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
					scene.billboard.addObject(obj, pivot, plane, fAxis, tAxis);
				}
				
				mesh = obj as Mesh;
				
				if (Main.current.user.menuOption.autoResetCamera)
				{
					setCamera(firstMeshCamera);
				}
			}
			
			objects = parser.objects;
			
			container.upload(scene.context3D, true, true);
			
			var resources:Vector.<Resource> = container.getResources(true, ExternalTextureResource);
			
			if (!parser.resourcePack)
			{
				var basePath:String = FileUtil.url(currentFile.parent.resolvePath(materialPath));
				var loader:TextureResourceLoader = new TextureResourceLoader();
				loader.addEventListener(TFPErrorEvent.INSTANTIATION_ERROR, instantiation_errorHandler);
				loader.addEventListener(TFPErrorEvent.LOAD_ERROR, material_errorHandler);
				loader.upload(basePath, scene.context3D, resources, false);
			}
			
			//アニメーションカーブの描画
			//debugger.parse(parser);
			
			updateShader();
		}
		
		private function instantiation_errorHandler(e:TFPErrorEvent):void 
		{
			onLog("マテリアル画像のインスタンス化に失敗しました。");
		}
		
		private function material_errorHandler(e:TFPErrorEvent):void 
		{
			onLog("マテリアル画像の読み込みに失敗したファイルが" + e.errorEventList.length + "個あります。");
		}
		
		/**
		 * 
		 * @param	material
		 * @return
		 */
		private function onConvertMaterial(material:M3DMaterial):Material 
		{
			var m:Material = new Material();
			m.name = material.name;
			material.addDiffuseShaderTo(m.shaderList);
			m.shaderList.addShader(shaderManager.fresnel);
			m.shaderList.addShader(shaderManager.vertexColor);
			m.shaderList.addShader(shaderManager.lambert);
			m.shaderList.addShader(shaderManager.environment);
			m.shaderList.addShader(shaderManager.specular);
			
			/*
			if (material.normalPath)
			{
				m.shaderList.addShader(new NormalMapShader(new ExternalTextureResource(material.normalPath), 0.5));
			}
			*/
			/*
			var opacity:ExternalTextureResource = material.opacityPath? new ExternalTextureResource(material.opacityPath) : null;
			if (material.diffusePath)
			{
				var diffuse:ExternalTextureResource = new ExternalTextureResource(material.diffusePath);
				m.shaderList.addShader(new TextureShader(diffuse, opacity, material.alpha, Mipmap.MIPLINEAR, Smoothing.LINEAR, Tiling.WRAP));
			}
			else
			{
				m.shaderList.addShader(new FillShader(material.diffuseColor, material.alpha));
				if (opacity)
				{
					m.shaderList.addShader(new OpacityShader(opacity, Mipmap.MIPLINEAR, Smoothing.LINEAR, Tiling.WRAP));
				}
			}
			*/
			
			/*
			m.shaderList.addShader(shaderManager.vertexColor);
			m.shaderList.addShader(shaderManager.lambert);
			if (material.reflectionPath)
			{
				var reflectiveTexture:ExternalTextureResource = new ExternalTextureResource(material.reflectionPath);
				var sphereMap:SphereMapShader = new SphereMapShader(reflectiveTexture, material.reflectionFactor, BlendMode.ADD, true, false);
				shaderManager.sphereMaps.push(sphereMap);
				m.shaderList.addShader(sphereMap);
			}
			m.shaderList.addShader(shaderManager.specular);
			*/
			
			return m;
		}
		
		private function material_completeHandler():void 
		{
		}
		
		private function checkOptimizable(obj:Object3D):Boolean 
		{
			var user:Object = parser.getUserData(obj);
			if (parser.equalAncestorUserData(obj, "sky", true)) return false;
			return obj as Mesh && obj.visible;
		}
		
		private function calcFiestMeshCamera(bb:BoundingBox):void
		{
			var px:Number = (bb.minX + bb.maxX) / 2;
			var py:Number = (bb.minY + bb.maxY) / 2;
			var pz:Number = (bb.minZ + bb.maxZ) / 2;
			var tx:Number = ((bb.maxX - bb.minX) / 2 + 0.01) * 1.1;
			var ty:Number = ((bb.maxY - bb.minY) / 2 + 0.01) * 1.1;
			var tz:Number = ((bb.maxZ - bb.minZ) / 2 + 0.01) * 1.1;
			var max:Number = Math.max(tx, ty, tz);
			firstMeshCamera.setPositionXYZ(px + max, py - max, pz + max);
			firstMeshCamera.lookAtXYZ(px, py, pz);
			
			firstMeshCamera.fovX = 60 / 180 * Math.PI;
			firstMeshCamera.fovY = 40 / 180 * Math.PI;
		}
		
		private function errorHandler(e:ErrorEvent):void 
		{
			onLog(e.text);
		}
		
		private function parseButton_clickHandler(e:Event):void 
		{
			AGALCache.clear();
			parse();
		}
		
		override public function setSize(w:Number, h:Number):void 
		{
			if (!isReady) return;
			
			super.setSize(w, h);
			Draw.box(mousePlane.graphics, 0, 0, w, h, 0x0, 0);
			scene.view.setSize(w, h);
			parseButton.x = (w - parseButton.width) * 0.5 | 0;
			parseButton.y = (h - parseButton.height) * 0.5 | 0;
			var scale:Number = 0.5;
			scene.view.setSize(w, h);
			scene.camera.width = w * scale;
			scene.camera.height = h * scale;
			scene.stats.x = w - scene.stats.width;
		}
		
		public function setConvertedFiles(files:Array):void 
		{
			VectorUtil.copy(files, resentFiles);
			filesComboBox.removeAll();
			var n:int = files.length;
			for (var i:int = 0; i < n; i++) 
			{
				var url:String = files[i];
				filesComboBox.addItem( { label:FileUtil.getFileID(url), path:url } );
			}
			Bit101Util.adjustComboList(filesComboBox, 10);
		}
		
	}

}