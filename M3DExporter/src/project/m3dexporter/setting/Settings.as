package project.m3dexporter.setting 
{
	import com.bit101.components.CheckBox;
	import com.bit101.components.PushButton;
	import com.bit101.components.TextArea;
	import com.bit101.components.VBox;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.text.TextFormat;
	import mx.utils.StringUtil;
	import net.morocoshi.air.components.minimal.Modal;
	import net.morocoshi.air.windows.ModalManager;
	import net.morocoshi.air.windows.WindowUtil;
	import net.morocoshi.common.graphics.Palette;
	import net.morocoshi.components.balloon.MouseOverLabel;
	import net.morocoshi.components.minimal.input.InputFile;
	import net.morocoshi.components.minimal.layout.LayoutCell;
	import net.morocoshi.components.minimal.layout.PaddingBox;
	import net.morocoshi.components.minimal.ScrollPane;
	import net.morocoshi.moja3d.loader.exporters.M3DExportOption;
	import project.m3dexporter.data.UserFile;
	import project.m3dexporter.Main;
	
	/**
	 *  
	 * @author tencho
	 */
	public class Settings
	{
		private var window:NativeWindow;
		private var option:M3DExportOption;
		
		private var useHideLayer:CheckBox;
		private var useVisible:CheckBox;
		
		private var exportCamera:CheckBox;
		private var exportLight:CheckBox;
		
		private var exportTransparentMap:CheckBox;
		//private var exportReflectionMap:CheckBox;
		private var exportNormalMap:CheckBox;
		
		private var exportVertexUV:CheckBox;
		private var exportVertexNormal:CheckBox;
		private var exportVertexColor:CheckBox;
		private var exportVertexTangent:CheckBox;
		
		private var autoRepeat:CheckBox;
		private var deleteEmptyObject:CheckBox;
		private var addAnimation:CheckBox;
		//private var removeDirectory:CheckBox;
		private var useFreezeLayer:CheckBox;
		private var moveToRoot:CheckBox;
		private var input:InputFile;
		private var optimizeSurface:CheckBox;
		private var extractObjectParam:CheckBox;
		private var objectParamsButton:PushButton;
		//private var objectParamList:Array;
		private var textArea:TextArea;
		private var lockUserPropertyObject:CheckBox;
		private var lockSkinEmptyObject:CheckBox;
		private var fixMaxStyleTexture:CheckBox;
		
		//private var simpleTangent4:CheckBox;
		//private var useShow:CheckBox;
		//private var moveBasePoint:CheckBox;
		//private var exportTangent4:CheckBox;
		//private var exportVertexColor:CheckBox;
		
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function Settings() 
		{
			window = new NativeWindow(WindowUtil.createOption());
			window.addEventListener(Event.CLOSING, window_closingHandler);
			
			window.stage.scaleMode = "noScale";
			window.stage.align = "TL";
			window.stage.stageWidth = 440;
			window.stage.stageHeight = 500;
			window.stage.color = 0xF3F3F3;
			
			var box:VBox = new VBox(window.stage, 20, 20);
			box.spacing = 12;
			
			var rgb:uint = 0xdd2244;
			useHideLayer = createCheckBox(box, "非表示レイヤーを書き出す", rgb);
			useFreezeLayer = createCheckBox(box, "フリーズレイヤーを書き出す", rgb);
			exportCamera = createCheckBox(box, "カメラを書き出す", rgb);
			exportLight = createCheckBox(box, "ライトを書き出す", rgb);
			exportTransparentMap = createCheckBox(box, "不透明度マップを書き出す", rgb);
			exportNormalMap = createCheckBox(box, "ノーマルマップを書き出す", rgb);
			fixMaxStyleTexture = createCheckBox(box, "拡散反射と不透明マップに同じPNGが貼られていた場合に不透明を消す", rgb);
			//exportReflectionMap = createCheckBox(box, "反射マップを書き出す", rgb);
			
			MouseOverLabel.instance.setLabel(fixMaxStyleTexture, "MAX上で透過PNGをプレビューする際に\n拡散反射と不透明の両方に同じPNG画像を貼る事があり\nその設定のまま書き出されてしまったマテリアルの対策用です。");
			MouseOverLabel.instance.setLabel(useHideLayer, "非表示状態になっているレイヤーに配置した\nオブジェクトを書き出すかを設定します。");
			MouseOverLabel.instance.setLabel(useFreezeLayer, "フリーズ状態になっているレイヤーに配置した\nオブジェクトを書き出すかを設定します。");
			MouseOverLabel.instance.setLabel(exportCamera, "シーン内のカメラを書き出すかを設定します。");
			MouseOverLabel.instance.setLabel(exportLight, "シーン内のライトを書き出すかを設定します。\n現時点で書き出し可能なライトは平行光源と環境光のみです。");
			MouseOverLabel.instance.setLabel(exportTransparentMap, "マテリアルに設定されている不透明度マップを\n書き出すかを設定します。");
			MouseOverLabel.instance.setLabel(exportNormalMap, "マテリアルに設定されているノーマルマップを\n書き出すかを設定します。");
			//MouseOverLabel.instance.setLabel(exportReflectionMap, "マテリアルに設定されている反射マップを書き出すかを設定します。");
			
			rgb = 0xee5500;
			exportVertexUV = createCheckBox(box, "UVを書き出す", rgb);
			exportVertexNormal = createCheckBox(box, "頂点法線を書き出す", rgb);
			exportVertexColor = createCheckBox(box, "頂点カラーを書き出す", rgb);
			exportVertexTangent = createCheckBox(box, "接線、従法線を書き出す", rgb);
			
			
			rgb = 0x444444;
			//new Component(box).height = 5;
			useVisible = createCheckBox(box, "ユーザーデータ「visible」を表示に反映", rgb);
			autoRepeat = createCheckBox(box, "マテリアルのリピートをUV座標から自動判別", rgb);
			//removeDirectory = createCheckBox(box, "マテリアルパスのフォルダを削る", rgb);
			
			MouseOverLabel.instance.setLabel(useVisible, "ユーザー定義プロパティがvisible=false\nになっているオブジェクトを非表示状態にします。");
			MouseOverLabel.instance.setLabel(autoRepeat, "各三角ポリゴンにおいてマテリアルのタイリングを、\nUVが0～1の範囲に収まっているものはリピート無しに、\nUVが0～1の範囲外のものはリピートを有りにします。\nマテリアルの両端の色が違いリピートすると反対側の色が見えてしまう場合に\n部分的にリピートを無効にする事で見た目が改善される可能性があります。\nなおマテリアル数が増えるためレンダリングの負荷は高くなります。");
			//MouseOverLabel.instance.setLabel(removeDirectory, "マテリアルが使用しているテクスチャマップパスのフォルダを削りファイル名だけにします。\nマテリアルフォルダを指定したい場合はこれを有効にする必要があります。");
			
			rgb = 0x4444dd;
			//new Component(box).height = 5;
			deleteEmptyObject = createCheckBox(box, "空っぽのコンテナを削除する", rgb);
			lockUserPropertyObject = createCheckBox(box, " （ユーザープロパティ付きは削除しない）", rgb);
			lockSkinEmptyObject = createCheckBox(box, " （スキンの中の空コンテナは削除しない）", rgb);
			optimizeSurface = createCheckBox(box, "同一マテリアルのサーフェイスを統合する", rgb);
			moveToRoot = createCheckBox(box, "可能なものは全てルート階層に移動する", rgb);
			MouseOverLabel.instance.setLabel(deleteEmptyObject, "中に何も入っていない空のコンテナオブジェクトを削除します。");
			MouseOverLabel.instance.setLabel(optimizeSurface, "マテリアルとユーザープロパティが同じメッシュ同士を\nアタッチしてオブジェクト数を減らし、\nレンダリング負荷を軽減します。");
			
			rgb = 0x116600;
			extractObjectParam = createCheckBox(box, "オブジェクトのカスタムアトリビュートを\nユーザーデータとして抽出する", rgb);
			extractObjectParam.height += 14;
			objectParamsButton = new PushButton(box, 0, 0, "", params_clickHandler);
			objectParamsButton.setSize(220, 25);
			MouseOverLabel.instance.setLabel(extractObjectParam, "MAYAから書き出したFBXにおいて、\nカスタムアトリビュートをユーザーデータ化します。");
			
			//exportTangent4 = new CheckBox(box, 0, 0, "Tangent/Binormalを書き出す");
			//useShow = new CheckBox(box, 0, 0, "△オブジェクトのshowプロパティを表示に反映");
			//moveBasePoint = new CheckBox(box, 0, 0, "✓基点をAABBの中心に移動する");
			//simpleTangent4 = new CheckBox(box, 0, 0, "△タンジェント情報を適当にしてサイズを減らす");
		}
		
		private function window_closingHandler(e:Event):void 
		{
			Main.current.stage.addChild(MouseOverLabel.instance.container);
			
			option.exportCamera = exportCamera.selected;
			option.exportLight = exportLight.selected;
			option.exportNormal = exportNormalMap.selected;
			//option.exportReflection = exportReflectionMap.selected;
			option.exportTransparent = exportTransparentMap.selected;
			option.fixMaxStylePngTexture = fixMaxStyleTexture.selected;
			
			option.exportUV = exportVertexUV.selected;
			option.exportNormal = exportVertexNormal.selected;
			option.exportVertexColor = exportVertexColor.selected;
			option.exportTangent4 = exportVertexTangent.selected;
			
			option.extractObjectParam = extractObjectParam.selected;
			//option.objectParamList = Main.current.user.objectParamList;
			//option.removeDirectory = removeDirectory.selected;
			option.useHideLayer = useHideLayer.selected;
			option.useFreezeLayer = useFreezeLayer.selected;
			option.useVisible = useVisible.selected;
			option.autoRepeat = autoRepeat.selected;
			option.deleteEmptyObject = deleteEmptyObject.selected;
			option.lockUserPropertyObject = lockUserPropertyObject.selected;
			option.lockSkinEmptyObject = lockSkinEmptyObject.selected;
			option.moveToRoot = moveToRoot.selected;
			option.optimizeSurface = optimizeSurface.selected;
			
			option.moveBasePoint = false;//moveBasePoint.selected;
			option.useShow = false;// useShow.selected;
		}
		
		public function open(option:M3DExportOption):void
		{
			this.option = option;
			
			//objectParamList = option.objectParamList;
			
			//simpleTangent4.selected = option.simpleTangent4;
			//useShow.selected = option.useShow;
			//moveBasePoint.selected = option.moveBasePoint;
			//exportTangent4.selected = option.exportTangent4;
			
			useVisible.selected = option.useVisible;
			autoRepeat.selected = option.autoRepeat;
			deleteEmptyObject.selected = option.deleteEmptyObject;
			lockUserPropertyObject.selected = option.lockUserPropertyObject;
			lockSkinEmptyObject.selected = option.lockSkinEmptyObject;
			
			exportCamera.selected = option.exportCamera;
			exportLight.selected = option.exportLight;
			exportTransparentMap.selected = option.exportTransparent;
			//exportReflectionMap.selected = option.exportReflection;
			exportNormalMap.selected = option.exportNormal;
			fixMaxStyleTexture.selected = option.fixMaxStylePngTexture;
			
			exportVertexUV.selected = option.exportUV;
			exportVertexNormal.selected = option.exportNormal;
			exportVertexColor.selected = option.exportVertexColor;
			exportVertexTangent.selected = option.exportTangent4;
			
			extractObjectParam.selected = option.extractObjectParam;
			useFreezeLayer.selected = option.useFreezeLayer;
			useHideLayer.selected = option.useHideLayer;
			//removeDirectory.selected = option.removeDirectory;
			moveToRoot.selected = option.moveToRoot;
			optimizeSurface.selected = option.optimizeSurface;
			
			updateButtonLabel();
			
			window.stage.addChild(MouseOverLabel.instance.container);
			ModalManager.activate(window);
			WindowUtil.moveCenter(window);
		}
		
		private function createCheckBox(parent:VBox, label:String, rgb:uint):CheckBox 
		{
			var check:CheckBox = new CheckBox(parent, 0, 0, label);
			check.getChildAt(0).y += 1;
			check.getChildAt(1).y += 1;
			check.getChildAt(2).transform.colorTransform = Palette.getFillColor(rgb);
			return check;
		}
		
		private function updateButtonLabel():void 
		{
			objectParamsButton.label = "抽出するアトリビュート名の設定(" + option.objectParamList.length +")";
		}
		
		private function params_clickHandler(e:Event):void 
		{
			var win:NativeWindow = Modal.confirm("カンマ区切り", inputParamList_okHandler, null, true, 210, 400);
			win.stage.scaleMode = "noScale";
			win.stage.align = "TL";
			
			textArea = new TextArea();
			textArea.setSize(360, 200);
			textArea.x = 20;
			textArea.y = 45;
			textArea.text = option.objectParamList.join(",");
			textArea.textField.defaultTextFormat = new TextFormat(null, 12);
			
			win.stage.addChild(textArea);
		}
		
		private function inputParamList_okHandler():void 
		{
			option.objectParamList.length = 0;
			var items:Array = textArea.text.split(",");
			var n:int = items.length;
			for (var i:int = 0; i < n; i++) 
			{
				option.objectParamList.push(items[i].replace(/\n|\r|\s/g, ""));
			}
			updateButtonLabel();
		}
		
	}

}