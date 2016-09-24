using UnityEngine;
using System.Collections;

public class FertileGround : MonoBehaviour
{
    public float maxRadius = 10.0f;
    public ToBeHealed[] toBeHealed;
    public FertileGroundRingParticles Ring;
    public GrassGrow Grass;

    float healingSpeed = 2.0f;

    public enum State
    {
        wasteland,
        transition,
        greenland
    }

    State _state = State.wasteland;
    public State state
    {
        get { return _state; }
        set
        {
            State oldState = _state;
            _state = value;
            UpdateState(oldState);
        }
    }

    float healingStartTime = 0.0f;

    void Update()
    {
        if( Input.GetMouseButtonDown(0) )
        	StartTransition();

        if (state == State.transition)
            UpdateHealing();
    }

    public void StartTransition()
    {
        state = State.transition;
    }

    public void SetToGreenland()
    {
        state = State.greenland;
        Grass.SetToGrown();
    }

    void UpdateState(State oldState)
    {
        foreach (ToBeHealed tbh in toBeHealed)
        {
            if (!tbh)
                continue;
            tbh.state = state;
        }

        if (oldState != State.transition && state == State.transition)
        {
            healingStartTime = Time.time;
            Ring.StartRing();
        }
    }

    void UpdateHealing()
    {
        float t = Time.time - healingStartTime;
        float progress = Mathf.PingPong(t * 0.05f * healingSpeed, 1.0f);
        float radius = t * 0.17f * healingSpeed + 0.7f;
        radius = Mathf.Pow( radius, 3 );

        if (radius > maxRadius)
        {
            state = State.greenland;
            Ring.StopRing();
            return;
        }

        Vector3 pos = transform.position;

        foreach (ToBeHealed tbh in toBeHealed)
        {
            if (!tbh)
                continue;

			//these operations transform vectors and points needed in the shader to 
			//local space of the object undergoing the transition
            Vector3 scale = tbh.transform.localScale;

            tbh.transform.localScale = new Vector3(1.0f, 1.0f, 1.0f);

            Vector3 origin = tbh.transform.InverseTransformPoint(pos);
			Vector3 zeroDirection = tbh.transform.InverseTransformDirection(Vector3.forward);
			Vector3 zeroDirectionPerp = tbh.transform.InverseTransformDirection(Vector3.right);

            tbh.transform.localScale = scale;

            tbh.UpdateMaterialProperties(zeroDirection, zeroDirectionPerp, origin, radius, progress);
        }

        Ring.UpdateRing(radius);
        Grass.UpdateVisibility(0.98f * radius, transform.position);
    }
}
