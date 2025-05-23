using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode()]
public class Bloom : MonoBehaviour
{

    public Material material;
    [Range(0, 10)]
    public float _Intensity = 1;
    [Range(0, 2)]
    public float _Threshold = 1;
     [Range(1, 10)]
    public float _DownSample=2.0f; 
    [Range(0, 10)]
    public int _Iteration = 4;


    void Start () {
        if (material == null || SystemInfo.supportsImageEffects == false
            || material.shader == null || material.shader.isSupported == false)
        {
            enabled = false;
            return;
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        float intensity = Mathf.Exp(_Intensity / 10.0f * 0.693f) - 1.0f;
        int width=(int)(source.width/_DownSample);
        int height=(int)(source.height/_DownSample);
        material.SetFloat("_Intensity", intensity);
        material.SetFloat("_Threshold", _Threshold);
        RenderTexture RT1=RenderTexture.GetTemporary(width,height);
        RenderTexture RT2=RenderTexture.GetTemporary(width,height);
        
        Graphics.Blit(source, RT1, material,0);

        material.SetTexture("_BloomTex", source);
        
        for (int i = 0; i < _Iteration; i++)
        {
            RenderTexture.ReleaseTemporary(RT2);
            width = width / 2;
            height = height / 2;
            RT2 = RenderTexture.GetTemporary(width, height);
            Graphics.Blit(RT1, RT2, material, 1);

            RenderTexture.ReleaseTemporary(RT1);
            width = width / 2;
            height = height / 2;
            RT1 = RenderTexture.GetTemporary(width, height);
            Graphics.Blit(RT2, RT1, material, 1);
        }
        for (int i = 0; i < _Iteration; i++)
        {
            RenderTexture.ReleaseTemporary(RT2);
            width = width * 2;
            height = height * 2;
            RT2 = RenderTexture.GetTemporary(width, height);
            Graphics.Blit(RT1, RT2, material, 2);

            RenderTexture.ReleaseTemporary(RT1);
            width = width * 2;
            height = height * 2;
            RT1 = RenderTexture.GetTemporary(width, height);
            Graphics.Blit(RT2, RT1, material, 2);
        }

        material.SetTexture("_BloomTex", RT1);

        Graphics.Blit(source, RT2, material, 3);
        Graphics.Blit(RT2, destination, material, 4);
        RenderTexture.ReleaseTemporary(RT1);
        RenderTexture.ReleaseTemporary(RT2);
    }
}
