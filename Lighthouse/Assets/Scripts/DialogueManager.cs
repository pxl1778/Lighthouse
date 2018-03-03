﻿using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.UI;

public class DialogueManager : MonoBehaviour {
    public static DialogueManager instance = null;

    private Dictionary<string, string> lines = new Dictionary<string, string>();
    private DialogueSystem originalDialog;
    private GameManager gm;

    void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else if (instance != null)
        {
            Destroy(gameObject);
        }
        DontDestroyOnLoad(gameObject);

        string dialoguePath = Application.dataPath + "/Scripts/NPC Scripts/CharacterDialogue/dialogue.txt";
        string jsonText = "";
        //reading in the file
        try
        {
            StreamReader sr = new StreamReader(dialoguePath);
            using (sr)
            {
                while (sr.Peek() >= 0)
                {
                    jsonText += sr.ReadLine();
                }
            }
            originalDialog = JsonUtility.FromJson<DialogueSystem>(jsonText);
        }
        catch (IOException e)
        {
            print(e.Message);
        }

        for (int i = 0; i < originalDialog.packs.Length; i++)
        {
            for (int j = 0; j < originalDialog.packs[i].objects.Length; j++)
            {
                lines.Add(originalDialog.packs[i].objects[j].name, originalDialog.packs[i].objects[j].text);
            }
        }
    }

    void Start () {
    }

    public string getLine(string pLineName)
    {
        if (lines.ContainsKey(pLineName))
        {
            return lines[pLineName];
        }
        else
        {
            return "Line not found";
        }
    }
}