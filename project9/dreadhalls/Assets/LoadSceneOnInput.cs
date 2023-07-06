using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LoadSceneOnInput : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		if (Input.GetAxis("Submit") == 1) {
			string currentSceneName = SceneManager.GetActiveScene().name;
			if (currentSceneName == "Title") {
				SceneManager.LoadScene("Play");
			}
			else if (currentSceneName == "Game Over") {
				SceneManager.LoadScene("Title");
			}
		}
	}
}
