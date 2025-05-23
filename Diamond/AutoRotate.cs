using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotation : MonoBehaviour
{
     public float rotationSpeed = 50.0f;

    // Start is called before the first frame update
    void Start()
    {
        // 如果需要在开始时就初始化一些状态，可以在这里进行
    }

    // Update is called once per frame
    void Update()
    {
        // 使用 Time.time 来累加旋转角度，使物体随时间旋转
        transform.Rotate(Vector3.up, rotationSpeed * Time.deltaTime);
    }
}
