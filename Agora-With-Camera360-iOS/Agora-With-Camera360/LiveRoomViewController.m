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
#define DEMOKEY @"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"


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
@property (strong, nonatomic) AgoraBeautyOptions *beautyOptions;
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
    [self.rtcEngine setBeautyEffectOptions:isBeautyOn options:self.beautyOptions];
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
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"roomVCPopBeautyList"]) {
        BeautyEffectTableViewController *vc = segue.destinationViewController;
        vc.isBeautyOn = self.isBeautyOn;
        vc.smoothness = self.beautyOptions.smoothnessLevel;
        vc.lightening = self.beautyOptions.lighteningLevel;
        vc.contrast = self.beautyOptions.lighteningContrastLevel;
        vc.redness = self.beautyOptions.rednessLevel;
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
    self.videoConfig.videoSize = CGSizeMake(480, 640);
    self.videoConfig.sessionPreset = AGMCaptureSessionPreset480x640;
    self.videoConfig.fps = 15;
    self.cameraCapturer = [[AGMCameraCapturer alloc] initWithConfig:self.videoConfig];
    
    // Filter
    self.videoAdapterFilter = [[AGMVideoAdapterFilter alloc] init];
    self.videoAdapterFilter.ignoreAspectRatio = YES;

    __weak typeof(self) weakSelf = self;
    [self.cameraCapturer addVideoSink:self.videoAdapterFilter];
//        #define DEGREES_TO_RADIANS(x) (x * M_PI/180.0)
    // Device Orientation Portrait
//    CGAffineTransform rotation = CGAffineTransformMakeRotation( DEGREES_TO_RADIANS(90));
    // Device Orientation LandscapeLeft
//    CGAffineTransform rotation = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180));
    // Device Orientation LandscapeRight
//    CGAffineTransform rotation = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(0));
//    self.videoAdapterFilter.affineTransform = rotation;
    [self.videoAdapterFilter setFrameProcessingCompletionBlock:^(AGMVideoSource * _Nonnull videoSource, CMTime time) {
        CVPixelBufferRef pixelBuffer = videoSource.framebufferForOutput.pixelBuffer;
        [weakSelf highMachineRender:pixelBuffer];
    }];
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
    
    [_pPGSkinPrettifyEngine updateCaptureOrientation:AVCaptureVideoOrientationPortrait];
    [_pPGSkinPrettifyEngine SetSizeForAdjustInput:CGSizeMake(480, 640)];
    [_pPGSkinPrettifyEngine SetOrientForAdjustInput:PGOrientationNormal];
    [_pPGSkinPrettifyEngine SetOutputOrientation:PGOrientationNormal];
    [_pPGSkinPrettifyEngine SetOutputFormat:PGPixelFormatYUV420];
    

}

///< 高端机型直接使用下面方法即可（iphone5s及其以上）同步处理 _skinStrength
- (void)highMachineRender:(CVPixelBufferRef)pixelBuffer {
    //设置输入帧（imageBuffer为CVPixelBufferRef类型）
    [_pPGSkinPrettifyEngine SetInputFrameByCVImage:pixelBuffer];
    //美肤强度设置, demo 设置为 80
    [_pPGSkinPrettifyEngine SetSkinSoftenStrength:80];
    //红润、粉嫩、白皙效果设置，demo 设置为 60
//    [_pPGSkinPrettifyEngine SetSkinColor:60 Whitening:60 Redden:60];
    [_pPGSkinPrettifyEngine SetColorFilterStrength:80];
    //设置大眼瘦脸功能强度
//    if(self.hasFaceFunc)
//        [_pPGSkinPrettifyEngine SetFaceShapingParam:70 ThinFace:100];
    
    //启动引擎
    [_pPGSkinPrettifyEngine RunEngine];
    //渲染试图
//    [_pPGSkinPrettifyEngine PGOglViewPresent];
    
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
        [[AgoraVideoEncoderConfiguration alloc] initWithSize:self.videoProfile
                                                   frameRate:AgoraVideoFrameRateFps24
                                                     bitrate:AgoraVideoBitrateStandard
                                             orientationMode:AgoraVideoOutputOrientationModeAdaptative];
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


//MARK: - enhancer
- (void)beautyEffectTableVCDidChange:(BeautyEffectTableViewController *)enhancerTableVC {
    self.beautyOptions.lighteningLevel = enhancerTableVC.lightening;
    self.beautyOptions.smoothnessLevel = enhancerTableVC.smoothness;
    self.beautyOptions.lighteningContrastLevel = enhancerTableVC.contrast;
    self.beautyOptions.rednessLevel = enhancerTableVC.redness;
    self.isBeautyOn = enhancerTableVC.isBeautyOn;
}

//MARK: - vc
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection {
    return UIModalPresentationNone;
}



@end
