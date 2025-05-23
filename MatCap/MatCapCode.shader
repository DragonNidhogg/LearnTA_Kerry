Shader "Custom/MatCapCode"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" {}
		_MatCap("MatCap", 2D) = "white" {}
		_RampTexture("RampTexture", 2D) = "white" {}
		_MatCapIntensity("MatCapIntensity", Float) = 1
		_MatCapAdd("MatCapAdd", 2D) = "white" {}
		_MatCapAddIntensity("MatCapAddIntensity", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        pass{
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        #include "UnityCG.cginc"

        sampler2D _MainTex;
        float4 _MainTex_ST;
        sampler2D _MatCapAdd;
        float _MatCapAddIntensity;
		sampler2D _MatCap;
		float _MatCapIntensity;
		sampler2D _RampTexture;

        struct a2v
        {
            float4 vertex :POSITION;
            float2 uv:TEXCOORD0;
            float3 normal:NORMAL;
        };

        struct v2f
        {
            float2 uv :TEXCOORD0;
            float4 vertex:SV_POSITION;
            float3 normal_world:TEXCOORD1;
            float3 pos_world:TEXCOORD2;
        };

        v2f vert(a2v v)
        {
            v2f o;
            o.vertex=UnityObjectToClipPos(v.vertex);
            o.uv=TRANSFORM_TEX(v.uv,_MainTex);
            float3 normal_world=mul(float4(v.normal,0.0),unity_WorldToObject);
            o.normal_world=normal_world;
            o.pos_world=mul(unity_ObjectToWorld,v.vertex);
            return o;
        }

        float4 frag(v2f i):SV_Target
        {
            float3 normal_world=normalize(i.normal_world);
            float3 normal_viewpos=mul(UNITY_MATRIX_V,float4(normal_world,0)).xyz;
            float2 uv_matcap=(normal_viewpos.xy+float2(1.0,1.0))*0.5;
            float4 matcap_color=tex2D(_MatCap,uv_matcap)*_MatCapIntensity;
            float4 diffuse_color=tex2D(_MainTex,i.uv);
            float4 matcap_add=tex2D(_MatCapAdd,uv_matcap);

            float3 view_dir=normalize(_WorldSpaceCameraPos.xyz-i.pos_world);
            float fresnel=1-saturate(dot(normal_world,view_dir));
            float2 uv_ramp=float2(fresnel,0.5);
            float4 ramp_color=tex2D(_RampTexture,uv_ramp);

            float4 col=diffuse_color*matcap_color*ramp_color+matcap_add*_MatCapAddIntensity;
            
            return col; 
        }

        ENDCG
    }
    }
    FallBack "Diffuse"
}
