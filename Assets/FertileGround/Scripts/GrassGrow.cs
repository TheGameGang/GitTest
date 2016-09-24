using UnityEngine;
using System.Collections;

public class GrassGrow : MonoBehaviour
{

    public Mesh grassPatchMesh;
    public float grassDensity = 18.0f;
    Vector3 Origin = new Vector3();

    System.Random r = new System.Random();

    void Start()
    {
        CreateGrassMesh();
        GetComponent<Renderer>().material.SetFloat("_Radius", 0);
        GetComponent<Renderer>().material.SetVector("_Origin", new Vector3());
        GetComponent<Renderer>().enabled = false;
    }

    void Update()
    {
        float time = Time.time * 0.02f + transform.localPosition.x * 0.02f - transform.localPosition.z * 0.02f;
        Vector4 wind = new Vector4(time, 1.0f, 0.8f, 1.0f);
        GetComponent<Renderer>().material.SetVector("_WaveAndDistance", wind);
    }

    public void UpdateVisibility(float radius, Vector3 origin)
    {
        if (!GetComponent<Renderer>().enabled)
            GetComponent<Renderer>().enabled = true;
        Vector3 scale = transform.localScale;
        transform.localScale = new Vector3(1.0f, 1.0f, 1.0f);
        Vector3 originTrans = transform.InverseTransformPoint(origin);
        transform.localScale = scale;

        GetComponent<Renderer>().material.SetFloat("_Radius", radius);
        GetComponent<Renderer>().material.SetVector("_Origin", originTrans);

    }

    public void SetToGrown()
    {
        GetComponent<Renderer>().enabled = true;
        float bigEnoughRadius = 10000.0f;
        GetComponent<Renderer>().material.SetFloat("_Radius", bigEnoughRadius);
    }

    void CreateGrassMesh()
    {
        int nrTrisInPatch = (int)(grassPatchMesh.triangles.Length / 3.0f);
        Vector3[] vertsPatch = grassPatchMesh.vertices;
        int[] trisPatch = grassPatchMesh.triangles;


        float areaOfPatch = 0.0f;
        for (int i = 0; i < nrTrisInPatch; i++)
        {
            Vector3 v1 = vertsPatch[trisPatch[3 * i + 1]] - vertsPatch[trisPatch[3 * i]];
            Vector3 v2 = vertsPatch[trisPatch[3 * i + 2]] - vertsPatch[trisPatch[3 * i]];
            areaOfPatch += Vector3.Cross(v1, v2).magnitude;
        }

        int nrGrassBlades = (int)(areaOfPatch * grassDensity);
        Vector3[] verts = new Vector3[nrGrassBlades * 4];
        Vector2[] uvs = new Vector2[nrGrassBlades * 4];
        int[] tris = new int[nrGrassBlades * 2 * 3];

        int g = 0; //g is the index of the current grassBlade
        int nrPatchTris = grassPatchMesh.triangles.Length / 3;
        for (int i = 0; i < nrPatchTris; i++)
        {
            Vector3 v1 = vertsPatch[trisPatch[3 * i + 1]] - vertsPatch[trisPatch[3 * i]];
            Vector3 v2 = vertsPatch[trisPatch[3 * i + 2]] - vertsPatch[trisPatch[3 * i]];
            float area = Vector3.Cross(v1, v2).magnitude;

            int nrGrassBladesForThisTri = (int)(area * grassDensity);

            for (int j = 0; j < nrGrassBladesForThisTri; j++)
            {
                if (g >= nrGrassBlades)
                    break;

                float x = (float)r.NextDouble();
                float y = (float)r.NextDouble();
                if (x + y > 1)
                {
                    x = 1.0f - x;
                    y = 1.0f - y;
                }
                Vector3 pos = v1 * x + v2 * y + vertsPatch[trisPatch[3 * i]];
                float scale = Mathf.Clamp(pos.y, 0.3f, 0.9f);
                pos.y = 0;

                Vector3 right = Vector3.right;
                Vector3 up = Vector3.up;

                Quaternion q = Quaternion.AngleAxis((float)r.NextDouble() * 360.0f, Vector3.up);
                right = q * right;

                q = Quaternion.AngleAxis(((float)r.NextDouble() - 0.5f) * 180.0f / 3.14f, right);
                up = q * up;

                right *= scale * 0.5f;
                up *= scale;

                verts[g * 4] = pos + right;
                verts[g * 4 + 1] = pos - right;
                verts[g * 4 + 2] = pos + right + up;
                verts[g * 4 + 3] = pos - right + up;

                uvs[g * 4] = Vector2.zero;
                uvs[g * 4 + 1] = Vector2.right;
                uvs[g * 4 + 2] = Vector2.up;
                uvs[g * 4 + 3] = Vector2.right + Vector2.up;

                tris[g * 6] = g * 4;
                tris[g * 6 + 1] = g * 4 + 1;
                tris[g * 6 + 2] = g * 4 + 2;

                tris[g * 6 + 3] = g * 4 + 2;
                tris[g * 6 + 4] = g * 4 + 1;
                tris[g * 6 + 5] = g * 4 + 3;

                g++;
            }

        }

        MeshFilter grassMeshFilter = gameObject.GetComponent(typeof(MeshFilter)) as MeshFilter;

        grassMeshFilter.mesh.vertices = verts;
        grassMeshFilter.mesh.triangles = tris;
        grassMeshFilter.mesh.uv = uvs;

    }

}
