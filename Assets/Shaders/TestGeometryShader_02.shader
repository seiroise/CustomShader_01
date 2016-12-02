//2016.12.02
//-------------------------------------
//三角ポリゴンごとに描画する色を変えるシェーダ
//HSV指定
//-------------------------------------

Shader "CustomShader/TestGeometryShader_01" {
	Properties {
		//色相(hue)
		_HueMin("HueMin", Range(0, 1)) = 0.5
		_HueMax("HueMax", Range(0, 1)) = 0.6
		//彩度(Saturation)
		_SatMin("SatMin", Range(0, 1)) = 0.9
		_SatMax("SatMax", Range(0, 1)) = 1.0
		//明度(Value)
		_ValMin("ValMin", Range(0, 1)) = 0.9
		_ValMax("ValMax", Range(0, 1)) = 1.0
		//時間倍率
		_TimeScale("TimeScale", Range(0, 100)) = 10
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

			//バーテックスシェーダへの入力構造体
			struct appdata {
				float4 vertex	: POSITION;
				float2 uv		: TEXCOORD0;
				float3 normal	: NORMAL;
			};

			//バーテックスシェーダからジオメトリ、フラグメントシェーダの入力
			struct v2f {
				float4 vertex	: SV_POSITION;
				float2 uv		: TEXCOORD0;
				float3 normal	: NORMAL;
				float3 worldPosition	: TEXCOORD1;
				float4 color	: TEXCOORD2;			//色
			};

			//プロパティの受取
			float _HueMin, _HueMax;
			float _SatMin, _SatMax;
			float _ValMin, _ValMax;
			float _TimeScale;

			//乱数生成
			float rand(float2 co) {
				//fracは組み込み関数で小数点以下を返す
				return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
			}

			//指定した範囲の乱数を生成する
			float randRange(float min, float max, float2 co) {
				float delta = max - min;
				return min + rand(co) * delta;
			}

			//RGBからHSVへの変換
			float3 rgb2hsv(float3 rgb) {
				float mi = min(min(rgb.x, rgb.y), rgb.z);
				float ma = max(max(rgb.x, rgb.y), rgb.z);
				float d = ma - mi;

				float3 hsv;

				//v(明度)
				hsv.z = ma;

				//s(彩度)
				if (ma != 0.0){
					hsv.y = d / ma;
				}else{
					hsv.y = 0;
				}

				//h(色相)
				if ( rgb.x == ma ) hsv.x = (rgb.y - rgb.z) / d;
				else if (rgb.y == ma) hsv.x = 2 + (rgb.z - rgb.x) / d;
				else hsv.x = 4 + (rgb.x - rgb.y) / d;
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

				float3 hsv = float3(1, 1, 1);
				float2 sumUV = input[0].uv + input[1].uv + input[2].uv;
				float rNum = rand(sumUV);
				float offset = sin((_Time* _TimeScale) + rNum);
				//乱数からそれぞれの値を生成
				hsv.x = randRange(_HueMin, _HueMax, sumUV);
				hsv.y = randRange(_SatMin + offset, _SatMax + offset, sumUV);
				hsv.z = randRange(_ValMin + offset, _ValMax + offset, sumUV);

				//HSVをRGBに変換
				float4 rgba = float4(hsv2rgb(hsv), 1);

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