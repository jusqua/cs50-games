using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class RenderMazeInfo : MonoBehaviour
{
	public static int mazeNum = 0;
    // Start is called before the first frame update
    void Start() {
        mazeNum++;
        var uiText = gameObject.GetComponent<Text>();
        uiText.text = "Maze " + mazeNum;
    }
}
