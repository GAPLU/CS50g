using UnityEngine;
using System.Collections;

public class GemSpawner : MonoBehaviour {

	public GameObject[] prefabs;

	// Use this for initialization
	void Start () {

		// infinite coin spawning function, asynchronous
		StartCoroutine(SpawnGems());
	}

	// Update is called once per frame
	void Update () {

	}

	IEnumerator SpawnGems() {
		while (true) {


            Instantiate(prefabs[Random.Range(0, prefabs.Length)], new Vector3(28, Random.Range(-10, 10), 10), Quaternion.identity);

			// pause 10-15 seconds until the next gem spawns
			yield return new WaitForSeconds(Random.Range(10, 15));
		}
	}
}
