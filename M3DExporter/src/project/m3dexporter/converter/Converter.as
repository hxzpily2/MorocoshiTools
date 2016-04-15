package project.m3dexporter.converter 
{
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.PNGEncoderOptions;
	import flash.events.ProgressEvent;
	import flash.events.TextEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import net.morocoshi.air.files.FileUtil;
	import net.morocoshi.air.files.LocalFile;
	import net.morocoshi.common.data.ByteArrayUtil;
	import net.morocoshi.common.graphics.BitmapUtil;
	import net.morocoshi.common.graphics.EdgeExtruder;
	import net.morocoshi.common.loaders.ClassAliasUtil;
	import net.morocoshi.common.loaders.collada.ColladaParser;
	import net.morocoshi.common.loaders.collada.nodes.ColladaScene;
	import net.morocoshi.common.loaders.fbx.FBXParseCollector;
	import net.morocoshi.common.loaders.fbx.FBXParser;
	import net.morocoshi.common.loaders.fbx.FBXScene;
	import net.morocoshi.common.loaders.fbx.events.FBXEvent;
	import net.morocoshi.common.loaders.tfp.TFPAssetType;
	import net.morocoshi.common.loaders.tfp.TFPConverter;
	import net.morocoshi.common.loaders.tfp.TFPFile;
	import net.morocoshi.common.loaders.tfp.TFPFolder;
	import net.morocoshi.common.loaders.tfp.TFPLibrary;
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.common.timers.FrameTimer;
	import net.morocoshi.moja3d.loader.M3DInfo;
	import net.morocoshi.moja3d.loader.M3DScene;
	import net.morocoshi.moja3d.loader.exporters.M3DColladaExporter;
	import net.morocoshi.moja3d.loader.exporters.M3DExportOption;
	import net.morocoshi.moja3d.loader.exporters.M3DFBXExporter;
	import net.morocoshi.moja3d.loader.materials.M3DMaterial;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class Converter 
	{
		private var fbxScene:FBXScene;
		private var m3dScene:M3DScene;
		private var file:File;
		private var option:M3DExportOption;
		private var collector:FBXParseCollector;
		private var imageDir:File;
		private var tfplib:TFPLibrary;
		public var errorList:Array;
		
		public var onLog:Function;
		public var onProgress:Function;
		public var onError:Function;
		public var onComplete:Function;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function Converter() 
		{
		}
		
		public function convert(file:File, option:M3DExportOption, imageDir:File, output:File):void
		{
			errorList = [];
			
			this.output = output;
			this.file = file;
			this.option = option;
			this.imageDir = imageDir;
			if (!file || !file.exists)
			{
				addError("変換するファイルが見つかりません。");
				onError();
				return;
			}
			
			var str:String = LocalFile.readUTFBytes(file);
			
			var ext:String = file.extension.toLowerCase();
			if (ext == "dae")
			{
				onLog("Colladaパース開始......");
				
				FrameTimer.setTimer(2, convertCollada, [new XML(str)]);
			}
			
			if (ext == "fbx")
			{
				onLog("FBXパース開始......");
				
				fbxParser = new FBXParser();
				fbxParser.addEventListener(ProgressEvent.PROGRESS, scene_progressHandler);
				fbxParser.addEventListener(FBXEvent.COMPLETE_PARSE_SCENE, scene_completeHandler);
				
				collector = new FBXParseCollector();
				collector.option.addAnimation = option.exportAnimation;
				collector.option.autoMaterialRepeat = option.autoRepeat;
				collector.option.simpleTangent4 = false;
				collector.option.repeatMargin = 0.001;
				collector.option.deleteNormal = !option.exportNormal;
				collector.option.deleteTangent4 = !option.exportTangent4;
				collector.option.deleteUV = !option.exportUV;
				collector.option.deleteVertexColor = !option.exportVertexColor;
				
				fbxParser.parseScene(str, collector);
			}
		}
		
		private function convertCollada(xml:XML):void 
		{
			var colladaParser:ColladaParser = new ColladaParser();
			var colladaScene:ColladaScene = colladaParser.parse(xml, option.toColladaOption());
			errorList = errorList.concat(colladaParser.collector.getMiscLogList());
			onLog("完了！");
			onLog("==========================================");
			var log:String = colladaParser.collector.getLog();
			if (log)
			{
				onLog(log.substr(0, log.length - 1));
			}
			onLog("==========================================");
			
			var exporter:M3DColladaExporter = new M3DColladaExporter();
			var m3dScene:M3DScene = exporter.convert(colladaScene, option);
			saveM3DScene(m3dScene);
		}
		
		private function addError(text:String):void
		{
			errorList.push(text);
		}
		
		private function scene_progressHandler(e:ProgressEvent):void 
		{
			onProgress(e.bytesLoaded);
		}
		
		private function scene_completeHandler(e:FBXEvent):void 
		{
			fbxParser.removeEventListener(ProgressEvent.PROGRESS, scene_progressHandler);
			fbxParser.removeEventListener(FBXEvent.COMPLETE_PARSE_SCENE, scene_completeHandler);
			
			fbxScene = e.scene;
			
			onLog("完了。");
			onLog("==========================================");
			var log:String = collector.getLog();
			if (log)
			{
				onLog(log.substr(0, log.length - 1));
			}
			onLog("*FBX内に" + fbxScene.objectList.length + "個のオブジェクトがあります。");
			onLog("*FBX内に" + fbxScene.geometryList.length + "個のジオメトリがあります。");
			onLog("*FBX内に" + fbxScene.getAllMaterialList().length + "個のマテリアルがあります。");
			onLog("*FBX内に" + fbxScene.numAnimation + "個のアニメーションがあります。");
			onLog("*FBX内に" + fbxScene.layers.length + "個のレイヤーがあります。");
			
			var animationFile:File;
			for each(var item:File in FileUtil.scanFile(file.parent, 0))
			{
				if (item.extension.toLowerCase() == "m3da")
				{
					animationFile = item;
					break;
				}
			}
			if (animationFile)
			{
				onLog("★アニメーションファイルが見つかりました：" + animationFile.name);
			}
			
			onLog("==========================================");
			onLog("M3Dに変換しています......");
			
			FrameTimer.setTimer(2, timesUp, [animationFile]);
		}
		
		private var numBitmap:int;
		private var fbxExporter:M3DFBXExporter;
		private var imageFolder:TFPFolder;
		
		private function timesUp(animationFile:File):void 
		{
			fbxExporter = new M3DFBXExporter();
			fbxExporter.addEventListener(M3DFBXExporter.EVENT_LOG, f3d_logHandler);
			var animationData:ByteArray;
			if (animationFile)
			{
				animationData = LocalFile.readByteArray(animationFile);
			}
			saveM3DScene(fbxExporter.convert(fbxScene, option, animationData));
		}
		
		private function saveM3DScene(m3dScene:M3DScene):void
		{
			this.m3dScene = m3dScene;
			if (option.optimizeSurface)
			{
				m3dScene.optimizeSurface();
			}
			else
			{
				m3dScene.optimizeMeshGeometry();
			}
			m3dScene.splitMeshGeometry();
			if (option.deleteEmptyObject)
			{
				m3dScene.removeEmptyObject(option.lockUserPropertyObject, option.lockSkinEmptyObject);
			}
			//onLog("完了。");
			onLog("*M3D内に" + m3dScene.objectList.length + "個のオブジェクトがあります。");
			onLog("*M3D内に" + m3dScene.geometryList.length + "個のジオメトリがあります。");
			onLog("*M3D内に" + m3dScene.materialList.length + "個のマテリアルがあります。");
			onLog("*M3D内に" + m3dScene.numAnimation + "個のアニメーションがあります。");
			onLog("==========================================");
			
			tfplib = new TFPLibrary();
			
			ClassAliasUtil.register(M3DInfo);
			var info:M3DInfo = new M3DInfo();
			info.hasModel = option.exportModel;
			info.hasAnimation = option.exportAnimation;
			info.hasImage = option.exportImage;
			onLog("画像書き出し： " + option.exportImage);
			var infoFile:TFPFile = new TFPFile("info.dat", ByteArrayUtil.toAMF(info), TFPAssetType.TEXT);
			tfplib.root.files.push(infoFile);
			
			//PNG画像を分離＆透過境界引き伸ばし
			if (option.exportImage)
			{
				imageFolder = new TFPFolder("image");
				tfplib.root.folders.push(imageFolder);
			}
			
			exsistPngPath = { };
			
			if (option.exportImage)
			{
				if (option.fixImageEnabled)
				{
					fixImageEdge();
				}
				else
				{
					exportImages();
				}
			}
			else
			{
				lastPhase();
			}
		}
		
		private var exsistPngPath:Object;
		private var fbxParser:FBXParser;
		private var edgeExtruder:EdgeExtruder;
		private var stock:Array;
		private var current:Object;
		private var materialLink:Dictionary;
		private var output:File;
		
		private function fixImageEdge():void 
		{
			materialLink = new Dictionary();
			var pngs:Vector.<File> = new Vector.<File>;
			
			numBitmap = 0;
			for each(var material:M3DMaterial in m3dScene.materialList)
			{
				if (!material.opacityPath && material.diffusePath)
				{
					var path:String = material.diffusePath;
					var rawFile:File = option.removeDirectory? imageDir.resolvePath(FileUtil.getFileName(path)) : FileUtil.toFile(path);
					var pngFile:File = FileUtil.changeExtension(rawFile, "png");
					if (pngFile.exists)
					{
						numBitmap++;
						pngs.push(pngFile);
						materialLink[pngFile] = material;
					}
				}
			}
			
			stock = [];
			for each(var file:File in pngs)
			{
				LocalFile.readBitmapData(file, bitmapLoad_completeHandler);
			}
			
			if (numBitmap == 0)
			{
				exportImages();
			}
		}
		
		/**
		 * ふちを修正する透過PNGが読み込めたら
		 * @param	file
		 * @param	bitmap
		 */
		private function bitmapLoad_completeHandler(file:File, bitmap:BitmapData):void 
		{
			stock.push( { file:file, bitmap:bitmap } );
			numBitmap--;
			if (numBitmap <= 0)
			{
				nextExtrude();
			}
		}
		
		private function nextExtrude():void
		{
			if (stock.length == 0)
			{
				current = null;
				edgeExtruder = null;
				onProgress(1);
				exportImages();
				return;
			}
			
			current = stock.pop();
			
			var image:BitmapData = current.bitmap;
			if (BitmapUtil.isTransparent(image) == false)
			{
				nextExtrude();
				return;
			}
			
			var imageID:String = FileUtil.getFileID(current.file.name);
			var material:M3DMaterial = materialLink[current.file];
			material.diffusePath = imageID + "__diffuse__.png";
			material.opacityPath = imageID + "__opacity__.png";
			exsistPngPath[material.diffusePath] = true;
			exsistPngPath[material.opacityPath] = true;
			
			edgeExtruder = new EdgeExtruder();
			edgeExtruder.splitAndExtrudeAsync(current.bitmap, 8, option.fixImageThreshold, edgeExtruder_completeHandler, edgeExtruder_progressHandler);			
		}
		
		private function edgeExtruder_progressHandler(per:Number):void 
		{
			onProgress(per);
		}
		
		private function edgeExtruder_completeHandler(diffuse:BitmapData, opacity:BitmapData):void 
		{
			//var fixed:Vector.<BitmapData> = EdgeExtruder.splitAndExtrude(bitmap, 4, false, option.fixImageThreshold);
			var imageID:String = FileUtil.getFileID(current.file.name);
			var diffusePNG:ByteArray = diffuse.encode(diffuse.rect, new PNGEncoderOptions(false));
			var diffuseJPG:ByteArray = diffuse.encode(diffuse.rect, new JPEGEncoderOptions(option.convertJpgQuality));
			var opacityPNG:ByteArray = opacity.encode(opacity.rect, new PNGEncoderOptions(false));
			var opacityJPG:ByteArray = opacity.encode(opacity.rect, new JPEGEncoderOptions(option.convertJpgQuality));
			
			var diffuseTFP:TFPFile;
			var opcityTFP:TFPFile;
			if (diffusePNG.length < diffuseJPG.length)
			{
				diffuseTFP = new TFPFile(imageID + "__diffuse__.png", diffusePNG, TFPAssetType.IMAGE);
			}
			else
			{
				diffuseTFP = new TFPFile(imageID + "__diffuse__.jpg", diffuseJPG, TFPAssetType.IMAGE);
			}
			if (opacityPNG.length < opacityJPG.length)
			{
				opcityTFP = new TFPFile(imageID + "__opacity__.png", opacityPNG, TFPAssetType.IMAGE);
			}
			else
			{
				opcityTFP = new TFPFile(imageID + "__opacity__.jpg", opacityJPG, TFPAssetType.IMAGE);
			}
			
			imageFolder.files.push(diffuseTFP);
			imageFolder.files.push(opcityTFP);
			onLog(current.file.name + "のアルファを修正しました。");
			
			nextExtrude();
		}
		
		private var requestCount:int;
		private function exportImages():void
		{
			requestCount = 0;
			for each(var name:String in m3dScene.getAllMaterialFileName())
			{
				if (exsistPngPath[name]) continue;
				
				//先にATF拡張子の画像を探して、無かったら元の画像ファイルを探す。
				var extList:Array = ["atf"];
				var rawExt:String = FileUtil.getExtension(name, true);
				if (["jpg", "png", "gif"].indexOf(rawExt) >= 0)
				{
					extList.push(rawExt);
				}
				VectorUtil.attachListDiff(extList, ["jpg", "png", "gif"]);
				
				var exist:Boolean = false;
				var rawFile:File = option.removeDirectory? imageDir.resolvePath(FileUtil.getFileName(name)) : FileUtil.toFile(name);
				if (rawFile)
				{
					var n:int = extList.length;
					for (var i:int = 0; i < n; i++) 
					{
						var imageFile:File = FileUtil.changeExtension(rawFile, extList[i]);
						if (imageFile.exists)
						{
							if (option.convertJpgEnabled)
							{
								requestCount++;
								LocalFile.readBitmapData(imageFile, loadImage_completeHandler);
							}
							else
							{
								var tfp:TFPFile = new TFPFile(imageFile.name, LocalFile.readByteArray(imageFile), TFPAssetType.IMAGE);
								imageFolder.files.push(tfp);
							}
							exist = true;
							break;
						}
					}
				}
				
				if (exist == false)
				{
					addError("■ 画像（" + FileUtil.getFileID(name) + ".xxx）が見つかりません！");
				}
			}
			
			if (requestCount == 0)
			{
				lastPhase();
			}
		}
		
		/**
		 * 画像を読み込んだらJPG化する
		 * @param	file
		 * @param	image
		 */
		private function loadImage_completeHandler(file:File, image:BitmapData):void 
		{
			var raw:ByteArray = LocalFile.readByteArray(file);
			var jpg:ByteArray = image.encode(image.rect, new JPEGEncoderOptions(option.convertJpgQuality));
			var useJPG:Boolean = (jpg.length < raw.length && BitmapUtil.isTransparent(image) == false);
			var bytes:ByteArray = useJPG? jpg : raw;
			var name:String = useJPG? FileUtil.changeExtension(file, "jpg").name : file.name;
			var tfp:TFPFile = new TFPFile(name, bytes, TFPAssetType.IMAGE);
			imageFolder.files.push(tfp);
			requestCount--;
			if (requestCount == 0)
			{
				lastPhase();
			}
		}
		
		private function lastPhase():void
		{
			for each(var mm:M3DMaterial in m3dScene.materialList)
			{
				if (mm.diffusePath) mm.diffusePath = FileUtil.getFileName(mm.diffusePath);
				if (mm.opacityPath) mm.opacityPath = FileUtil.getFileName(mm.opacityPath);
				if (mm.normalPath) mm.normalPath = FileUtil.getFileName(mm.normalPath);
				if (mm.reflectionPath) mm.reflectionPath = FileUtil.getFileName(mm.reflectionPath);
			}
			
			var ba:ByteArray = new ByteArray();
			ba.writeObject(m3dScene);
			ba.compress();
			
			var sceneFile:TFPFile = new TFPFile("scene.dat", ba, TFPAssetType.BYTEARRAY);
			tfplib.root.files.push(sceneFile);
			
			var bytes:ByteArray = new TFPConverter().export(tfplib, false);
			onLog("M3D化完了！(" + int(bytes.bytesAvailable / 1024) + "KB)");
			LocalFile.writeByteArray(output, bytes, true);
			
			onComplete();
		}
		
		private function f3d_logHandler(e:TextEvent):void 
		{
			onLog(e.text);
		}
		
	}

}