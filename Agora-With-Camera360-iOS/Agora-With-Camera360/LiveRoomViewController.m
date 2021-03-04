//
//  LiveRoomViewController.m
//  OpenLive
//
//  Created by GongYuhua on 2016/9/12.
//  Copyright © 2016年 Agora. All rights reserved.
//

#import "LiveRoomViewController.h"
#import "VideoSession.h"
#import "VideoViewLayouter.h"
#import "BeautyEffectTableViewController.h"
#import "KeyCenter.h"
#import <AGMBase/AGMBase.h>
#import <AGMCapturer/AGMCapturer.h>
#import "PGSkinPrettifyEngine.h"

//替换自己的key
#define DEMOKEY @"<#Your Camera360 Key#>"


@interface LiveRoomViewController () <AgoraRtcEngineDelegate, BeautyEffectTableVCDelegate, UIPopoverPresentationControllerDelegate, AgoraVideoSourceProtocol, PGSkinPrettifyDelegate>
@property (weak, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (weak, nonatomic) IBOutlet UIView *remoteContainerView;
@property (weak, nonatomic) IBOutlet UIButton *broadcastButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *sessionButtons;
@property (weak, nonatomic) IBOutlet UIButton *audioMuteButton;
@property (weak, nonatomic) IBOutlet UIButton *beautyEffectButton;
@property (weak, nonatomic) IBOutlet UIButton *superResolutionButton;

@property (assign, nonatomic) BOOL isBroadcaster;
@property (assign, nonatomic) BOOL isMuted;
@property (assign, nonatomic) BOOL shouldEnhancer;
@property (strong, nonatomic) NSMutableArray<VideoSession *> *videoSessions;
@property (strong, nonatomic) VideoSession *fullSession;
@property (strong, nonatomic) VideoViewLayouter *viewLayouter;
@property (assign, nonatomic) BOOL isEnableSuperResolution;
@property (assign, nonatomic) NSUInteger highPriorityRemoteUid;
@property (assign, nonatomic) BOOL isBeautyOn;
@property (assign, nonatomic) BOOL m_bIsFirstFrame;
@property (assign, nonatomic) CGSize m_sFrameSize;
@property (strong, nonatomic) AgoraBeautyOptions *beautyOptions;
@property (assign, nonatomic) CGFloat faceLighten;
@property (assign, nonatomic) CGFloat faceShaping;
@property (assign, nonatomic) CGFloat faceThining;
@property (assign, nonatomic) CGFloat faceSmooth;
@property (assign, nonatomic) CVPixelBufferRef previousPixelBuffer;
#pragma Capturer
@property (nonatomic, strong) AGMCameraCapturer *cameraCapturer;
@property (nonatomic, strong) AGMCapturerVideoConfig *videoConfig;
@property (nonatomic, strong) AGMVideoAdapterFilter *videoAdapterFilter;

@property (nonatomic, strong) PGSkinPrettifyEngine *pPGSkinPrettifyEngine;
@property (nonatomic, assign) BOOL isFirstFrame;
@end

@implementation LiveRoomViewController

@synthesize consumer;

- (BOOL)isBroadcaster {
    return self.clientRole == AgoraClientRoleBroadcaster;
}

- (VideoViewLayouter *)viewLayouter {
    if (!_viewLayouter) {
        _viewLayouter = [[VideoViewLayouter alloc] init];
    }
    return _viewLayouter;
}

- (void)setClientRole:(AgoraClientRole)clientRole {
    _clientRole = clientRole;
    
    if (self.isBroadcaster) {
        self.shouldEnhancer = YES;
    }
    [self updateButtonsVisiablity];
}

- (void)setIsMuted:(BOOL)isMuted {
    _isMuted = isMuted;
    [self.rtcEngine muteLocalAudioStream:isMuted];
    [self.audioMuteButton setImage:[UIImage imageNamed:(isMuted ? @"btn_mute_cancel" : @"btn_mute")] forState:UIControlStateNormal];
}

- (void)setVideoSessions:(NSMutableArray<VideoSession *> *)videoSessions {
    _videoSessions = videoSessions;
    if (self.remoteContainerView) {
        [self updateInterfaceWithAnimation:YES];
    }
}

- (void)setFullSession:(VideoSession *)fullSession {
    _fullSession = fullSession;
    if (self.remoteContainerView) {
        [self updateInterfaceWithAnimation:YES];
    }
}

- (void)setIsEnableSuperResolution:(BOOL)isEnableSuperResolution {
    _isEnableSuperResolution = isEnableSuperResolution;
    [self.superResolutionButton setImage:[UIImage imageNamed:_isEnableSuperResolution ? @"btn_sr_blue" : @"btn_sr"] forState:UIControlStateNormal];
}

- (void)setHighPriorityRemoteUid:(NSUInteger)highPriorityRemoteUid {
    _highPriorityRemoteUid = highPriorityRemoteUid;
    for (VideoSession *session in self.videoSessions) {
        [self.rtcEngine enableRemoteSuperResolution:session.uid enabled:NO];
        [self.rtcEngine setRemoteUserPriority:session.uid type:AgoraUserPriorityNormal];
    }
    if (highPriorityRemoteUid != 0) {
        if (self.isEnableSuperResolution) {
            [self.rtcEngine enableRemoteSuperResolution:highPriorityRemoteUid enabled:YES];
        }
        [self.rtcEngine setRemoteUserPriority:highPriorityRemoteUid type:AgoraUserPriorityHigh];
    }
}

- (void)setIsBeautyOn:(BOOL)isBeautyOn {
    _isBeautyOn = isBeautyOn;
    [self.beautyEffectButton setImage:[UIImage imageNamed:(isBeautyOn ? @"btn_beautiful_cancel" : @"btn_beautiful")] forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoSessions = [[NSMutableArray alloc] init];
    
    self.roomNameLabel.text = self.roomName;
    [self updateButtonsVisiablity];
    
    [self setupCamera360];
    [self initCapturer];
    [self loadAgoraKit];
    
    self.beautyOptions = [[AgoraBeautyOptions alloc] init];
    self.beautyOptions.lighteningContrastLevel = AgoraLighteningContrastNormal;
    self.beautyOptions.lighteningLevel = 0.7;
    self.beautyOptions.smoothnessLevel = 0.5;
    self.beautyOptions.rednessLevel = 0.1;
    
    self.isBeautyOn = YES;
    
    self.faceSmooth = 80;
    self.faceLighten = 0.6;
    self.faceShaping = 70;
    self.faceThining = 100;
    self.m_bIsFirstFrame = YES;
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"roomVCPopBeautyList"]) {
        BeautyEffectTableViewController *vc = segue.destinationViewController;
        vc.isBeautyOn = self.isBeautyOn;
        vc.smoothness = self.faceSmooth / 100;
        vc.lightening = self.faceLighten;
        vc.faceshaping = self.faceShaping / 100;
        vc.facethining = self.faceThining / 100;
        vc.delegate = self;
        vc.popoverPresentationController.delegate = self;
    }
}

