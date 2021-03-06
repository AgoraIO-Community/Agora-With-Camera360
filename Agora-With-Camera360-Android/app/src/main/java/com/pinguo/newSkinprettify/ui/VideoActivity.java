package com.pinguo.newSkinprettify.ui;

import android.os.Bundle;
import android.util.Log;
import android.view.OrientationEventListener;
import android.view.SurfaceView;
import android.view.TextureView;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.TextView;
import com.pinguo.newSkinprettify.Const;
import com.pinguo.newSkinprettify.R;
import com.pinguo.newSkinprettify.framework.Camera360Preprocessor;
import com.pinguo.newSkinprettify.framework.RtcVideoConsumer;
import io.agora.capture.video.camera.CameraVideoManager;
import io.agora.capture.video.camera.Constant;
import io.agora.capture.video.camera.VideoCapture;
import io.agora.rtc.Constants;

public class VideoActivity extends BaseActivity implements
    OnSeekBarChangeListener {

  private static final String TAG = VideoActivity.class.getSimpleName();

  private static final int CAPTURE_WIDTH = 1280;
  private static final int CAPTURE_HEIGHT = 720;
  private static final int CAPTURE_FRAME_RATE = 24;

  private CameraVideoManager mCameraManager;
  private Camera360Preprocessor mPreprocessor;

  private TextureView mLocalPreview;
  private RelativeLayout mRemoteVideoLayout;
  private boolean mMuted = false;

  private int mRemoteUid = -1;
  private String mChannelName;

  private SeekBar seek_pink;
  private SeekBar seek_whiten;
  private SeekBar seek_redden;
  private SeekBar seek_soften;
  private SeekBar seek_bigeye;
  private SeekBar seek_thinface;

  private TextView pink_value;
  private TextView whiten_value;
  private TextView redden_value;
  private TextView soften_value;
  private TextView bigeye_value;
  private TextView thinface_value;

  private OrientationEventListener mOrientationListener;

  public void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.video_activity);

    initUI();
    initCamera();
    initRtc();
    registerOrientationEventListener();
  }

  private void registerOrientationEventListener() {
    if (mOrientationListener == null) {
      mOrientationListener = new OrientationEventListener(this) {

        @Override
        public void onOrientationChanged(int orientation) {
          mPreprocessor.onOrientationChanged(orientation);
        }
      };
    }
  }

  private void initUI() {
    mLocalPreview = findViewById(R.id.video_preview_surface);
    mRemoteVideoLayout = findViewById(R.id.remote_video_layout);

    seek_pink = findViewById(R.id.seek_pink);
    seek_whiten = findViewById(R.id.seek_whiten);
    seek_redden = findViewById(R.id.seek_redden);
    seek_soften = findViewById(R.id.seek_soften);
    seek_bigeye = findViewById(R.id.seek_bigeye);
    seek_thinface = findViewById(R.id.seek_thinface);

    pink_value = findViewById(R.id.pink_value);
    whiten_value = findViewById(R.id.whiten_value);
    redden_value = findViewById(R.id.redden_value);
    soften_value = findViewById(R.id.soften_value);
    bigeye_value = findViewById(R.id.bigeye_value);
    thinface_value = findViewById(R.id.thinface_value);

    seek_pink.setOnSeekBarChangeListener(this);
    seek_whiten.setOnSeekBarChangeListener(this);
    seek_redden.setOnSeekBarChangeListener(this);
    seek_soften.setOnSeekBarChangeListener(this);
    seek_bigeye.setOnSeekBarChangeListener(this);
    seek_thinface.setOnSeekBarChangeListener(this);
  }

  private void initCamera() {
    mCameraManager = cameraVideoManager();
    mPreprocessor = (Camera360Preprocessor) mCameraManager.getPreprocessor();
    mPreprocessor.setIsFront(true);

    mCameraManager.setCameraStateListener(new VideoCapture.VideoCaptureStateListener() {
      @Override
      public void onFirstCapturedFrame(int width, int height) {
        Log.i(TAG, "onFirstCapturedFrame: " + width + "x" + height);
      }

      @Override
      public void onCameraCaptureError(int error, String msg) {
        Log.i(TAG, "onCameraCaptureError: error:" + error + " " + msg);
        if (mCameraManager != null) {
          // When there is a camera error, the capture should
          // be stopped to reset the internal states.
          mCameraManager.stopCapture();
        }
      }

      @Override
      public void onCameraClosed() {
        Log.i(TAG, "onCameraClosed() called");
      }
    });
    mCameraManager.setPictureSize(CAPTURE_WIDTH, CAPTURE_HEIGHT);
    mCameraManager.setFrameRate(CAPTURE_FRAME_RATE);
    mCameraManager.setFacing(Constant.CAMERA_FACING_FRONT);
    mCameraManager.setLocalPreviewMirror(Constant.MIRROR_MODE_AUTO);
    mCameraManager.setLocalPreview(mLocalPreview);

    seek_pink.setProgress((int) (mPreprocessor.getSkinPink() * 100));
    seek_whiten.setProgress((int) (mPreprocessor.getSkinWhiten() * 100));
    seek_redden.setProgress((int) (mPreprocessor.getSkinRedden() * 100));
    seek_soften.setProgress(mPreprocessor.getSkinSoftStrength());
    seek_bigeye.setProgress(mPreprocessor.getBigEyeStrength());
    seek_thinface.setProgress(mPreprocessor.getThinFaceStrength());
  }

  private void initRtc() {
    setRtcConfig();

    registerHandler(this);

    rtcEngine().enableAudio();
    rtcEngine().enableVideo();
    rtcEngine().enableLocalAudio(true);
    rtcEngine().enableLocalVideo(true);

    RtcVideoConsumer mRtcVideoConsumer = new RtcVideoConsumer();
    rtcEngine().setVideoSource(mRtcVideoConsumer);

    rtcEngine().startPreview();

    mChannelName = getIntent().getStringExtra(Const.KEY_CHANNEL_NAME);
    rtcEngine().joinChannel(null, mChannelName, null, 0);
  }

  public void onCameraSwitched(View view) {
    mCameraManager.switchCamera();
    mPreprocessor.switchCamera();
  }

  public void onMuteClicked(View view) {
    mMuted = !mMuted;
    rtcEngine().muteLocalAudioStream(mMuted);
  }

  @Override
  public void finish() {
    super.finish();
    rtcEngine().leaveChannel();
  }

  @Override
  public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
    Log.i(TAG, "onJoinChannelSuccess " + channel + " " + uid);
  }

  @Override
  public void onUserJoined(int uid, int elapsed) {
    mRemoteUid = uid;
  }

  @Override
  public void onUserOffline(int uid, int reason) {
    runOnUiThread(() -> {
      if (mRemoteUid == uid) {
        mRemoteVideoLayout.removeAllViews();
        mRemoteVideoLayout.setVisibility(View.GONE);
        mRemoteUid = -1;
      }
    });
  }

  @Override
  public void onRemoteVideoStateChanged(int uid, int state, int reason, int elapsed) {
    if (mRemoteUid == uid && state == Constants.REMOTE_VIDEO_STATE_DECODING) {
      runOnUiThread(() -> {
        SurfaceView surfaceView = setupRemoteView(mRemoteUid);
        mRemoteVideoLayout.setVisibility(View.VISIBLE);
        mRemoteVideoLayout.addView(surfaceView);
      });
    }
  }

  @Override
  public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
    if (fromUser == false) {
      return;
    }

    if (seekBar == seek_pink) {
      float value = progress / 100f;
      pink_value.setText(String.valueOf(value));
      mPreprocessor.setSkinPink(value);
    } else if (seekBar == seek_whiten) {
      float value = progress / 100f;
      whiten_value.setText(String.valueOf(value));
      mPreprocessor.setSkinWhiten(value);
    } else if (seekBar == seek_redden) {
      float value = progress / 100f;
      redden_value.setText(String.valueOf(value));
      mPreprocessor.setSkinRedden(value);
    } else if (seekBar == seek_soften) {
      soften_value.setText(String.valueOf(progress));
      mPreprocessor.setSkinStrength(progress);
    } else if (seekBar == seek_bigeye) {
      bigeye_value.setText(String.valueOf(progress));
      mPreprocessor.setFaceShapingParam(progress, mPreprocessor.getThinFaceStrength());
    } else if (seekBar == seek_thinface) {
      thinface_value.setText(String.valueOf(progress));
      mPreprocessor.setFaceShapingParam(mPreprocessor.getBigEyeStrength(), progress);
    }
  }

  @Override
  public void onStartTrackingTouch(SeekBar seekBar) {

  }

  @Override
  public void onStopTrackingTouch(SeekBar seekBar) {

  }

  @Override
  protected void onResume() {
    super.onResume();
    mOrientationListener.enable();
    mPreprocessor.resume();
    mCameraManager.startCapture();
  }

  @Override
  protected void onPause() {
    super.onPause();
    mOrientationListener.disable();
    mPreprocessor.pause();
    mCameraManager.stopCapture();
  }

  @Override
  protected void onDestroy() {
    removeHandler(this);
    mOrientationListener.disable();
    super.onDestroy();
  }
}
