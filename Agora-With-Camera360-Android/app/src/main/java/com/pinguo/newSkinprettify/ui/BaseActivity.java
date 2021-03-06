package com.pinguo.newSkinprettify.ui;

import android.view.SurfaceView;

import androidx.appcompat.app.AppCompatActivity;

import com.pinguo.newSkinprettify.AgoraApplication;
import com.pinguo.newSkinprettify.AgoraRtcEventHandlerImpl;
import com.pinguo.newSkinprettify.EventHandler;

import io.agora.capture.video.camera.CameraVideoManager;
import io.agora.rtc.Constants;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.video.VideoCanvas;
import io.agora.rtc.video.VideoEncoderConfiguration;

public abstract class BaseActivity extends AppCompatActivity implements EventHandler {

  protected AgoraApplication application() {
    return (AgoraApplication) getApplication();
  }

  protected RtcEngine rtcEngine() {
    return application().rtcEngine();
  }

  protected AgoraRtcEventHandlerImpl eventHandler() {
    return application().eventHandler();
  }

  protected void registerHandler(EventHandler handler) {
    application().registerHandler(handler);
  }

  protected void removeHandler(EventHandler handler) {
    application().removeHandler(handler);
  }

  protected CameraVideoManager cameraVideoManager() {
    return application().cameraVideoManager();
  }

  protected void setRtcConfig() {
    rtcEngine().setClientRole(Constants.CLIENT_ROLE_BROADCASTER);
    rtcEngine().setVideoEncoderConfiguration(new VideoEncoderConfiguration(
        VideoEncoderConfiguration.VD_1280x720,
        VideoEncoderConfiguration.FRAME_RATE.FRAME_RATE_FPS_15,
        VideoEncoderConfiguration.STANDARD_BITRATE,
        VideoEncoderConfiguration.ORIENTATION_MODE.ORIENTATION_MODE_FIXED_PORTRAIT));
  }

  protected SurfaceView setupRemoteView(int uid) {
    SurfaceView surfaceView = RtcEngine.CreateRendererView(this);
    rtcEngine().setupRemoteVideo(new VideoCanvas(surfaceView,
        VideoCanvas.RENDER_MODE_HIDDEN, uid));
    return surfaceView;
  }
}
