Shader "Custom/FlatNoOutline" {
Properties {
	_Color ("Main Color", Color) = (0,1,1,1)
}
Category {
	Tags { "RenderType"="NoOutline" }
	SubShader {
		Pass {
            Color [_Color]
        }
	}
}
}
