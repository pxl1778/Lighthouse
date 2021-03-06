﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/water"
{
	Properties
	{
		_Color("Color", Color) = (1,0,0,1)
		_SpecColor("Specular Material Color", Color) = (1,1,1,1)
		_FoamColor("Foam Color", Color) = (1,1,1,1)
		_FoamPower("Foam Power", Range(0, 10)) = 1.0
		_Shininess("Shininess", Float) = 1.0
		_WaveLength("Wave length", Float) = 0.5
		_WaveHeight("Wave height", Float) = 0.5
		_WaveSpeed("Wave speed", Float) = 1.0
		_RandomHeight("Random height", Float) = 0.5
		_RandomSpeed("Random Speed", Float) = 0.5
	}
	SubShader
	{
	 
		Pass
		{
			Tags{ "RenderType"="Opaque"}
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			 
			float rand(float3 co)
			{
				return frac(sin(dot(co.xyz ,float3(12.9898,78.233,45.5432))) * 43758.5453);
			}
			 
			float rand2(float3 co)
			{
				return frac(sin(dot(co.xyz ,float3(19.9128,75.2,34.5122))) * 12765.5213);
			}
			 
			float _WaveLength;
			float _WaveHeight;
			float _WaveSpeed;
			float _RandomHeight;
			float _RandomSpeed;
			 
			uniform float4 _LightColor0;
			sampler2D _CameraDepthTexture;
			 
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float4 _FoamColor;
			uniform float _FoamPower;
			uniform float _Shininess;
			 
			struct v2g
			{
				float4 pos : SV_POSITION;
				float3 norm : NORMAL;
				float2 uv : TEXCOORD0;
			};
			 
			struct g2f
			{
				float4 pos : SV_POSITION;
				float3 norm : NORMAL;
				float3 diffuseColor : TEXCOORD1;
				float3 specularColor : TEXCOORD2;
				float3 wpos : WORLD;
				float  depth : DEPTH;
				float4 scrPos : SCREEN;
			};
			
			v2g vert(appdata_full v)
			{
				float4 v0 = mul(unity_ObjectToWorld, v.vertex);
				 
				float phase0 = (_WaveHeight)* sin((_Time[1] * _WaveSpeed) + (v0.x * _WaveLength) + (v0.z * _WaveLength) + rand2(v0.xzz));
				float phase0_1 = (_RandomHeight)*sin(cos(rand(v0.xzz) * _RandomHeight * cos(_Time[1] * _RandomSpeed * sin(rand(v0.xxz)))));
				 
				v0.y += phase0 + phase0_1;
				 
				v.vertex = mul(unity_WorldToObject, v0);
				 
				v2g OUT;
				OUT.pos = v.vertex;
				OUT.norm = v.normal;
				OUT.uv = v.texcoord;
				return OUT;
			}

			[maxvertexcount(3)]
			void geom(triangle v2g i[3], inout TriangleStream<g2f> triStream){
			float3 v0 = i[0].pos.xyz;
			float3 v1 = i[1].pos.xyz;
			float3 v2 = i[2].pos.xyz;
			 
			float3 centerPos = (v0 + v1 + v2) / 3.0;
			 
			float3 vn = normalize(cross(v1 - v0, v2 - v0));
			 
			float4x4 modelMatrix = unity_ObjectToWorld;
			float4x4 modelMatrixInverse = unity_WorldToObject;
			 
			float3 normalDirection = normalize(mul(float4(vn, 0.0), modelMatrixInverse).xyz);
			float3 viewDirection = normalize(_WorldSpaceCameraPos - mul(modelMatrix, float4(centerPos, 0.0)).xyz);
			float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
			float attenuation = 1.0;
			 
			float3 ambientLighting =
			UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
			 
			float3 diffuseReflection =
			attenuation * _LightColor0.rgb * _Color.rgb
			* max(0.0, dot(normalDirection, lightDirection));

			//diffuseReflection = lightDirection;
			 
			float3 specularReflection;
			if(dot(normalDirection, lightDirection) < 0.0){
				specularReflection = float3(0.0, 0.0, 0.0);
			}
			else{
				specularReflection = attenuation * _LightColor0.rgb
				* _SpecColor.rgb * pow(max(0.0, dot(
				reflect(-lightDirection, normalDirection),
				viewDirection)), _Shininess);
			}

			//specularReflection = float3(0.0f, 0.0f, 0.0f);
			//diffuseReflection = float3(0.0f, 0.0f, 0.0f);
			 
			g2f OUT;
			OUT.pos = UnityObjectToClipPos(i[0].pos);
			OUT.norm = UnityObjectToWorldNormal(vn);
			OUT.diffuseColor = ambientLighting + diffuseReflection;
			OUT.specularColor = specularReflection;
			OUT.wpos = mul(unity_ObjectToWorld, i[0].pos).xyz;
			OUT.depth = (UnityObjectToClipPos(i[0].pos) * -1).z * _ProjectionParams.w;
			OUT.scrPos = ComputeScreenPos(UnityObjectToClipPos(i[0].pos));
			triStream.Append(OUT);
			 
			OUT.pos = UnityObjectToClipPos(i[1].pos);
			OUT.norm = UnityObjectToWorldNormal(vn);
			OUT.diffuseColor = ambientLighting + diffuseReflection;
			OUT.specularColor = specularReflection;
			OUT.wpos = mul(unity_ObjectToWorld, i[1].pos).xyz;
			OUT.depth = (UnityObjectToClipPos(i[1].pos) * -1).z * _ProjectionParams.w;
			OUT.scrPos = ComputeScreenPos(UnityObjectToClipPos(i[1].pos));
			triStream.Append(OUT);
			 
			OUT.pos = UnityObjectToClipPos(i[2].pos);
			OUT.norm = UnityObjectToWorldNormal(vn);
			OUT.diffuseColor = ambientLighting + diffuseReflection;
			OUT.specularColor = specularReflection;
			OUT.wpos = mul(unity_ObjectToWorld, i[2].pos).xyz;
			OUT.depth = (UnityObjectToClipPos(i[2].pos) * -1).z * _ProjectionParams.w;
			OUT.scrPos = ComputeScreenPos(UnityObjectToClipPos(i[2].pos));
			triStream.Append(OUT);
			}
			
			fixed4 frag (g2f i) : SV_Target
			{
				half3 viewDirection = normalize(i.wpos - _WorldSpaceCameraPos);
				half depth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos))); //depth
				half4 foamLine = 1 - saturate(_FoamPower * (depth - i.scrPos.w));
				float3 lightPos = float3(unity_4LightPosX0[0], unity_4LightPosY0[0], unity_4LightPosZ0[0]);
				float3 lightDir = normalize(lightPos - i.wpos);
				float3 lightDistance = lightPos - i.wpos;
				float nDotL = saturate(dot(i.norm, lightDir));
				float attenuation = 1.0 / (1 + unity_4LightAtten0[0] * pow(dot(lightDistance, lightDistance), 2));
				float4 pointLight = nDotL * unity_LightColor[0] * attenuation;
				float4 lightColor = float4(i.specularColor + i.diffuseColor, 1.3 - saturate(0.1f + dot(i.norm, -viewDirection))) + pointLight;
				lightColor.a = 1; //get rid of for transparency
				return (lightColor * step(-0.5, -foamLine)) + (step(0.5, foamLine) * _FoamColor);
			}
			ENDCG
		}
	}
}