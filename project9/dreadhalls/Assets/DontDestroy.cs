using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class DontDestroy : MonoBehaviour
{
    // Make this static so it's visible across all instances
    public static DontDestroy instance = null;


    private void Awake()
    {
        if (instance == null) {
            instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else if (instance != this) {
            Destroy(gameObject);
        }

        // execute onsceneloaded logic after the scene is loaded
        SceneManager.sceneLoaded += OnSceneLoaded;
    }

    // Called when a new scene is loaded
    private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        // Destroy if not play scene 
        if (scene.name != "Play")
        {
            Destroy(gameObject);
        }
    }
}