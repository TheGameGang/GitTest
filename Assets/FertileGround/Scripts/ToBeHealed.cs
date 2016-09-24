using UnityEngine;
using System.Collections;

[RequireComponent(typeof(Renderer))]

public class ToBeHealed : MonoBehaviour
{
    Material[] Wasteland;
    public Material[] Transition;
    public Material[] Greenland;

    FertileGround.State m_state = FertileGround.State.wasteland;
    public FertileGround.State state
    {
        get { return m_state; }
        set
        {
            m_state = value;
            UpdateMaterials();
        }
    }

    void Start()
    {
        Wasteland = new Material[GetComponent<Renderer>().materials.Length];
        for (int i = 0; i < GetComponent<Renderer>().materials.Length; i++)
        {
            Wasteland[i] = GetComponent<Renderer>().materials[i];
        }
    }

    void UpdateMaterials()
    {
        if (m_state == FertileGround.State.greenland)
        {
            GetComponent<Renderer>().materials = Greenland;
        }
        else if (m_state == FertileGround.State.wasteland)
        {
            GetComponent<Renderer>().materials = Wasteland;
        }
        else if (m_state == FertileGround.State.transition)
        {
            GetComponent<Renderer>().materials = Transition;
        }
    }

    public void UpdateMaterialProperties(Vector3 zeroDirection, Vector3 zeroDirectionPerp, Vector3 origin, float radius, float progress)
    {
        foreach (Material m in GetComponent<Renderer>().materials)
        {
            m.SetVector("_ZeroDirection", zeroDirection);
            m.SetVector("_ZeroDirectionPerp", zeroDirectionPerp);

            m.SetVector("_Origin", origin);
            m.SetFloat("_Radius", radius);
            m.SetFloat("_Progress", progress);
        }
    }
}
