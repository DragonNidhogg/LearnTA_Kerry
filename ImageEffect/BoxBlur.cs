using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode()]
public class NewBehaviourScript : MonoBehaviour
{
    public Material material;
    [Range(0, 10)]
    public int _Iteration = 4;
    [Range(0, 15)]
    public float _BlurRadius = 5.0f;
    [Range(1, 10)]
    public float _DownSample=2.0f; 
    public enum BlurMethods
    {
        BoxFliter,
        Grass
    }
    public BlurMethods BlurMethod;
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
    void OnRenderImage(RenderTexture source,RenderTexture destination)
    {
        if(BlurMethod==BlurMethods.BoxFliter)
        {
            int width=(int)(source.width/_DownSample);
            int height=(int)(source.height/_DownSample);

            RenderTexture RT1=RenderTexture.GetTemporary(width,height);
            RenderTexture RT2=RenderTexture.GetTemporary(width,height);

            Graphics.Blit(source,RT1);

            material.SetVector("_BlurOffset", new Vector4(_BlurRadius / source.width, _BlurRadius / source.height, 0,0));

            for (int i = 0; i < _Iteration; i++)
            {
                RenderTexture.ReleaseTemporary(RT2);
                width = width / 2;
                height = height / 2;
                RT2 = RenderTexture.GetTemporary(width, height);
                Graphics.Blit(RT1, RT2, material, 0);

                RenderTexture.ReleaseTemporary(RT1);
                width = width / 2;
                height = height / 2;
                RT1 = RenderTexture.GetTemporary(width, height);
                Graphics.Blit(RT2, RT1, material, 0);
            }
            for (int i = 0; i < _Iteration; i++)
            {
                RenderTexture.ReleaseTemporary(RT2);
                width = width * 2;
                height = height * 2;
                RT2 = RenderTexture.GetTemporary(width, height);
                Graphics.Blit(RT1, RT2, material, 0);

                RenderTexture.ReleaseTemporary(RT1);
                width = width * 2;
                height = height * 2;
                RT1 = RenderTexture.GetTemporary(width, height);
                Graphics.Blit(RT2, RT1, material, 0);
            }

             Graphics.Blit(RT1, destination);
            RenderTexture.ReleaseTemporary(RT1);
            RenderTexture.ReleaseTemporary(RT2);
        }
        if(BlurMethod==BlurMethods.Grass)
        {
            int width = (int)(source.width / _DownSample);
            int height = (int)(source.height / _DownSample);
            RenderTexture RT1 = RenderTexture.GetTemporary(width,height);
            RenderTexture RT2 = RenderTexture.GetTemporary(width, height);

            Graphics.Blit(source, RT1);

            material.SetVector("_BlurOffset", new Vector4(_BlurRadius / source.width, _BlurRadius / source.height, 0,0));
            for (int i = 0; i < _Iteration; i++)
            {
                Graphics.Blit(RT1, RT2, material, 1); //水平方向
                Graphics.Blit(RT2, RT1, material, 2); //垂直方向
            }

            Graphics.Blit(RT1, destination);

             //release
            RenderTexture.ReleaseTemporary(RT1);
            RenderTexture.ReleaseTemporary(RT2);
        }
    }
}
