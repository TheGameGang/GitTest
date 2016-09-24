Shader "Custom/Unlit" {
	Properties {
		_Color ("Main Color", Color) = (.5,.5,.5,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}

	SubShader {
		Tags { "RenderType"="Opaque" }
		Pass {
			Cull Back
			SetTexture [_MainTex] {
				constantColor [_Color]
				Combine texture * constant
			} 
		}
	}
}
