using UnityEngine;
using UnityEngine.UI;

public class ArchTrigger : MonoBehaviour
{
    private Text textComponent;

    // Use this for initialization
    void Start()
    {
        textComponent = GetComponentInChildren<Text>();

        // Start with the text disabled
        textComponent.enabled = false;
    }

    // Update is called once per frame
    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Arch")) {
            // Enable and display the text
            textComponent.enabled = true;
            textComponent.text = "You Won!";
        }
        
    }

    void Update() {
        if (Input.GetButtonDown("Jump"))
            {
                textComponent.enabled = false;
            }
    }
}
