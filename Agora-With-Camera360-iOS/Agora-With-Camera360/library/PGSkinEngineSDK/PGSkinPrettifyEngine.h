//
//  PGSkinPrettifyEngine.h
//  PGSkinPrettifyEngine
//
//  Created by ZhangJingQi on 16/5/26.
//  Copyright © 2016-2017年 Chengdu PinGuo Technology Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "PGSkinPrettifyType.h" 
// Tips: 本引擎依赖 libz， AVFoundation.framework 以及 CoreMedia.framework

// 用于实时预览美肤的 View , 继承至 UIView

extern NSString const *kSDK_PG_Version;  ///< sdk版本，问题反馈、key更新请提供此版本号

@class PGOglView;

// 美肤结果输出委托，当美肤完成时，引擎会回调此委托，传入美肤结果
@protocol PGSkinPrettifyDelegate <NSObject>

- (void) PGSkinPrettifyResultOutput:(CVPixelBufferRef)pixelBuffer;

@end

@interface PGSkinPrettifyEngine : NSObject

/**
 描述：获取sdk版本
 */
+ (NSString*)getSDKVersion;

/*
 描述：初始化引擎
 返回值：成功返回 YES，失败或已经初始化过返回 NO
 参数：pKey - 许可密钥
 */
- (BOOL) InitEngineWithKey:(NSString*) pKey;

/*
 描述：根据所设置的参数，运行引擎
 返回值：成功返回 YES, 失败返回 NO
 参数：无
 */
- (BOOL) RunEngine;

/*
 描述：暂停引擎运行，调用后所有接口调用均被忽略，避免 App 切换至后台时产生新的 drawcall 而引起崩溃
 返回值：无
 参数：无
 */
- (void) PauseEngine;

/*
 描述：恢复引擎的运行
 返回值：无
 参数：无
 */
- (void) ResumeEngine;

/*
 描述：销毁引擎
 返回值：无
 参数：无
 */
- (void) DestroyEngine;

/*
 描述：设置输入帧，纯美颜、滤镜推荐调用此接口
 返回值：无
 参数：pInputPixel - 相机回调所给的预览帧，支持 kCVPixelFormatType_32BGRA 与 kCVPixelFormatType_420YpCbCr8BiPlanarFullRange 两种格式的输入
 */
- (void) SetInputFrameByCVImage:(CVPixelBufferRef)pInputPixel;

/*
 描述：设置输入帧，带贴纸功能和大眼瘦脸功能必须使用此接口，此接口是在接口 SetInputFrameByCVImage 功能之上增加贴纸和大眼瘦脸功能
 返回值：无
 参数：pInputPixel - 相机回调所给的预览帧，支持 kCVPixelFormatType_32BGRA 与 kCVPixelFormatType_420YpCbCr8BiPlanarFullRange 两种格式的输入
 */
- (void) SetInputFrameByCVSampleImage:(CMSampleBufferRef)pInputPixel;

/*
 描述：设置一个方向，用于校正输入的预览帧
 返回值：无
 参数：eAdjustInputOrient - 方向值
 */
- (void) SetOrientForAdjustInput:(PGOrientation)eAdjustInputOrient;

/*
 描述：设置一个矩阵用于调整输入帧，使用此方法意味着将输入的预处理变换操作交由调用者控制，调用此方法后会影响 SetOrientForAdjustInput 产生的设置
 返回值：无
 参数：pMatrix - MVP矩阵
 */
- (void) SetMatrixForAdjustInput:(float *)pMatrix;

/*
 描述：设置一个尺寸，用于调整输入帧的宽高，也是最终输出帧的宽高
 返回值：无
 参数：sSize - 宽和高
 */
- (void) SetSizeForAdjustInput:(CGSize)sSize;

/*
 描述：设置美肤步骤中磨皮的强度
 返回值：无
 参数：iSoftenStrength - 磨皮强度，范围 0 - 100
 */
- (void) SetSkinSoftenStrength:(int)iSoftenStrength;

/*
 描述：设置美肤算法
 返回值：无
 参数：eSoftenAlgorithm - 美肤算法类型
 */
- (void) SetSkinSoftenAlgorithm:(PGSoftenAlgorithm)eSoftenAlgorithm;

/*
 描述：设置调色滤镜
 返回值：无
 参数：pName - 滤镜名称
 */
- (void) SetColorFilterByName:(NSString *)pName;

/*
 描述：设置调色滤镜强度
 返回值：无
 参数：iStrength - 调色滤镜强度，范围 0 - 100
 */
- (void) SetColorFilterStrength:(int)iStrength;

/*
 描述：设置对比度调节参数
 返回值：无
 参数：iStrength - 调节对比度，范围 -100 - +100
 */
- (void) SetAdjustContrastStrength:(int)iStrength;

/*
 描述：移除当前滤镜
 返回值：无
 */
- (void) RemoveFilter;

/*
 描述：设置美肤步骤中的肤色调整参数
 返回值：无
 参数：fPinking - 粉嫩程度， fWhitening - 白晰程度，fRedden - 红润程度，范围都是0.0 - 1.0
 */
