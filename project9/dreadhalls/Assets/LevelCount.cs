using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;   
using UnityEngine.SceneManagement;

public class LevelCount : MonoBehaviour {

    // access to the text component
    private Text textComponent;
    // current level
    public static int Level = 1;
    
    private void Start() {
        // Get the text field
        textComponent = GetComponent<Text>();
        // Update the text initially
        UpdateLevelText();
    }

    // reset the level when the game is over
    private void OnSceneLoaded(Scene scene, LoadSceneMode mode) {
        if (scene.name == "Game Over") {
            Level = 1;
        }

        UpdateLevelText();
    }
    // update the text field
    private void UpdateLevelText() {
        // Update the text value of the Text component with the current level
        textComponent.text = "Level " + Level;
    }
    private void Awake()
    {
        // Check if another instance of LevelCount already exists
        LevelCount[] levelCountInstances = FindObjectsOfType<LevelCount>();
        if (levelCountInstances.Length > 1)
        {
            // Destroy this instance if another one already exists
            Destroy(gameObject);
        }
        else
        {
            // Preserve this instance when loading a new scene
            DontDestroyOnLoad(gameObject);

            // execute onsceneloaded logic
            SceneManager.sceneLoaded += OnSceneLoaded;
        }
    }

}
