# Agora-With-Camera360-Android

## 准备 Camera360 美颜 SDK

您需要联系 Camera360 美颜的工作人员为您定制 SDK 压缩包。 SDK 压缩包包含了一个 aar 库文件、一个模型文件和一个授权字符串。

* 将 aar 库文件拷贝到 `app/libs` 文件夹. 此项目中将其命名为 **PgPrettifyEngine-release.aar**, 若需要您可以添加模块的依赖；

* 将模型文件拷贝到 `app/src/main/res/raw` 文件夹， 您可能需要将模型文件重命名，添加扩展名以便在资源下看到您的文件 (R.raw.xxx)。 此项目将其命名为 **megvii_facepp.model**;

* 将授权字符串拷贝到 `app/src/main/res/values/strings.xml`, 替换掉 <#LICENCE#> 如下:

```
<string name="camera_360_licence"><#LICENCE#></string>
```

请注意美颜 SDK 是与应用的包名进行绑定的，在开发您的项目之前务必要联系 Camera360 的工作人员。

## 申请 Agora App ID

为了正常运行 RTC 相关功能，您必须先获取一个 Agora App ID:

1. 创建一个开发者账户 [agora.io](https://sso.agora.io/cn/v2/signup). 结束注册流程后，会将您重定位到 Dashboard；
2. Dashboard 左侧的导航栏上找到 **项目** > **项目列表**，可以免费申请 App ID.
3. 将您选用的APP ID 拷贝至 `app/src/main/res/values/strings.xml`, 替换掉 <#YOUR_APP_ID#> 如下：

```
<string name="agora_app_id"><#YOUR_APP_ID#></string>
```