- (IBAction)doSwitchCameraPressed:(UIButton *)sender {
    [self.cameraCapturer switchCamera];
}

- (IBAction)doMutePressed:(UIButton *)sender {
    self.isMuted = !self.isMuted;
}

- (IBAction)doBroadcastPressed:(UIButton *)sender {
    if (self.isBroadcaster) {
        self.clientRole = AgoraClientRoleAudience;
        if (self.fullSession.uid == 0) {
            self.fullSession = nil;
        }
    } else {
        self.clientRole = AgoraClientRoleBroadcaster;
    }
    
    [self.rtcEngine setClientRole:self.clientRole];
    [self updateInterfaceWithAnimation:YES];
}

- (IBAction)doSuperResolutionPressed:(UIButton *)sender {
    self.isEnableSuperResolution = !self.isEnableSuperResolution;
    self.highPriorityRemoteUid = [self highPriorityRemoteUidInSessions:self.videoSessions fullSession:self.fullSession];
}

- (IBAction)doDoubleTapped:(UITapGestureRecognizer *)sender {
    if (!self.fullSession) {
        VideoSession *tappedSession = [self.viewLayouter responseSessionOfGesture:sender inSessions:self.videoSessions inContainerView:self.remoteContainerView];
        if (tappedSession) {
            self.fullSession = tappedSession;
        }
    } else {
        self.fullSession = nil;
    }
}

