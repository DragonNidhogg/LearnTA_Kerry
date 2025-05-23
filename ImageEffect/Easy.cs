using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode()]
public class Easy : MonoBehaviour
{
    public Material material; 
    public float _Brightness;
    public float _Saturation;
    public float _Contrast;
    [Range(0.05f,3.0f)]
    public float _VignetteIntensity;
    [Range(1f,6f)]
    public float _VigentteRoundness;
    [Range(0.05f,5f)]
    public float _VignetteSmothness;
    public float _HueShift;

    void Start()
    {
        if(material==null||SystemInfo.supportsImageEffects==false
        ||material.shader==null||material.shader.isSupported==false)
        {
            enabled=false;
            return;
        }
    }

    // Update is called once per frame
    void OnRenderImage(RenderTexture sourse,RenderTexture destination)
    {
        material.SetFloat("_Brightness",_Brightness);
        material.SetFloat("_Saturation",_Saturation);
        material.SetFloat("_Contrast",_Contrast);
        material.SetFloat("_VignetteIntensity",_VignetteIntensity);
        material.SetFloat("_VigentteRoundness",_VigentteRoundness);
        material.SetFloat("_VignetteSmothness",_VignetteSmothness);
        material.SetFloat("_HueShift",_HueShift);

        Graphics.Blit(sourse,destination,material,0);
    }
}
