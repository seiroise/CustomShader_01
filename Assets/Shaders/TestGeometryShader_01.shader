Shader "CustomShader/TestGeometryShader_01" {
	Properties {
		_MainColor("Color", COLOR) = (1,1,1,1)
		_Randomness("Randomness", Range(0, 1)) = 0.5
		_Debug("Debug", Range(0, 1)) = 0.5
	}
	SubShader {
		Tags {"renderType" = "Opaque"}
		LOD 100

		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom

			#include "UnityCG.cginc"

			struct appdata {
				float4 vertex	: POSITION;
				float2 uv		: TEXCOORD0;
				float3 normal	: NORMAL;
			};

			struct v2f {
				float4 vertex	: SV_POSITION;
				float2 uv		: TEXCOORD0;
				float3 normal	: NORMAL;
				float3 worldPosition	: TEXCOORD1;
				float4 color	: TEXCOORD2;			//色
			};

			//プロパティの受取
			float4 _MainColor;
			float _Randomness;
			float _Debug;

			//乱数生成
			float rand(float2 co) {
				//fracは組み込み関数で小数点以下を返す
				return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
			}

			//RGBからHSVへの変換
			float3 rgb2hsv(float3 rgb) {
				float mi = min(min(rgb.x, rgb.y), rgb.z);
				float ma = max(max(rgb.x, rgb.y), rgb.z);
				float d = ma - mi;

				float3 hsv;
				hsv.z = ma;				//v
				if (ma != 0.0){
					hsv.y = d / ma;	//s
				}else{
					hsv.y = 0;			//s
				}
				if ( rgb.x == ma ) hsv.x = (rgb.y - rgb.z) / d;			// h
				else if (rgb.y == ma) hsv.x = 2 + (rgb.z - rgb.x) / d;	// h
				else hsv.x = 4 + (rgb.x - rgb.y) / d;					// h

				hsv.x /= 6;
				if (hsv.x < 0) hsv.x += 1;
				return hsv;
			}

			//HSVからRGBへの変換
			float3 hsv2rgb(float3 hsv) {
				float3 rgb;
				if(hsv.y == 0) {
					float v = hsv.z;
					rgb = float3(v, v, v);
				} else {
					float h = hsv.x * 6;
					float i = floor(h);
					float f = h - i;
					float a = hsv.z * (1 - hsv.y);
					float b = hsv.z * (1 - (hsv.y * f));
					float c = hsv.z * (1 - (hsv.y * (1 - f)));
					if(i < 1) {
						rgb = float3(hsv.z, c, a);
					} else if(i < 2) {
						rgb = float3(b, hsv.z, a);
					} else if(i < 3) {
						rgb = float3(a, hsv.z, c);
					} else if(i < 4) {
						rgb = float3(a, b, hsv.z);
					} else if(i < 5) {
						rgb = float3(c, a, hsv.z);
					} else {
						rgb = float3(hsv.z, a, b);
					}
				}
				return rgb;
			}

			//バーテックスシェーダ
			v2f vert(appdata v) {
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				o.normal = v.normal;
				o.worldPosition = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.color = 0.0;
				return o;
			}

			//ジオメトリシェーダ
			[maxvertexcount(3)]
			void geom(triangle v2f input[3], inout TriangleStream<v2f> OutputStream) {
				v2f test = (v2f)0;
				//頂点座標からベクトルを求め面の法線を計算する
				float3 normal = normalize(cross(input[1].worldPosition.xyz - input[0].worldPosition.xyz,
						 input[2].worldPosition.xyz - input[0].worldPosition.xyz));
				//RGBをHSVに変換
				float3 hsv = rgb2hsv(_MainColor);
				//s(色相)をいじる
				float r = rand(input[0].uv + input[1].uv + input[2].uv) * _Randomness - (_Randomness * 0.5);
				hsv.y += r;
				if(hsv.y > 1) {
					hsv.y -= (hsv.y - 1);
				} else if(hsv.y < 0) {
					hsv.y = abs(hsv.y);
				}
				//v(明度)をいじる
				hsv.z += _SinTime.x;
				float4 rgba = float4(hsv2rgb(hsv), _MainColor.w);
				//新しく追加する頂点の設定
				int i;
				for(i = 0; i < 3; ++i) {
					test.normal = normal;
					test.vertex = input[i].vertex;
					test.uv = input[i].uv;
					test.color = rgba;
					OutputStream.Append(test);
				}
			}

			//フラグメントシェーダ
			fixed4 frag(v2f i) : SV_Target {
				return i.color;
			}

			ENDCG
		}
	}
}