- (IBAction)doLeavePressed:(UIButton *)sender {
    [self leaveChannel];
}

- (void)updateButtonsVisiablity {
    [self.broadcastButton setImage:[UIImage imageNamed:self.isBroadcaster ? @"btn_join_cancel" : @"btn_join"] forState:UIControlStateNormal];
    for (UIButton *button in self.sessionButtons) {
        button.hidden = !self.isBroadcaster;
    }
}

- (void)leaveChannel {
    [self setIdleTimerActive:YES];
    
    [self.rtcEngine setupLocalVideo:nil];
    [self.rtcEngine leaveChannel:nil];
    if (self.isBroadcaster) {
        [self.rtcEngine stopPreview];
    }
    
    for (VideoSession *session in self.videoSessions) {
        [session.hostingView removeFromSuperview];
    }
    [self.videoSessions removeAllObjects];
    
    if ([self.delegate respondsToSelector:@selector(liveVCNeedClose:)]) {
        [self.delegate liveVCNeedClose:self];
    }
}

- (void)setIdleTimerActive:(BOOL)active {
    [UIApplication sharedApplication].idleTimerDisabled = !active;
}

- (void)alertString:(NSString *)string {
    if (!string.length) {
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:string preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateInterfaceWithAnimation:(BOOL)animation {
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            [self updateInterface];
            [self.view layoutIfNeeded];
        }];
    } else {
        [self updateInterface];
    }
}

- (void)updateInterface {
    NSArray *displaySessions;
    if (!self.isBroadcaster && self.videoSessions.count) {
        displaySessions = [self.videoSessions subarrayWithRange:NSMakeRange(1, self.videoSessions.count - 1)];
    } else {
        displaySessions = [self.videoSessions copy];
    }
    
    [self.viewLayouter layoutSessions:displaySessions fullSession:self.fullSession inContainer:self.remoteContainerView];
    [self setStreamTypeForSessions:displaySessions fullSession:self.fullSession];
    self.highPriorityRemoteUid = [self highPriorityRemoteUidInSessions:displaySessions fullSession:self.fullSession];
}

- (void)setStreamTypeForSessions:(NSArray<VideoSession *> *)sessions fullSession:(VideoSession *)fullSession {
    if (fullSession) {
        for (VideoSession *session in sessions) {
            if (session == self.fullSession) {
                [self.rtcEngine setRemoteVideoStream:fullSession.uid type:AgoraVideoStreamTypeHigh];
            } else {
                [self.rtcEngine setRemoteVideoStream:session.uid type:AgoraVideoStreamTypeLow];
            }
        }
    } else {
        for (VideoSession *session in sessions) {
            [self.rtcEngine setRemoteVideoStream:session.uid type:AgoraVideoStreamTypeHigh];
        }
    }
}

- (void)addLocalSession {
    VideoSession *localSession = [VideoSession localSession];
    [self.videoSessions addObject:localSession];
    [self.rtcEngine setupLocalVideo:localSession.canvas];

    [self updateInterfaceWithAnimation:YES];
}

- (VideoSession *)fetchSessionOfUid:(NSUInteger)uid {
    for (VideoSession *session in self.videoSessions) {
        if (session.uid == uid) {
            return session;
        }
    }
    return nil;
}

- (VideoSession *)videoSessionOfUid:(NSUInteger)uid {
    VideoSession *fetchedSession = [self fetchSessionOfUid:uid];
    if (fetchedSession) {
        return fetchedSession;
    } else {
        VideoSession *newSession = [[VideoSession alloc] initWithUid:uid];
        [self.videoSessions addObject:newSession];
        [self updateInterfaceWithAnimation:YES];
        return newSession;
    }
}

- (NSUInteger)highPriorityRemoteUidInSessions:(NSArray<VideoSession *> *)sessions fullSession:(VideoSession *)fullSession {
    if (fullSession) {
        return fullSession.uid;
    } else {
        return sessions.lastObject.uid;
    }
}

