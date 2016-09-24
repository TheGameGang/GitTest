using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class CameraController : MonoBehaviour
{
    public Transform target;
    public float angle = 55.0f;
    public float startDistance = 24.0f;
    float distance;
    public float minDistance = 10.0f;
    public float maxDistance = 90.0f;
    public float zoomSpeed = 200.0f;
    public bool smooth = true;
    public float turnSpeed = 40.0f;
    public bool invertRotation = false;
	float moveDamping = 3.0f;
    
    void Awake()
    {
        distance = startDistance;
    }

    void FixedUpdate()
    {
    	Vector3 prevPosition = transform.position;

        Vector3 newRelativePos = prevPosition - target.position;
        newRelativePos.y = 0.0f;
        newRelativePos = Vector3.Normalize(newRelativePos);
        newRelativePos *= Mathf.Cos(angle * Mathf.Deg2Rad) * distance;
        newRelativePos.y = Mathf.Sin(angle * Mathf.Deg2Rad) * distance;

        //position
        if (!smooth)
            transform.position = target.position + newRelativePos;
        else
            transform.position = Vector3.Lerp(prevPosition, target.position + newRelativePos, Time.deltaTime * moveDamping);

        //look at
        transform.rotation = Quaternion.LookRotation(target.position - transform.position);
    	
        MouseTurn();
    }

    void Update()
    {
        float scroll = Input.GetAxis("Mouse ScrollWheel");
        if (scroll != 0)
        {
            distance -= Mathf.Sign(scroll) * scroll * scroll * zoomSpeed;
            if (distance > maxDistance)
                distance = maxDistance;
            if (distance < minDistance)
                distance = minDistance;
        }
    }

    Vector2 lastMousePos;
    bool inMouseRotation = false;
    public float mouseTurnSpeed = 15.0f;

    void MouseTurn()
    {
        if (Input.GetMouseButton(1) || ( Input.GetMouseButton(0) && Input.GetKey(KeyCode.LeftControl) ))
        {
            if (!inMouseRotation)
            {
                inMouseRotation = true;
                lastMousePos = Input.mousePosition;
            }
        }
        else
        {
            inMouseRotation = false;
        }

        if (inMouseRotation)
        {
            float mouseDelta = Input.mousePosition.x - lastMousePos.x;
            transform.RotateAround(target.position, Vector3.up, 0.02f * mouseTurnSpeed * mouseDelta);
            lastMousePos = Input.mousePosition;
        }
    }
}
