// Upgrade NOTE: replaced 'V2F_POS_FOG' with 'float4 pos : SV_POSITION'
// Upgrade NOTE: replaced 'glstate.matrix.mvp' with 'UNITY_MATRIX_MVP'

Shader "Custom/FertileGroundUnlit" {

Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Origin (RGB)", 2D) = "white" {}
	_MainTex2 ("Destination (RGB)", 2D) = "white" {}
	_Noise ("Noise", 2D) = "white" {}

	_ZeroDirection ("ZeroDirection", Vector) = (0,0,1,1)
	_ZeroDirectionPerp ("ZeroDirectionPerp", Vector) = (0,0,1,1)
	
	_Origin ("Origin", Vector) = (0,0,0,1)
	_Radius ("Radius", Float) = 0.0
	_Progress ("Progress", Range(0.0,1.0)) = 0.0
}

SubShader {
		Tags { "RenderType"="Opaque" }
        Pass {
 
CGPROGRAM
// Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members position)
#pragma exclude_renderers d3d11 xbox360
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

uniform sampler2D _MainTex;
uniform sampler2D _MainTex2;
uniform sampler2D _Noise;

uniform float4 _Color;
uniform float4 _ZeroDirection;
uniform float4 _ZeroDirectionPerp;

uniform float4 _Origin;
uniform float _Radius;
uniform float _Progress;

struct v2f {
	float4 pos : SV_POSITION;
    float4 uv[1] : TEXCOORD0;
    float4 diffuse : COLOR;
    float4 position;
};

v2f vert (appdata_base v)
{
    v2f o;
    o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
    o.uv[0] = TRANSFORM_UV(0).xyxy;
    o.position = v.vertex;
	
    return o;
}

float StatusOfTransformation(	float3 position,
								float3 origin,
								float radius,
								float waving);

half4 frag( v2f i ) : COLOR
{
    half4 color1 = tex2D( _MainTex, i.uv[0].xy );
    half4 color2 = tex2D( _MainTex2, i.uv[0].xy );

	float mult = StatusOfTransformation(i.position.xyz, _Origin.xyz, _Radius, _Progress);
	
	half4 color = lerp(color1, color2, mult);
	
    return color*_Color;
}


float StatusOfTransformation(	float3 position,
								float3 origin,
								float radius,
								float waving)
{
	float3 direction = position - origin.xyz;
	direction.y = 0.0;
	float dist = sqrt(dot(direction, direction));
	float3 directionNorm = direction/dist;
		
	float angleNorm = acos(dot(_ZeroDirection.xyz, directionNorm))*0.1591549431; //1/2pi = 0.1591549431
	if( dot(_ZeroDirectionPerp.xyz, directionNorm) < 0 )
		angleNorm = 1.0 - angleNorm;
	//high frequency contribution to edge noise:
	float edgeNoise = tex2D( _Noise, 3*direction.xz/_Radius ).y*0.1;
	//low frequency contribution to edge noisee (the big waves)
	float noise = tex2D( _Noise, float2(angleNorm+edgeNoise, waving) ).y;
		
	//linear falloff border:
	float mult = (_Radius - dist*noise*4.0)*7.0/dist;
	//sigmoidal (sigmf) falloff border:
	//float mult = 1/(1 + exp(-50.0*(dist - noise-0.0))); //to be adjusted
	//sharp falloff border:
	//float mult = 0;
	//if( radius > dist*noise*4.0 )
	//	mult = 1;
	
	return clamp(mult, 0.0, 1.0);
}


ENDCG

    }
}

}