//MARK: Capturer
- (void)initCapturer {
    self.videoConfig = [AGMCapturerVideoConfig defaultConfig];
    self.videoConfig.sessionPreset = AVCaptureSessionPreset1920x1080;
    self.videoConfig.fps = 10;
    self.cameraCapturer = [[AGMCameraCapturer alloc] initWithConfig:self.videoConfig];
    
    // Filter
    self.videoAdapterFilter = [[AGMVideoAdapterFilter alloc] init];
    self.videoAdapterFilter.ignoreAspectRatio = YES;

    __weak typeof(self) weakSelf = self;
    [self.cameraCapturer addVideoSink:self.videoAdapterFilter];
    [self.videoAdapterFilter setFrameProcessingCompletionBlock:^(AGMVideoSource * _Nonnull videoSource, CMTime time) {
        CVPixelBufferRef pixelBuffer = videoSource.framebufferForOutput.pixelBuffer;
        // 根据第一帧适配界面
        if(self.m_bIsFirstFrame){
            self.m_sFrameSize = CVImageBufferGetDisplaySize(pixelBuffer);
            [self configFirstBuffer];
        }
        [weakSelf highMachineRender:pixelBuffer];
    }];
}

- (void)configFirstBuffer {
    //----------此代码很关键，为配置引擎-------------
    // 在第一帧视频到来时，初始化美肤引擎，指定需要的输出大小和输出格式
    CGSize sizeForAdjustInput = CGSizeMake(self.m_sFrameSize.width, self.m_sFrameSize.height);
    //第一帧大小调整
    [_pPGSkinPrettifyEngine SetSizeForAdjustInput:sizeForAdjustInput];
    //第一帧方向校准
    [_pPGSkinPrettifyEngine SetOrientForAdjustInput: PGOrientationNormal];
    //输出格式，此处一定注意输出格式要与opengl绘制中的格式一致（直播接收端处理注意了）
    [_pPGSkinPrettifyEngine SetOutputFormat:PGPixelFormatYUV420];
    //输出方向
    [_pPGSkinPrettifyEngine SetOutputOrientation:PGOrientationMirrored];
    //美肤强度设置
    [_pPGSkinPrettifyEngine SetSkinSoftenStrength:80];
    //红润、粉嫩、白皙效果设置
    [_pPGSkinPrettifyEngine SetSkinColor:0.6 Whitening:0.6 Redden:0.6];
    [_pPGSkinPrettifyEngine FaceShapingEnable:YES];
    
    self.m_bIsFirstFrame = NO;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    #define DEGREES_TO_RADIANS(x) (x * M_PI/180.0)
    CGAffineTransform rotation = CGAffineTransformMakeRotation( DEGREES_TO_RADIANS(90));
    switch (orientation) {
        case UIInterfaceOrientationPortrait:
            rotation = CGAffineTransformMakeRotation( DEGREES_TO_RADIANS(90));
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            break;
        case UIInterfaceOrientationLandscapeLeft:
            rotation = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
            break;
        case UIInterfaceOrientationLandscapeRight:
            rotation = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
            break;

        default:
            break;
    }
    self.videoAdapterFilter.affineTransform = rotation;

}


//MARK: - Camera360
- (void)setupCamera360 {
    //***接入核心代码***
    // ---------初始化引擎实例-----------
    _pPGSkinPrettifyEngine = [[PGSkinPrettifyEngine alloc] init];
    [_pPGSkinPrettifyEngine InitEngineWithKey:DEMOKEY];
    [_pPGSkinPrettifyEngine SetSkinPrettifyResultDelegate:self];
    // ----------设置磨皮算法，请使用 细节保留磨皮:PGSoftenAlgorithmContrast--------
    [_pPGSkinPrettifyEngine SetSkinSoftenAlgorithm:PGSoftenAlgorithmContrast];
    
    [_pPGSkinPrettifyEngine SetOutputOrientation:PGOrientationNormal];
    [_pPGSkinPrettifyEngine SetSizeForAdjustInput:CGSizeMake(1080, 1920)];
    [_pPGSkinPrettifyEngine SetOrientForAdjustInput:PGOrientationNormal];
    [_pPGSkinPrettifyEngine SetOutputFormat:PGPixelFormatYUV420];
    
    /*--------------------增加贴纸-----------------*/
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"megvii_facepp_model" ofType:nil];
    if(modelPath && [[NSFileManager defaultManager] fileExistsAtPath:modelPath]){
        [_pPGSkinPrettifyEngine SetFaceModelPath:modelPath];
    }
    [_pPGSkinPrettifyEngine FaceShapingEnable:YES];
    NSLog(@"Prettify SDK Version:%@", [PGSkinPrettifyEngine getSDKVersion]);

}

