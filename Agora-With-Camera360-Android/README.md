# Agora-With-Camera360-Android

*English | [中文](README.zh.md)*

## Prepare Camera360 Prettify SDK

You need to contact Camera360 for customized SDK archives. Once you receive an SDK archive, you should find in it a prettify engine aar, a model file and a licence key string.

* Copy the aar library to `app/libs`. Here we use **PgPrettifyEngine-release.aar**, add module dependency if needed;

* Copy the model file to `app/src/main/res/raw`， remember to add an extension name so that it can be found in the resources (R.raw.xxx). In this project, we use **megvii_facepp.model**;

* Copy the licence key string into `app/src/main/res/values/strings.xml`, replace <#LICENCE#> with your key:

```
<string name="camera_360_licence"><#LICENCE#></string>
```

Note that if you introduce this demo into your project, the Camera360 sdk must be built based on your package name. Contact Camera360 before starting your own project.

## Apply for an Agora App ID

In order to build and run the sample application you must obtain an App ID:

1. Create a developer account at [agora.io](https://sso.agora.io/en/v2/signup). Once you finish the signup process, you will be redirected to the Dashboard.
2. Navigate in the Dashboard tree on the left to **Projects** > **Project List**, and apply for a free App ID.
3. Copy App id into `app/src/main/res/values/strings.xml`, replace <#YOUR_APP_ID#> with your App Id

```
<string name="agora_app_id"><#YOUR_APP_ID#></string>
```