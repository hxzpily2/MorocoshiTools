package project.m3dviewer 
{
	import flash.display.BlendMode;
	import net.morocoshi.moja3d.shaders.render.EnvironmentShader;
	import net.morocoshi.moja3d.shaders.render.FresnelShader;
	import net.morocoshi.moja3d.shaders.render.LambertShader;
	import net.morocoshi.moja3d.shaders.render.ReflectionShader;
	import net.morocoshi.moja3d.shaders.render.SpecularShader;
	import net.morocoshi.moja3d.shaders.render.SphereMapShader;
	import net.morocoshi.moja3d.shaders.render.VertexColorShader;
	import net.morocoshi.moja3d.shaders.shadow.ShadowShader;
	
	/**
	 * 共通シェーダー
	 * 
	 * @author tencho
	 */
	public class ShaderManager 
	{
		public var lambert:LambertShader;
		public var shadow:ShadowShader;
		public var vertexColor:VertexColorShader;
		public var wireframe:*;
		public var specular:SpecularShader;
		public var reflections:Vector.<ReflectionShader>;
		public var sphereMaps:Vector.<SphereMapShader>;
		public var environment:EnvironmentShader;
		public var fresnel:FresnelShader;
		
		public function ShaderManager() 
		{
			lambert = new LambertShader();
			shadow = new ShadowShader(true);
			vertexColor = new VertexColorShader(BlendMode.MULTIPLY, BlendMode.MULTIPLY);
			specular = new SpecularShader(10, 0.2, false, true, false);
			reflections = new Vector.<ReflectionShader>;
			sphereMaps = new Vector.<SphereMapShader>;
			fresnel = new FresnelShader(1 / 1.5, 0);
		}
		
	}

}