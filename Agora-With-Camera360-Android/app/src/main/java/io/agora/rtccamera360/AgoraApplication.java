package io.agora.rtccamera360;

import android.app.Application;

import io.agora.capture.video.camera.CameraVideoManager;
import io.agora.capture.video.camera.VideoModule;
import io.agora.framework.Camera360Preprocessor;
import io.agora.rtc.Constants;
import io.agora.rtc.RtcEngine;

public class AgoraApplication extends Application {
    private RtcEngine mRtcEngine;
    private AgoraRtcEventHandler mAgoraRtcEventHandler;

    private CameraVideoManager mCameraVideoManager;

    @Override
    public void onCreate() {
        super.onCreate();
        createRtcEngine();
        initCameraManagerAsync();
    }

    private void createRtcEngine() {
        mAgoraRtcEventHandler = new AgoraRtcEventHandler();
        try {
            mRtcEngine = RtcEngine.create(this, getString(R.string.APP_ID), mAgoraRtcEventHandler);
            mRtcEngine.setChannelProfile(Constants.CHANNEL_PROFILE_LIVE_BROADCASTING);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void initCameraManagerAsync() {
        new Thread(() -> {
            Camera360Preprocessor preprocessor = new Camera360Preprocessor();
            mCameraVideoManager = new CameraVideoManager(this, preprocessor);
        }).start();
    }

    public RtcEngine rtcEngine() {
        return mRtcEngine;
    }

    public AgoraRtcEventHandler eventHandler() {
        return mAgoraRtcEventHandler;
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
