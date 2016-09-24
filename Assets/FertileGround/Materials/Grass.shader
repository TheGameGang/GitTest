Shader "Custom/Grass" {
	Properties {
		_Color ("Main Color", Color) = (1,1,1,1)
		_MainTex ("Base (RGB) Alpha (A)", 2D) = "white" {}
		_WaveAndDistance ("Wave and distance", Vector) = (12, 3.6, 1, 1)
		_Cutoff ("Cutoff", float) = 0.5
	    _Radius ("Radius", Float) = 0.0
	    _Origin ("Origin", Vector) = (0,0,0,1)
	}
	SubShader {
		Tags {
			"Queue" = "Transparent-101"
			"IgnoreProjector"="True"
			"RenderType"="NoOutline"
		}

		ColorMask rgb
		Cull Off
		
		Pass {
			CGPROGRAM 
			#pragma vertex vert
			#pragma multi_compile NO_INTEL_GMA_X3100_WORKAROUND INTEL_GMA_X3100_WORKAROUND
			#include "WavingGrass.cginc"
			ENDCG 

			AlphaTest Greater [_Cutoff]

			SetTexture [_MainTex] { 
				//combine texture * primary DOUBLE, primary*texture
				combine texture * primary, primary*texture
			}
		}
		Pass { 
			Tags { "RequireOptions" = "SoftVegetation" }
			CGPROGRAM
			#pragma vertex vert
			#pragma multi_compile NO_INTEL_GMA_X3100_WORKAROUND INTEL_GMA_X3100_WORKAROUND
			#include "WavingGrass.cginc"
			ENDCG   	

			// Dont write to the depth buffer
			ZWrite off
			
			// Only render non-transparent pixels
			AlphaTest Greater 0

			// And closer to us than first pass (so we don't fill those twice)
			ZTest Less

			// Set up alpha blending
			Blend SrcAlpha OneMinusSrcAlpha
 
			SetTexture [_MainTex] { 
				//combine texture * primary DOUBLE, primary*texture
				combine texture * primary, primary*texture
			} 
		 }
	} 
	
	Fallback Off
}
