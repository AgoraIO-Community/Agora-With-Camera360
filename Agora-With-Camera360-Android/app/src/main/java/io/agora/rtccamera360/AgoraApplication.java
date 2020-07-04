package io.agora.rtccamera360;

import android.app.Application;

import io.agora.rtc.Constants;
import io.agora.rtc.RtcEngine;

public class AgoraApplication extends Application {
    private RtcEngine mRtcEngine;
    private AgoraRtcEventHandler mAgoraRtcEventHandler;

    @Override
    public void onCreate() {
        super.onCreate();
        createRtcEngine();

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

    public RtcEngine rtcEngine() {
        return mRtcEngine;
    }

    public AgoraRtcEventHandler eventHandler() {
        return mAgoraRtcEventHandler;
    }

    @Override
    public void onTerminate() {
        super.onTerminate();
    }
}
