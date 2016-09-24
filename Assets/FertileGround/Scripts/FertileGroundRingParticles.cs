using UnityEngine;
using System.Collections;

public class FertileGroundRingParticles : MonoBehaviour
{
    public float emitterSizeMultiplier = 1.0f;
    public float emissionMultiplier = 30.0f;

    void Start()
    {
        GetComponent<ParticleEmitter>().emit = false;
    }

    public void StartRing()
    {
        GetComponent<ParticleEmitter>().emit = true;
    }

    public void UpdateRing(float radius)
    {
        float r = radius * emitterSizeMultiplier;
        transform.localScale = new Vector3(r, r, r);
        GetComponent<ParticleEmitter>().minEmission = GetComponent<ParticleEmitter>().maxEmission = r * emissionMultiplier;
    }

    public void StopRing()
    {
        GetComponent<ParticleEmitter>().emit = false;
    }
}
