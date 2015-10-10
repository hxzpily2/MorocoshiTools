package project.tfp.data 
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import net.morocoshi.air.components.minimal.Modal;
	import net.morocoshi.air.files.LocalFile;
	import net.morocoshi.common.timers.FrameTimer;
	import project.tfp.canvas.grid.ExportDataGrid;
	import project.tfp.Document;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ProjectData 
	{
		
		static public const MESSAGE_OPENING:String = "ファイルを開こうとしています。";
		static public const MESSAGE_LOST:String = "保存していない情報は失われますがよろしいですか？";
		static public const MESSAGE_SUCCESS:String = "保存しました。";
		static public const MESSAGE_ERROR:String = "保存に失敗しました...";
		static public const LABEL_OPENFILE:String = "ファイルを開く";
		static public const LABEL_NEWFILE:String = "新しいファイル";
		static public const DEFAULT_FILENAME:String = "assets.tfproj";
		static public const MESSAGE_EXIT:String = "ツールを終了しようとしています。";
		static public const MESSAGE_RESTORE:String = "リストを復元しようとしています。";
		
		public var assetList:AssetList;
		public var currentFile:File;
		
		private var lastKey:String;
		private var grid:ExportDataGrid;
		private var loadingFile:File;
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		public function ProjectData(grid:ExportDataGrid) 
		{
			this.grid = grid;
			assetList = new AssetList();
			resetChange();
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 削除
		 */
		/*
		private function ___clear():void
		{
			assetList.clear();
			resetChange();
			grid.importAssetList(assetList);
		}
		*/
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 新規作成
		 */
		public function newFile(force:Boolean):void 
		{
			updateAssetList();
			if (isChange && !force)
			{
				Modal.confirm(MESSAGE_LOST, newFile_okHandler);
				return;
			}
			newFile_okHandler();
		}
		
		private function newFile_okHandler():void 
		{
			assetList.clear();
			grid.importAssetList(assetList);
			Document.setWindowTitle(LABEL_NEWFILE);
			resetChange();
			currentFile = null;
		}
		
		/**
		 * 好きなファイルを開く
		 */
		public function browse():void 
		{
			updateAssetList();
			if (isChange)
			{
				Modal.confirm(MESSAGE_LOST, browse_okHandler).title = LABEL_OPENFILE;
			}
			else
			{
				browse_okHandler();
			}
		}
		
		private function browse_okHandler():void 
		{
			FrameTimer.setTimer(1, function():void
			{
				var file:File = currentFile || new File();
				file.addEventListener(Event.SELECT, browse_openHandler, false, 0, true);
				file.browseForOpen(LABEL_OPENFILE, [new FileFilter("*.tfproj", "*.tfproj")]);
			});
		}
		
		private function browse_openHandler(e:Event):void 
		{
			var file:File = e.currentTarget as File;
			loadFile(file, true);
		}
		
		/**
		 * 指定のファイルを開く
		 * @param	file
		 */
		public function loadFile(file:File, force:Boolean):void
		{
			loadingFile = file;
			updateAssetList();
			
			if (isChange && !force)
			{
				Modal.confirm(MESSAGE_OPENING + "\n" + MESSAGE_LOST, load_okHandler);
			}
			else
			{
				load_okHandler();
			}
		}
		
		private function load_okHandler():void 
		{
			currentFile = loadingFile.clone();
			assetList.parse(LocalFile.readXML(currentFile));
			Document.canvas.grid.importAssetList(assetList);
			resetChange();
			Document.setWindowTitle(currentFile.name);
		}
		
		/**
		 * 確認あり上書き保存
		 */
		public function trySave():void
		{
			updateAssetList();
			if (!currentFile || !currentFile.exists)
			{
				saveAs();
				return;
			}
			Modal.confirm(currentFile.nativePath + "\nを上書き保存しますか？", save_okHandler);
		}
		
		private function save_okHandler():void 
		{
			if (save())
			{
				Modal.alert(MESSAGE_SUCCESS);
			}
			else
			{
				Modal.alert(MESSAGE_ERROR);
			}
		}
		
		/**
		 * 確認無し上書き保存。成功するとtrueが返る
		 * @return
		 */
		private function save():Boolean
		{
			var success:Boolean = LocalFile.writeUTFBytes(currentFile, assetList.toXML(), true);
			if (success)
			{
				resetChange();
			}
			return success;
		}
		
		/**
		 * 名前をつけて保存
		 */
		public function saveAs():void
		{
			updateAssetList();
			var name:String = currentFile? currentFile.name : DEFAULT_FILENAME;
			var file:File = new File();
			file.addEventListener(Event.COMPLETE, saveAs_completeHandler, false, 0, true);
			file.save(assetList.toXML(), name);
		}
		
		private function saveAs_completeHandler(e:Event):void 
		{
			currentFile = e.currentTarget as File;
			Document.setWindowTitle(currentFile.name);
			resetChange();
			Modal.alert(MESSAGE_SUCCESS);
		}
		
		/**
		 * ツールを終了する。変更点があれば確認。
		 */
		public function tryExit():void 
		{
			updateAssetList();
			if (isChange)
			{
				Modal.confirm(MESSAGE_EXIT + "\n" + MESSAGE_LOST, NativeApplication.nativeApplication.exit);
				return;
			}
			NativeApplication.nativeApplication.exit(0);
		}
		
		private var swappingAssetList:AssetList;
		/**
		 * 旧バージョンのリストを復元する
		 * @param	assetList
		 */
		public function restoreAssetList(assetList:AssetList):void 
		{
			swappingAssetList = assetList;
			updateAssetList();
			if (isChange)
			{
				Modal.confirm(MESSAGE_RESTORE + "\n" + MESSAGE_LOST, restore_okHandler);
				return;
			}
			restore_okHandler();
		}
		
		private function restore_okHandler():void 
		{
			newFile(true);
			grid.importAssetList(swappingAssetList);
			Modal.alert("復元しました。");
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		private function resetChange():void
		{
			lastKey = assetList.getKey();
		}
		
		private function get isChange():Boolean
		{
			return (lastKey != assetList.getKey());
		}
		
		/**
		 * データグリッドを渡してアセットリストに最新データを反映する
		 * @param	grid
		 */
		private function updateAssetList():void
		{
			assetList.items = grid.getAssetList();
		}
		
	}

}