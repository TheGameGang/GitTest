Shader "Custom/Flat" {
Properties {
	_Color ("Main Color", Color) = (0,1,1,1)
}
Category {
	Tags { "RenderType"="Opaque" }
	SubShader {
		Pass {
            Color [_Color]
        }
	}
}
}
