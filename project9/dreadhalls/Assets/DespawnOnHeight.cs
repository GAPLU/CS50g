using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class DespawnOnHeight: MonoBehaviour {

    // respawn logic
    void Update() {
        if (this.transform.position.y <= -25) {
            SceneManager.LoadScene("Game Over");
        }
    }
}