//把pixelBuffer包装成samplebuffer送给displayLayer
- (CMSampleBufferRef)dispatchPixelBuffer:(CVPixelBufferRef) pixelBuffer
{
    if (!pixelBuffer){
        return NULL;
    }
    @synchronized(self) {
    if (self.previousPixelBuffer){
//        CFRelease(self.previousPixelBuffer);
        self.previousPixelBuffer = nil;
    }
    self.previousPixelBuffer = CFRetain(pixelBuffer);
    }

    //不设置具体时间信息
    CMSampleTimingInfo timing = {kCMTimeInvalid, kCMTimeInvalid, kCMTimeInvalid};
    //获取视频信息
    CMVideoFormatDescriptionRef videoInfo = NULL;
    OSStatus result = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    NSParameterAssert(result == 0 && videoInfo != NULL);

    CMSampleBufferRef sampleBuffer = NULL;
    result = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
    NSParameterAssert(result == 0 && sampleBuffer != NULL);
    CFRelease(pixelBuffer);
    CFRelease(videoInfo);
    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
    CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
    CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
//    [self enqueueSampleBuffer:sampleBuffer toLayer:self.sampleBufferDisplayLayer];
//    CFRelease(sampleBuffer);
    return sampleBuffer;
}

- (CMSampleBufferRef)getCMSampleBufferFromPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    if (!pixelBuffer){
        return NULL;
    }
    CMSampleTimingInfo timing = {kCMTimeInvalid, kCMTimeInvalid, kCMTimeInvalid};
    CMVideoFormatDescriptionRef videoInfo = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(NULL, self.previousPixelBuffer, &videoInfo);
    CMSampleBufferRef sampleBuffer = NULL;
    CMSampleBufferCreateReadyWithImageBuffer(kCFAllocatorDefault, pixelBuffer, videoInfo, &timing, &sampleBuffer);
    return sampleBuffer;
}

///< 高端机型直接使用下面方法即可（iphone5s及其以上）同步处理 _skinStrength
- (void)highMachineRender:(CVPixelBufferRef)pixelBuffer {
    //设置输入帧（imageBuffer为CVPixelBufferRef类型）
//    [_pPGSkinPrettifyEngine SetInputFrameByCVImage:pixelBuffer];
    CMSampleBufferRef bufferRef = [self dispatchPixelBuffer:pixelBuffer];
    [_pPGSkinPrettifyEngine SetInputFrameByCVSampleImage:bufferRef];
    if (self.isBeautyOn) {
        [_pPGSkinPrettifyEngine SetSkinSoftenStrength:self.faceSmooth];
        [_pPGSkinPrettifyEngine SetColorFilterStrength:self.faceSmooth];
        [_pPGSkinPrettifyEngine SetSkinColor:self.faceLighten Whitening:self.faceLighten Redden:self.faceLighten];
        [_pPGSkinPrettifyEngine SetFaceShapingParam:self.faceShaping ThinFace:self.faceThining];
    }
    else {
        [_pPGSkinPrettifyEngine SetSkinSoftenStrength:0];
        [_pPGSkinPrettifyEngine SetColorFilterStrength:0];
        [_pPGSkinPrettifyEngine SetSkinColor:0 Whitening:0 Redden:0];
        [_pPGSkinPrettifyEngine SetFaceShapingParam:0 ThinFace:0];
    }
    //启动引擎
    [_pPGSkinPrettifyEngine RunEngine];
    BOOL isFaceDetected = [_pPGSkinPrettifyEngine isFaceDetected];
    if(isFaceDetected) {
//        NSLog(@"检测到人脸");
    }
    CFRelease(bufferRef);
}


