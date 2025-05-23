Shader "Hidden/BoxBlur"
{
    CGINCLUDE
    #include "UnityCG.cginc"

    sampler2D _MainTex; 
    float4 _BlurOffset;

    fixed4 frag_BoxFilter_9 (v2f_img i) : SV_Target
    {
        half4 s = tex2D(_MainTex, i.uv);
        half4 d = _BlurOffset.xyxy*float4(-1,-1,1,1);
                
        s += tex2D(_MainTex, i.uv+d.xy);
        s += tex2D(_MainTex, i.uv+d.xw);
        s += tex2D(_MainTex, i.uv+d.zy);
        s += tex2D(_MainTex, i.uv+d.zw);
        s += tex2D(_MainTex, i.uv+half2(0.0,d.y));
        s += tex2D(_MainTex, i.uv+half2(0.0,d.w));
        s += tex2D(_MainTex, i.uv+half2(d.x,0.0));
        s += tex2D(_MainTex, i.uv+half2(d.z,0.0));

        s=s/9.0;
             
        return s;
    }
    half4 frag_HorizontalBlur(v2f_img i) : SV_Target
	{
		half2 uv1 = i.uv + _BlurOffset.xy * half2(1, 0) * -2.0;
		half2 uv2 = i.uv + _BlurOffset.xy * half2(1, 0) * -1.0;
		half2 uv3 = i.uv;
		half2 uv4 = i.uv + _BlurOffset.xy * half2(1, 0) * 1.0;
		half2 uv5 = i.uv + _BlurOffset.xy * half2(1, 0) * 2.0;

		half4 s = 0;
		s += tex2D(_MainTex, uv1) * 0.05;
		s += tex2D(_MainTex, uv2) * 0.25;
		s += tex2D(_MainTex, uv3) * 0.40;
		s += tex2D(_MainTex, uv4) * 0.25;
		s += tex2D(_MainTex, uv5) * 0.05;
		return s;
	}

	half4 frag_VerticalBlur(v2f_img i) : SV_Target
	{
		half2 uv1 = i.uv + _BlurOffset.xy * half2(0, 1) * -2.0;
		half2 uv2 = i.uv + _BlurOffset.xy * half2(0, 1) * -1.0;
		half2 uv3 = i.uv;
		half2 uv4 = i.uv + _BlurOffset.xy * half2(0, 1) * 1.0;
		half2 uv5 = i.uv + _BlurOffset.xy * half2(0, 1) * 2.0;

		half4 s = 0;
		s += tex2D(_MainTex, uv1) * 0.05;
		s += tex2D(_MainTex, uv2) * 0.25;
		s += tex2D(_MainTex, uv3) * 0.40;
		s += tex2D(_MainTex, uv4) * 0.25;
		s += tex2D(_MainTex, uv5) * 0.05;
		return s;
	}
    ENDCG

     Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurOffset("_BlurOffset",Float)=1
    }   
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag_BoxFilter_9
            ENDCG
        }
        Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag_HorizontalBlur
			ENDCG
		}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag_VerticalBlur
			ENDCG
		}
    }
}
