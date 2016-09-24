@script ExecuteInEditMode

class EdgeDetectEffectNormals extends ImageEffectBase
{
	var renderSceneShader : Shader;
	
	private var renderTexture : RenderTexture;
	private var shaderCamera : GameObject;
	
	function OnDisable() {
		super.OnDisable();
		DestroyImmediate (shaderCamera);
		if (renderTexture != null) {
			RenderTexture.ReleaseTemporary (renderTexture);
			renderTexture = null;
		}
	}
	
	function OnPreRender()
	{
		if (!enabled || !gameObject.active)
			return;
			
		if (renderTexture != null) {
			RenderTexture.ReleaseTemporary (renderTexture);
			renderTexture = null;
		}
		renderTexture = RenderTexture.GetTemporary (GetComponent.<Camera>().pixelWidth, GetComponent.<Camera>().pixelHeight, 16);
		if (!shaderCamera) {
			shaderCamera = new GameObject("ShaderCamera", Camera);
			shaderCamera.GetComponent.<Camera>().enabled = false;
			shaderCamera.hideFlags = HideFlags.HideAndDontSave;
		}
		
		var cam = shaderCamera.GetComponent.<Camera>();
		cam.CopyFrom (GetComponent.<Camera>());
		cam.backgroundColor = Color(1,1,1,1);
		cam.clearFlags = CameraClearFlags.SolidColor;
		cam.targetTexture = renderTexture;
		cam.RenderWithShader (renderSceneShader, "RenderType");	
	}
	
	function OnRenderImage (source : RenderTexture, destination : RenderTexture)
	{
		var mat = material;
		mat.SetTexture("_NormalsTexture", renderTexture);
		ImageEffects.BlitWithMaterial (mat, source, destination);
		if (renderTexture != null) {
			RenderTexture.ReleaseTemporary (renderTexture);
			renderTexture = null;
		}
	}
}
