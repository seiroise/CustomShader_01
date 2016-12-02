Shader "CustomShader/TestShader_01" {
	SubShader {

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			//入力データ
			struct appdata {
				float4 vertex		: POSITION;
				float2 uv			: TEXCOORD0;
				float2 uv2			: TEXCOORD1;
				fixed4 color		: COLOR;
			};

			//頂点シェーダからフラグメントシェーダへの入力
			struct v2f {
				float4 vertex	: SV_POSITION;
				float2 uv		: TEXCOORD0;
				float2 uv2		: TEXCOORD1;
			};
			
			//頂点シェーダ
			v2f vert (appdata v) {
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				o.uv2 = v.uv2;
				return o;
			}
			
			//フラグメントシェーダ
			fixed4 frag (v2f i) : SV_Target {
				fixed4 col = fixed4(i.uv2.y % 16 / 16, 0.0, 0.0, 0.0);
				return col;
			}
			ENDCG
		}
	}
}