//MARK: - PGSkinPrettifyDelegate
/**
 @brief
 美颜SDK处理结果回调
 @note
 用户可以在此回调中走直播推流流程或进行数据转换
 demo提供了预览处理结果支持，用户一定要注意配置美颜engine的 SetOutputFormat:PGPixelFormatYUV420，与自己预览时数据解析格式要一致，比如输出YUV，展示时就要按照解析YUV内容render；
 AAPLEAGLLayer 内部就是采用解析buffer 的YUV信息进行render的；
 @param pixelBuffer 处理结果
 */
- (void)PGSkinPrettifyResultOutput:(CVPixelBufferRef)pixelBuffer {
    [self.consumer consumePixelBuffer:pixelBuffer withTimestamp:CMTimeMake(CACurrentMediaTime()*1000, 1000) rotation:AgoraVideoRotationNone];
}

//MARK: - Agora Media SDK
- (void)loadAgoraKit {
    self.rtcEngine.delegate = self;
    [self.rtcEngine setChannelProfile:AgoraChannelProfileLiveBroadcasting];
    
    // Warning: only enable dual stream mode if there will be more than one broadcaster in the channel
    [self.rtcEngine enableDualStreamMode:YES];
    [self.rtcEngine enableVideo];
    
    AgoraVideoEncoderConfiguration *configuration =
        [[AgoraVideoEncoderConfiguration alloc] initWithSize:CGSizeMake(1080, 1920)
                                                   frameRate:AgoraVideoFrameRateFps10
                                                     bitrate:AgoraVideoBitrateStandard
                                             orientationMode:AgoraVideoOutputOrientationModeFixedPortrait];
    [self.rtcEngine setVideoEncoderConfiguration:configuration];
    [self.rtcEngine setClientRole:self.clientRole];
    [self.rtcEngine setVideoSource:self];

    if (self.isBroadcaster) {
        [self.rtcEngine startPreview];
    }
    
    [self addLocalSession];
    
    
    int code = [self.rtcEngine joinChannelByToken:[KeyCenter Token] channelId:self.roomName info:nil uid:0 joinSuccess:nil];
    if (code == 0) {
        [self setIdleTimerActive:NO];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alertString:[NSString stringWithFormat:@"Join channel failed: %d", code]];
        });
    }
    

    if (self.isBroadcaster) {
        self.shouldEnhancer = YES;
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    VideoSession *userSession = [self videoSessionOfUid:uid];
    [self.rtcEngine setupRemoteVideo:userSession.canvas];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstLocalVideoFrameWithSize:(CGSize)size elapsed:(NSInteger)elapsed {
    if (self.videoSessions.count) {
        [self updateInterfaceWithAnimation:NO];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    VideoSession *deleteSession;
    for (VideoSession *session in self.videoSessions) {
        if (session.uid == uid) {
            deleteSession = session;
        }
    }
    
    if (deleteSession) {
        [self.videoSessions removeObject:deleteSession];
        [deleteSession.hostingView removeFromSuperview];
        [self updateInterfaceWithAnimation:YES];
        
        if (deleteSession == self.fullSession) {
            self.fullSession = nil;
        }
    }
}

#pragma mark - Agora Video Source Protocol
- (BOOL)shouldInitialize {
    return YES;
}

- (void)shouldStart {
    NSLog(@"shouldStart");
    [self.cameraCapturer start];
}

- (void)shouldStop {
    NSLog(@"shouldStop");
    [self.cameraCapturer stop];
}

- (void)shouldDispose {
    NSLog(@"shouldDispose");
//    [self.cameraCapturer dispose];
}

- (AgoraVideoBufferType)bufferType {
    return AgoraVideoBufferTypePixelBuffer;
}

- (AgoraVideoCaptureType)captureType {
    return AgoraVideoCaptureTypeCamera;
}


//MARK: - enhancer
- (void)beautyEffectTableVCDidChange:(BeautyEffectTableViewController *)enhancerTableVC {
    self.faceLighten = enhancerTableVC.lightening;
    self.faceShaping = enhancerTableVC.faceshaping * 100;
    self.faceThining = enhancerTableVC.facethining * 100;
    self.faceSmooth = enhancerTableVC.smoothness * 100;
    self.isBeautyOn = enhancerTableVC.isBeautyOn;
}

//MARK: - vc
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}



@end
