﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GrassScript : MonoBehaviour {

    private GameObject player;
    private GameObject glow;
    private Material mat;
    private Renderer grassRenderer;
    private MaterialPropertyBlock propBlock;
    [SerializeField]
    //private Color topColor = new Color(0, .796f, .368f, 1);
    private Color topColor;
    [SerializeField]
    //private Color bottomColor = new Color(0, .247f, .588f, 1);
    private Color bottomColor;

    // Use this for initialization
    void Start () {
        player = GameObject.Find("Player");
        glow = GameObject.Find("Dog");
        //Terrain t = this.transform.GetComponent<Terrain>();
        //if(t != null)
        //{
        //    mat = t.materialTemplate;
        //}
        //else
        //{
            mat = this.transform.GetComponent<MeshRenderer>().sharedMaterial;
            grassRenderer = this.transform.GetComponent<Renderer>();
        //}
        propBlock = new MaterialPropertyBlock();
        if (grassRenderer != null)
        {
            grassRenderer.GetPropertyBlock(propBlock);
            if (propBlock != null)
            {
                propBlock.SetColor("_Color", topColor);
                propBlock.SetColor("_BottomColor", bottomColor);
                grassRenderer.SetPropertyBlock(propBlock);
            }
        }
    }
	
	// Update is called once per frame
	void Update () {
        mat.SetVector("_ObjectPoint", new Vector4(player.transform.position.x, player.transform.position.y + 0.25f, player.transform.position.z, 0));
        if(glow != null)
        {
            mat.SetVector("_GlowObjectPoint", new Vector4(glow.transform.position.x, glow.transform.position.y, glow.transform.position.z, 0));
        }
        else
        {
            mat.SetVector("_GlowObjectPoint", new Vector4(0, -500, 0, 0));
        }
    }
}
