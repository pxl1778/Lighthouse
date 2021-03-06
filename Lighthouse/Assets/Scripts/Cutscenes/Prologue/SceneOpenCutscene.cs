﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SceneOpenCutscene : Cutscene {

    Cinemachine.CinemachineVirtualCamera cutsceneCam;

    public override void StartCutscene()
    {
        base.StartCutscene();
        cutsceneCam = this.GetComponentInChildren<Cinemachine.CinemachineVirtualCamera>();
        cutsceneCam.Priority = 11;
        GameManager.instance.EventMan.endCutscene.AddListener(EndCutscene);
        cameraTimeline.Play();
        PlayCutscene();
    }

    protected override void PlayCutscene()
    {
    }

    public override void LerpCallback(string pName)
    {
        base.LerpCallback(pName);

        if (pName == "PlayerNodes")
        {
            if (objectDictionary[pName].Length > indexDictionary[pName])
            {
                gm.EventMan.movePlayerToPosition.Invoke(objectDictionary["PlayerNodes"][indexDictionary[pName]].transform.position, objectDictionary["PlayerNodes"][indexDictionary[pName]].delay, objectDictionary["PlayerNodes"][indexDictionary[pName]].running);
            }
        }
    }

    protected override void EndCutscene()
    {
        base.EndCutscene();
        GameManager.instance.EventMan.endCutscene.RemoveListener(EndCutscene);
        cutsceneCam.Priority = 0;
        GameObject.Find("TutorialCanvas").GetComponent<TutorialCanvasScript>().FadeInTutorial(0);
    }
}