- (void) SetSkinColor:(float)fPinking Whitening:(float)fWhitening Redden:(float)fRedden;

/*
 描述：设置美肤结果的输出方向
 返回值：无
 参数：eOutputOrientation - 方向值
 */
- (void) SetOutputOrientation:(PGOrientation)eOutputOrientation;

/*
 描述：设置一个矩阵用于调节输出，使用此方法意味着将输出的变换操作交由调用者控制，调用此方法后会影响 SetOutputOrientation 产生的设置
 返回值：无
 参数：pMatrix - MVP 矩阵
 */
- (void) SetMatrixForAdjustOutput:(float *)pMatrix;

/*
 描述：设置美肤结果的输出格式
 返回值：无
 参数：eOutFormat - 输出的色彩格式
 */
- (void) SetOutputFormat:(PGPixelFormat)eOutFormat;

/*
 描述：设置美肤结果的输出回调
 返回值：无
 参数：outputCallback - 委托
 */
- (void) SetSkinPrettifyResultDelegate:(id <PGSkinPrettifyDelegate>)outputCallback;

/*
 描述：从路径设置水印图像，支持 jpeg 和 png，注意，如果将png打包到app中时，在xcode中开启了png压缩和去除metadata，会导致libpng解码出错
 返回值：成功返回 YES，失败返回 NO
 参数：pImagePath - 图像路径，iMode - 水印混合模式
 */
- (BOOL) SetWatermarkByPath:(NSString *)pImagePath Blend:(PGBlendMode)iMode;

/*
 描述：设置水印
 返回值：成功返回 YES，失败返回 NO
 参数：pImage - UIImage对象，iMode - 水印混合模式
 */
- (BOOL) SetWatermarkByImage:(UIImage *)pImage Blend:(PGBlendMode)iMode;

/*
 描述：设置水印的位置及翻转和镜像参数，坐标系是左下角为原点，横向为x轴，纵向为y轴，范围均为 0 - 1
 返回值：成功返回 YES，失败返回 NO
 参数：fLeft, fTop - 左上角坐标， fWidth, fHeight - 宽和高， fFlipped, fMirrored - 上下翻转和左右镜像
 */
- (BOOL) SetParamForAdjustWatermark:(float)fLeft Top:(float)fTop Width:(float)fWidth Height:(float)fHeight Flipped:(float)fFlipped Mirrored:(float)fMirrored;

/*
 描述：设置水印不透明度
 返回值：无
 参数：iBlendStrength - 水印不透明度，范围 0 - 100
 */
- (void) SetWatermarkStrength:(int)iBlendStrength;

/*
 描述：主动获取美肤结果
 返回值：无
 参数：pResultBuffer - 指向 CVPixelBufferRef 的指针
 */
- (void) GetSkinPrettifyResult:(CVPixelBufferRef *)pResultBuffer;

/*
 描述：获取输出纹理的 ID
 返回值：输出纹理的 ID
 参数：无
 */
- (int) GetOutputTextureID;

/*
 描述：获取美肤 SDK 内部的 EAGLContext
 返回值：美肤 SDK 内部的 EAGLContext
 参数：无
 */
- (EAGLContext *) GetInternalEAGLContext;

/*
 描述：创建一个预览美肤效果的 View ,返回的 View 会在 DestroyEngine 时销毁，不需要外部销毁
 返回值：所创建的 PGOglView 指针
 参数：View 的尺寸
 */
- (PGOglView *) PGOglViewCreateWithFrame:(CGRect)sFrame;

/*
 描述：将美肤结果刷新到 PGOglView
 返回值：成功返回 YES，引擎未初始化，或 View 未成功创建返回 NO
 参数：无
 */
- (BOOL) PGOglViewPresent;

/*
 描述：设置一个矩阵用于控制显示画面的变换
 返回值：成功返回 YES
 参数：pMatrix - MVP矩阵
 */
- (BOOL) PGOglViewSetMVPMatrix:(float *)pMatrix;

/*
 描述：将美肤结果缓冲区显示到 PGOglView
 返回值：成功返回 YES，引擎未初始化，或 View 未成功创建返回 NO
 参数：无
 */
- (BOOL) PGOglViewRenderResult;

/*
 描述：将显示内容左右镜像
 返回值：无
 参数：bMirrored - 为YES时显示内容会左右镜像
 */
- (void) PGOglViewMirrored:(BOOL)bMirrored;

/*
 描述：外部更改了 PGOglView 的 Size 后通过调用此方法通知引擎更新 PGOglView 相关的组件
 返回值：无
 参数：无
 */
- (void) PGOglViewSizeChanged;

/*
 描述：设置贴纸文件夹包路径（解压后），解析贴纸成功之后，贴纸开关会自动打开
 返回值：无
 参数：path:包路径
 */
- (void) SetStickerPackagePath:(NSString *)path;

/*
 描述：关闭贴纸功能，关闭之后会清除屏幕上所有贴纸，直到再次设置
 返回值：无
 参数：YES:打开 NO:关闭
 */
