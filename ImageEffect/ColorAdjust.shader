Shader "Hidden/ColorAdjust"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Brightness("_Brightness",Float)=1
        _Saturation("_Saturation",Float)=1
        _Contrast("_Contrast",Float)=1
        _VignetteIntensity("_VignetteIntensity",Range(0.05,3.0))=1.5
        _VigentteRoundness("_VigentteRoundness",Range(1,6))=5
        _VignetteSmothness("_VignetteSmothness",Range(0.05,5))=5
    }   
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex; 
            float _Brightness;
            float _Saturation;
            float _Contrast;
            float _VignetteIntensity;
            float _VigentteRoundness;
            float _VignetteSmothness;

            fixed4 frag (v2f_img i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                half3 finalcol=col.rgb*_Brightness;

                float lumin=dot(finalcol,float3(0.22,0.707,0.071));
                finalcol=lerp(lumin,finalcol,_Saturation);

                float3 midpoint=float3(0.5,0.5,0.5);
                finalcol=lerp(midpoint,finalcol,_Contrast);

                float2 d=abs(i.uv-half2(0.5,0.5))*_VignetteIntensity;
                d=pow(saturate(d),_VigentteRoundness);
                float dist=length(d);
                float vfactor=pow(saturate(1.0-dist*dist),_VignetteSmothness);

                finalcol=finalcol*vfactor;

                return float4(finalcol,col.a);
            }
            ENDCG
        }
    }
}
