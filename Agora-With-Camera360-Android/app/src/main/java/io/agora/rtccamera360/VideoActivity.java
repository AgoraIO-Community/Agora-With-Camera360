package io.agora.rtccamera360;

import android.os.Bundle;
import android.util.Log;
import android.view.SurfaceView;
import android.view.TextureView;
import android.view.View;
import android.widget.RelativeLayout;

import io.agora.capture.video.camera.CameraVideoManager;
import io.agora.capture.video.camera.Constant;
import io.agora.framework.Camera360Preprocessor;
import io.agora.framework.RtcVideoConsumer;
import io.agora.rtc.Constants;

public class VideoActivity extends BaseActivity {
    private static final String TAG = VideoActivity.class.getSimpleName();

    private CameraVideoManager mCameraManager;
    private Camera360Preprocessor mPreprocessor;

    private TextureView mLocalPreview;
    private RelativeLayout mRemoteVideoLayout;

    private int mRemoteUid = -1;
    private String mChannelName;

    private boolean mFinished;

    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initUI();
        initCamera();
        initRtc();
    }

    private void initUI() {
        setContentView(R.layout.video_activity);
        mLocalPreview = findViewById(R.id.video_preview_surface);
        mRemoteVideoLayout = findViewById(R.id.remote_video_layout);
    }

    private void initCamera() {
        mCameraManager = cameraVideoManager();
        if (mCameraManager != null) {
            mPreprocessor = (Camera360Preprocessor) mCameraManager.getPreprocessor();
            mCameraManager.setPictureSize(1920, 1080);
            mCameraManager.setFrameRate(24);
            mCameraManager.setFacing(Constant.CAMERA_FACING_FRONT);
            mCameraManager.setLocalPreview(mLocalPreview);
        }
    }

    private void initRtc() {
        setRtcConfig();
        rtcEngine().setVideoSource(new RtcVideoConsumer());
        mChannelName = getIntent().getStringExtra(Const.KEY_CHANNEL_NAME);
        rtcEngine().joinChannel(null, mChannelName, null, 0);
    }

    private boolean cameraAvailable() {
        if (mCameraManager == null) {
            initCamera();
        }

        return mCameraManager != null;
    }

    public void onCameraSwitched(View view) {
        if (cameraAvailable()) {
            mCameraManager.switchCamera();
        }
    }

    @Override
    public void onStart() {
        super.onStart();
        registerHandler(this);
        if (cameraAvailable()) {
            mCameraManager.startCapture();
        }
    }

    @Override
    public void finish() {
        super.finish();
        mFinished = true;
        if (cameraAvailable()) {
            mCameraManager.stopCapture();
        }

        rtcEngine().leaveChannel();
    }

    @Override
    public void onStop() {
        super.onStop();
        removeHandler(this);
        if (!mFinished && cameraAvailable()) {
            mCameraManager.stopCapture();
        }
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
        runOnUiThread(() ->  {
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
}
