using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GoalCollision : MonoBehaviour
{
    public GameObject target;

    private void OnTriggerEnter(Collider other) {
        target.SetActive(true);
    }
}
