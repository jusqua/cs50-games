using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class DespawnOnHeight : MonoBehaviour
{
    public int height;
    private CharacterController characterController;

    void Start() {
        characterController = GetComponent<CharacterController>();
    }

    void Update() {
        if (characterController.transform.position.y < height) {
            Destroy(DontDestroy.instance.gameObject);
            SceneManager.LoadScene("Game Over");
        }
    }
}