- (void) StickerEnable:(BOOL)enable;

/*
 描述：打开和关闭大眼瘦脸功能
 返回值：无
 参数：YES:打开 NO:关闭
 */
- (void) FaceShapingEnable:(BOOL)enable;

/*
 描述：设置大眼及瘦脸功能的强度
 返回值：无
 参数：iBigEyeStrength - 大眼强度，iThinFaceStrength - 瘦脸强度，范围 0 - 100
 */
- (void) SetFaceShapingParam:(int)iBigEyeStrength ThinFace:(int)iThinFaceStrength;

/*
 描述：给人脸模型指定文件夹路径,需要在初始化引擎之后指定模型文件路径（如果需要进行人脸识别相关操作,一定要设置）
 返回值：无
 参数：path:模型文件路径，可为nil，默认mainBundle文件路径
 */
- (void) SetFaceModelPath:(NSString *)path;

/*
 描述：SDK日志输出，请在测试阶段打开它。
 返回值：无。
 参数：YES:打开 NO:关闭，默认为打开。
 */
- (void) SDKLogEnable:(BOOL)enable;


#pragma mark - added by bob 2019-01-26

/**
 @brief
 设置直接处理美化图片的路径
 @note
 请注意区分本地图片类型
 设置前请先初始化引擎并配置相关美化参数
 @param sourcePath 图片路径
 @param scale 缩放倍数
 @return 设置结果
 */
- (BOOL)setInputImageByJpegPath:(NSString*)sourcePath scale:(NSUInteger)scale;

/**
 @brief
 设置直接处理美化图片二进制数据
 @note
 请注意区分本地图片类型
 设置前请先初始化引擎并配置相关美化参数
 @param image Jpeg图片
 @param scale 缩放倍数
 @return 设置结果
 */
- (BOOL)setInputImageByJpegImage:(UIImage*)image scale:(NSUInteger)scale;

/**
 @brief
 设置直接处理美化图片的路径
 @note
 请注意区分本地图片类型
 设置前请先初始化引擎并配置相关美化参数
 @param sourcePath 图片路径
 @return 设置结果
 */
- (BOOL)setInputImageByPngPath:(NSString*)sourcePath;

/**
 @brief
 获取美化结果图片数据到指定JPG文件
 @note
 请与setInputImageByJpegPath或者setInputImageByJpegBuffer配套使用
 @param resultPath 结果保存文件路径
 @param quality 图像质量 1~100
 @return 处理结果
 */
- (BOOL)getOutputImageToJpeg:(NSString*)resultPath quality:(NSUInteger)quality;

/**
 @brief
 获取美化结果图片数据到指定PNG文件
 @note
 请与setInputImageByPngPath配套使用
 @param resultPath 结果保存文件路径
 @param withAlpha 是否保持透明度
 @return 处理结果
 */
- (BOOL)getOutputImageToPng:(NSString*)resultPath withAlpha:(BOOL)withAlpha;

/**
 @date
 2019-03-05
 @author
 Bob
 @brief
 是否检测到人脸
 @note
 1.必须配置模型文件
 - (void)SetStickerPackagePath:(NSString *)path
 
 2.必须设置 enable = YES
 - (void)StickerEnable:(BOOL)enable
 or
 - (void) FaceShapingEnable:(BOOL)enable
 仅对调用时刻处理的这一帧图像有效
 @return YES = 已检测到人脸 NO = 未检测到人脸
 */
- (BOOL)isFaceDetected;

/**
 @brief
 UIImage to CVPixelBufferRef (BGRA)
 @note
 格式一定要与Engine一致(SetOutputFormat:PGPixelFormatBGRA)
 @param image 图像
 @param size size必须与engine设置的SetSizeForAdjustInput一致
 @return CVPixelBufferRef
 */
+ (CVPixelBufferRef)convertCGImageToCVPixelBufferRef:(UIImage*)image size:(CGSize)size;

/**
 @brief
 bob 2018-08-09
 直接通过内存拷贝将GPU处理后的位图内容拷贝到输出位图上
 @note
 1.输出处理过程不建议修改图像大小，否则可能拷贝过程导致丢失或者图像混合问题
 2.采用了某些直播sdk采集后，直播sdk没有提供将结果回传的接口时，采用此方法处理
 3.此方法与直播sdk回传方法必须在同一个线程处理
 @param result 美颜结果数据
 @param pixelBuffer 原始采集到的数据或者三方sdk回调的数据
 */
+ (void)replacePixelWithResult:(CVPixelBufferRef)result origin:(CVPixelBufferRef)pixelBuffer;

/**
 @brief
 bob 2018-08-01
 将CVPixelBufferRef转换为CMSampleBufferRef
 @note
 只有通过三方采集到的数据是CVPixelBufferRef时才需要调用，比如七牛直播
 只有需要大眼瘦脸，贴纸功能才可能需要调用此方法转换
 @param pixel 三方采集得到的图像数据
 @return CMSampleBufferRef
 */
+ (CMSampleBufferRef)convertPixelToSampleBufferRef:(CVPixelBufferRef)pixel;

@end


