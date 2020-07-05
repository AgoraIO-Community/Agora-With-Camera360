package com.pinguo.newSkinprettify;

import android.app.Application;

import io.agora.capture.video.camera.CameraVideoManager;
import io.agora.capture.video.camera.VideoModule;
import com.pinguo.newSkinprettify.framework.Camera360Preprocessor;
import io.agora.rtc.Constants;
import io.agora.rtc.RtcEngine;

public class AgoraApplication extends Application {
    private RtcEngine mRtcEngine;
    private AgoraRtcEventHandlerImpl mAgoraRtcEventHandlerImpl;

    private CameraVideoManager mCameraVideoManager;

    @Override
    public void onCreate() {
        super.onCreate();
        createRtcEngine();
        initCameraManagerAsync();
    }

    private void createRtcEngine() {
        mAgoraRtcEventHandlerImpl = new AgoraRtcEventHandlerImpl();
        try {
            mRtcEngine = RtcEngine.create(this, getString(R.string.APP_ID), mAgoraRtcEventHandlerImpl);
            mRtcEngine.setChannelProfile(Constants.CHANNEL_PROFILE_LIVE_BROADCASTING);
            mRtcEngine.enableVideo();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void initCameraManagerAsync() {
        new Thread(() -> {
            Camera360Preprocessor preprocessor = new Camera360Preprocessor(this);
            mCameraVideoManager = new CameraVideoManager(this, preprocessor);
        }).start();
    }

    public RtcEngine rtcEngine() {
        return mRtcEngine;
    }

    public AgoraRtcEventHandlerImpl eventHandler() {
        return mAgoraRtcEventHandlerImpl;
    }

    public void registerHandler(EventHandler handler) {
        mAgoraRtcEventHandlerImpl.registerHandler(handler);
    }

    public void removeHandler(EventHandler handler) {
        mAgoraRtcEventHandlerImpl.removeHandler(handler);
    }

    public CameraVideoManager cameraVideoManager() {
        return mCameraVideoManager;
    }

    @Override
    public void onTerminate() {
        super.onTerminate();
        destroyCameraCapture();
    }

    private void destroyCameraCapture() {
        VideoModule.instance().stopAllChannels();
    }
}
