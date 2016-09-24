// Upgrade NOTE: replaced 'glstate.matrix.invtrans.modelview[0]' with 'UNITY_MATRIX_IT_MV'
// Upgrade NOTE: replaced 'glstate.matrix.modelview[0]' with 'UNITY_MATRIX_MV'
// Upgrade NOTE: replaced 'glstate.matrix.mvp' with 'UNITY_MATRIX_MVP'

Shader "Hidden/RenderNormalsAndDepth" {
	
SubShader {
	Tags { "RenderType"="Opaque" }
	Pass {
		Fog { Mode Off }
		
CGPROGRAM
// Upgrade NOTE: excluded shader from OpenGL ES 2.0 because it uses non-square matrices
#pragma exclude_renderers gles
#pragma vertex vert
#include "UnityCG.cginc"

struct v2f {
	float4 pos : POSITION;
	float4 color : COLOR;
};

v2f vert( appdata_base v ) {
	v2f o;
	o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
	float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
	o.color.rgb = viewNormal * 0.5 + 0.5;
	float z = mul((float3x4)UNITY_MATRIX_MV, v.vertex).z;
	o.color.a = -z / _ProjectionParams.z;
	return o;
}

ENDCG

	}
}

//this SubShader will run for objects, for which "RenderType" is set to "NoOutline", so that they will receive no outline at the edge detection phase
SubShader {
	Tags { "RenderType"="NoOutline" }
	Pass {
		Fog { Mode Off }
		
CGPROGRAM
#pragma vertex vert
#include "UnityCG.cginc"

struct v2f {
	float4 pos : POSITION;
	float4 color : COLOR;
};

v2f vert( appdata_base v ) {
	v2f o;
	o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
	o.color = float4(0,0,0,0);
	
	return o;
}

ENDCG

	}
} 

}
