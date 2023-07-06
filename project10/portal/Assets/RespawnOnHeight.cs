using UnityEngine;

public class RespawnOnHeight : MonoBehaviour
{
    public float respawnHeight = -15f;
    public Vector3 respawnPosition = new Vector3(-0.3f, -0.3f, -0.05f);

    private void Update()
    {
        if (transform.position.y <= respawnHeight)
        {
            transform.Translate(respawnPosition - transform.position, Space.World);
        }
    }
}
