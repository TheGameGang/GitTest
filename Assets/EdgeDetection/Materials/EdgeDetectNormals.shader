// Upgrade NOTE: replaced 'glstate.matrix.mvp' with 'UNITY_MATRIX_MVP'
// Upgrade NOTE: replaced 'glstate.matrix.texture[0]' with 'UNITY_MATRIX_TEXTURE0'
// Upgrade NOTE: replaced 'samplerRECT' with 'sampler2D'
// Upgrade NOTE: replaced 'texRECT' with 'tex2D'

Shader "Hidden/Edge Detect Normals" {
Properties {
	_MainTex ("Base (RGB)", RECT) = "white" {}
	_NormalsTexture ("Normals", RECT) = "white" {}
}

SubShader {
	Pass {
		ZTest Always Cull Off ZWrite Off
		Fog { Mode off }

CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest 
#include "UnityCG.cginc"

uniform sampler2D _MainTex;
uniform sampler2D _NormalsTexture;
uniform float4 _MainTex_TexelSize;

struct v2f {
	float4 pos : POSITION;
	float2 uv[3] : TEXCOORD0;
};

v2f vert( appdata_img v )
{
	v2f o;
	o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
	float2 uv = MultiplyUV( UNITY_MATRIX_TEXTURE0, v.texcoord );
	o.uv[0] = uv;
	o.uv[1] = uv + float2(-_MainTex_TexelSize.x, -_MainTex_TexelSize.y);
	o.uv[2] = uv + float2(+_MainTex_TexelSize.x, -_MainTex_TexelSize.y);
	return o;
}


half4 frag (v2f i) : COLOR
{
	half4 original = tex2D(_MainTex, i.uv[0]);
	
	// three samples from normals+depth buffer		
	half4 normalD1 = tex2D(_NormalsTexture, i.uv[0]);
	half4 normalD2 = tex2D(_NormalsTexture, i.uv[1]);
	half4 normalD3 = tex2D(_NormalsTexture, i.uv[2]);
	
	// do not draw outline for objects rendered with the NoOutline version of RenderNormalsAndDepth shader:
	half4 ignore = half4(0,0,0,0.01);
	if( normalD1.a <= ignore.a || normalD2.a <= ignore.a || normalD3.a <= ignore.a )
		return original;
	
	// normals filter
	half3 n1 = normalD1.rgb*2-1;
	half3 n2 = normalD2.rgb*2-1;
	half3 n3 = normalD3.rgb*2-1;
	half2 ndiff;
	ndiff.x = dot( n1, n2 );
	ndiff.y = dot( n1, n3 );
	ndiff -= 0.9;
	ndiff = ndiff > half2(0,0) ? half2(1,1) : half2(0,0);
	half ndiff1 = ndiff.x * ndiff.y;
	original.rgb *= ndiff1;
	
	// depth filter
	float2 zdiff;
	zdiff.x = normalD1.a - normalD2.a;
	zdiff.y = normalD1.a - normalD3.a;
	// a small fix to make the depth discontinuity detection work well both for small and big distances:
	zdiff = abs( zdiff ) - 0.1*clamp(normalD1.a, 0.05, 1.0);
	zdiff = zdiff > half2(0,0) ? half2(0,0) : half2(1,1);
	original *= zdiff.x*zdiff.y;
	
	return original;
}
ENDCG
	}
}

Fallback off

}