Shader "Unlit/BattleFader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_TransitMap("TransitMap", 2D) = "white" {}
		_Color("Tint", Color) = (1, 1, 1, 1)
		_Cutoff("Cutoff", Range(0, 1)) = 0
		_Fade("Fade", Range(0, 1)) = 0
		[MaterialToggle]_Distort("Distort", Float ) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _TransitMap;
			float _Cutoff;
			float _Fade;
			float _Distort;
			float4 _Color;
			float4 _MainTex_TexelSize;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.uv1 = v.uv;

#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
					o.uv1.y = 1 - o.uv1.y;
#endif

				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target
			{
				float3 tansit = tex2D(_TransitMap, i.uv);

				float2 dir = float2(0, 0);
				
				if (_Distort)
					dir = normalize(float2((tansit.r - .5) * 2, (tansit.g - .5) * 2));

				float4 col = tex2D(_MainTex, i.uv + _Cutoff * dir);

				if (tansit.b < _Cutoff)
					return _Color;
				
				return lerp(col, _Color, _Fade);
			}
			ENDCG
		}
	}
}
