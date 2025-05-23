Shader "Hidden/Bloom"
{
    CGINCLUDE
	#include "UnityCG.cginc"

	sampler2D _MainTex;
	float4 _MainTex_TexelSize;
	float _Threshold;
	sampler2D _BloomTex;
	float _Intensity;

	half4 frag_PreFilter(v2f_img i) : SV_Target
	{
		half4 d = _MainTex_TexelSize.xyxy * half4(-1,-1,1,1);
		half4 color = 0;
		color += tex2D(_MainTex, i.uv + d.xy);
		color += tex2D(_MainTex, i.uv + d.zy);
		color += tex2D(_MainTex, i.uv + d.xw);
		color += tex2D(_MainTex, i.uv + d.zw);
		color *= 0.25;

		float br = max(max(color.r, color.g), color.b);
		br = max(0.0f, (br - _Threshold)) / max(br,0.00001f);
		color.rgb *= br;
		return color;
	}
	//降采样模糊
	half4 frag_DownsampleBox(v2f_img i) : SV_Target
	{
		half4 d = _MainTex_TexelSize.xyxy * half4(-1,-1,1,1);
		half4 s = 0;
		s += tex2D(_MainTex, i.uv + d.xy);
		s += tex2D(_MainTex, i.uv + d.zy);
		s += tex2D(_MainTex, i.uv + d.xw);
		s += tex2D(_MainTex, i.uv + d.zw);
		s *= 0.25;
		return s;
	}

	//升采样模糊
	half4 frag_UpsampleBox(v2f_img i) : SV_Target
	{
		half4 d = _MainTex_TexelSize.xyxy * half4(-1,-1,1,1);
		half4 color = 0;
		color += tex2D(_MainTex, i.uv + d.xy);
		color += tex2D(_MainTex, i.uv + d.zy);
		color += tex2D(_MainTex, i.uv + d.xw);
		color += tex2D(_MainTex, i.uv + d.zw);
		color *= 0.25;

		half4 color2 = tex2D(_BloomTex, i.uv);
		return color + color2;
	}

	//合并
	half4 frag_Combine(v2f_img i) : SV_Target
	{
		half4 d = _MainTex_TexelSize.xyxy * half4(-1,-1,1,1);
		half4 base_color = tex2D(_MainTex, i.uv);
		half4 bloom_color = tex2D(_BloomTex, i.uv);

		half3 final_color = base_color.rgb + bloom_color.rgb * _Intensity;

		return half4(final_color,1.0);
	}

	half4 frag_ACES (v2f_img i) : SV_Target
	{
		half4 col = tex2D(_MainTex, i.uv);
		half3 linear_color = pow(col.rgb, 2.2);
		float a = 2.51f;
		float b = 0.03f;
		float c = 2.43f;
		float d = 0.59f;
		float e = 0.14f;
		float3 encode_color = saturate((linear_color*(a*linear_color + b)) / (linear_color*(c*linear_color + d) + e));
		half3 final_color = pow(encode_color, 1.0 / 2.2);
		return float4(final_color,col.a);
	}

	ENDCG

	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BlurOffset("BlurOffset",Float) = 1 
	}
	SubShader
	{
		Cull Off ZWrite Off ZTest Always
		//0 阈值
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag_PreFilter
			ENDCG
		}
		//1 降采样模糊
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag_DownsampleBox
			ENDCG
		}
		//2 升采样模糊
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag_UpsampleBox
			ENDCG
		}
		//3 合并
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag_Combine
			ENDCG
		}
        //ACES_ToneMapping
        Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag_ACES
			ENDCG
		}
	}
}
