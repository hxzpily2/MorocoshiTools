package project.m3dviewer 
{
	import com.bit101.components.TextArea;
	import flash.display.NativeWindow;
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	import net.morocoshi.air.windows.WindowUtil;
	import net.morocoshi.common.text.TextUtil;
	import net.morocoshi.components.minimal.layout.LayoutCell;
	import net.morocoshi.components.minimal.TreePanel;
	import net.morocoshi.components.tree.TreeLimb;
	import net.morocoshi.components.tree.TreeLimbEvent;
	import net.morocoshi.moja3d.objects.Mesh;
	import net.morocoshi.moja3d.objects.Object3D;
	import net.morocoshi.moja3d.renderer.MaskColor;
	
	/**
	 * 木構造の表示
	 * 
	 * @author tencho
	 */
	public class TreeWindow extends NativeWindow
	{
		private var cell:LayoutCell;
		private var tree:TreePanel;
		private var logger:TextArea;
		private var allObjects:Vector.<Object3D>;
		
		public function TreeWindow() 
		{
			super(WindowUtil.createOption());
			alwaysInFront = true;
			
			stage.align = "TL";
			stage.scaleMode = "noScale";
			stage.addEventListener(Event.RESIZE, win_resizeHandler);
			stage.stageWidth = 550;
			stage.stageHeight = 400;
			
			tree = new TreePanel();
			tree.folder.addEventListener(TreeLimbEvent.CHANGE_SELECT, tree_changeSelectHandler);
			tree.resizable = false;
			logger = new TextArea();
			
			cell = new LayoutCell(stage, 0, 0, LayoutCell.ALIGN_TOP);
			cell.addCell(tree, "*");
			cell.addCell(logger, "*");
			
			win_resizeHandler(null);
		}
		
		/**
		 * Object3Dの全階層をTreeLimb化
		 * @param	target
		 * @return
		 */
		public function toTreeLimb(target:Object3D):TreeLimb
		{
			var limb:TreeLimb = new TreeLimb();
			var className:String = getQualifiedClassName(target).split(".").pop().split("::").pop();
			var type:String = target.visible? "": "(hide)";
			limb.label = "[" + className + " " + target.name + "] " + type;
			limb.extra = target;
			limb.isFolder = target.numChildren > 0;
			for (var child:Object3D = target.children; child; child = child.next)
			{
				limb.addLimb(toTreeLimb(child));
			}
			return limb;
		}
		
		public function setObject3DTree(object:Object3D):void
		{
			allObjects = object.getChildren(true, true);
			
			tree.folder.lock();
			tree.folder.removeAllChildren();
			tree.folder.addLimb(toTreeLimb(object));
			tree.folder.unlock();
		}
		
		private function tree_changeSelectHandler(e:TreeLimbEvent):void 
		{
			for each (var object:Object3D in allObjects) 
			{
				//object.renderMask = -1;
			}
			
			var selected:Vector.<TreeLimb> = tree.folder.getSelectedLimbs();
			for each(var item:TreeLimb in selected)
			{
				//Object3D(item.extra).renderMask = MaskColor.RED;
			}
			
			if (selected.length == 1)
			{
				analysisObject(selected[0].extra);
				
			}
		}
		
		private function analysisObject(extra:Object3D):void 
		{
			addLog(extra);
			var mesh:Mesh = extra as Mesh;
			if (mesh == null) return;
			
			var n:int = mesh.surfaces.length;
			for (var i:int; i < n; i++)
			{
				if (mesh.startShaderList)
				{
					//var skin:SkinShader = mesh.startShaderList.getShaderAs(SkinShader) as SkinShader;
					//if (skin) skin.enabled = false;
					addLog(mesh.startShaderList.key);
				}
				addLog(mesh.surfaces[i].material.shaderList.key);
				if (mesh.endShaderList) addLog(mesh.endShaderList.key);
			}
		}
		
		private function addLog(value:*):void 
		{
			logger.text += TextUtil.fixNewline(String(value)) + "\n";
		}
		
		private function win_resizeHandler(e:Event):void 
		{
			if (cell)
			{
				cell.setSize(stage.stageWidth, stage.stageHeight);
			}
		}
		
	}

}