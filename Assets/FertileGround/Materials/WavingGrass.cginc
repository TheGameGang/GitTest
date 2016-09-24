// Upgrade NOTE: replaced 'glstate.matrix.mvp' with 'UNITY_MATRIX_MVP'

#include "UnityCG.cginc"
#include "TerrainEngine.cginc"

uniform float _Radius;
uniform float4 _Origin;

struct v2f {
	float4 pos : POSITION;
	float4 color : COLOR;
	float fog : FOGC;
	float4 uv : TEXCOORD0;
};

void WaveGrass (inout float4 vertex, float waveAmount);

v2f vert (appdata_grass v) {
	v2f o;

	float4 unchangedPosition = v.vertex;

	float waveAmount = v.color.a * _WaveAndDistance.z;
	//move only the upper vertices of the grass blades:
	if( v.vertex.y > 0.1 )
		WaveGrass (v.vertex, waveAmount);

	o.color = v.color;
		
	o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
	o.fog = o.pos.z;
	o.uv = v.texcoord;

	//fertile ground fade-in effect:
	float dist = length(_Origin - v.vertex);
	float mult = (_Radius - dist*2.0)*0.5;
	
	o.color.a = clamp(mult, 0.0f, 1.0f);

	return o;
}

//based on TerrainWaveGrass() from TerrainEngine.cginc, but no color animation
void WaveGrass (inout float4 vertex, float waveAmount)
{
	// Intel GMA X3100 cards on OS X have bugs in this vertex shader part (OS X 10.5.0-10.5.2),
	// transforming vertices to almost infinities.
	// So we multi-compile shaders, and use a non-waving one on X3100 cards.
	
	#ifndef INTEL_GMA_X3100_WORKAROUND
	
	const float4 _waveXSize = float4(0.012, 0.02, 0.06, 0.024) * _WaveAndDistance.y;
	const float4 _waveZSize = float4 (0.006, .02, 0.02, 0.05) * _WaveAndDistance.y;
	const float4 waveSpeed = float4 (0.3, .5, .4, 1.2) * 4;

	float4 _waveXmove = float4(0.012, 0.02, -0.06, 0.048) * 2;
	float4 _waveZmove = float4 (0.006, .02, -0.02, 0.1);

	float4 waves;
	waves = vertex.x * _waveXSize;
	waves += vertex.z * _waveZSize;

	// Add in time to model them over time
	waves += _WaveAndDistance.x * waveSpeed;

	float4 s, c;
	waves = frac (waves);
	FastSinCos (waves, s,c);

	s = s * s;

	s = s * waveAmount;

	float3 waveMove = float3 (0,0,0);
	waveMove.x = dot (s, _waveXmove);
	waveMove.z = dot (s, _waveZmove);

	vertex.xz -= waveMove.xz * _WaveAndDistance.z;
	
	#endif
}