package project.tfp.converter 
{
	import flash.filesystem.File;
	import net.morocoshi.common.loaders.tfp.TFPFile;
	import net.morocoshi.common.loaders.tfp.TFPFolder;
	import net.morocoshi.components.tree.TreeLimb;
	
	/**
	 * Fileオブジェクト内の階層構造をTreeLimbオブジェクトに変換して追加する
	 * (※このクラスは使いません)
	 * 
	 * @author tencho
	 */
	public class FolderImporter 
	{
		
		public function FolderImporter() 
		{
		}
		
		/**
		 * 指定TFPフォルダ内の構造をTreeLimbオブジェクト化する
		 * @param	limb
		 * @param	root
		 */
		public function importLibrary(limb:TreeLimb, root:TFPFolder):void 
		{
			limb.lock();
			limb.removeAllChildren();
			//ルートフォルダを生成する
			var trunk:TreeLimb = limb.addFolder(root.name, root);
			scanAssetFolder(trunk, root);
			limb.unlock();
		}
		
		/**
		 * 指定TFPフォルダ内のサブフォルダ、ファイルをリストアップしてTreeLimbオブジェクトの子として追加する
		 * @param	limb
		 * @param	folder
		 */
		private function scanAssetFolder(limb:TreeLimb, folder:TFPFolder):void 
		{
			//サブフォルダ
			for each(var fd:TFPFolder in folder.folders)
			{
				var dir:TreeLimb = limb.addFolder(fd.name, fd);
				scanAssetFolder(dir, fd);
			}
			//ファイル
			for each(var fl:TFPFile in folder.files)
			{
				limb.addFile(fl.name, fl.type, fl);
			}
		}
		
		public function importFolder(limb:TreeLimb, folder:File):void 
		{
			limb.lock();
			limb.removeAllChildren();
			scanFolder(limb, folder);
			limb.unlock();
		}
		
		private function scanFolder(limb:TreeLimb, folder:File):void
		{
			if (!folder.isDirectory) return;
			for each(var f:File in folder.getDirectoryListing())
			{
				if (!f.isDirectory) return;
				var dir:TreeLimb = limb.addFolder(f.name, f);
				scanFolder(dir, f);
			}
		}
		
	}

}