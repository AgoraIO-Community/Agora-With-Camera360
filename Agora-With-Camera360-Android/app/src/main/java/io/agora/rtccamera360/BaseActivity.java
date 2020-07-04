package io.agora.rtccamera360;

import androidx.appcompat.app.AppCompatActivity;

import io.agora.rtc.RtcEngine;

public abstract class BaseActivity extends AppCompatActivity {

    protected AgoraApplication application() {
        return (AgoraApplication) getApplication();
    }

    protected RtcEngine rtcEngine() {
        return application().rtcEngine();
    }

    protected AgoraRtcEventHandler eventHandler() {
        return application().eventHandler();
    }
}
