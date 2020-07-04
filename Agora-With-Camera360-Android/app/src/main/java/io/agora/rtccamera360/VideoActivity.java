package io.agora.rtccamera360;

import android.os.Bundle;
import android.view.TextureView;
import android.view.View;

import io.agora.capture.video.camera.CameraVideoManager;
import io.agora.capture.video.camera.Constant;
import io.agora.framework.Camera360Preprocessor;

public class VideoActivity extends BaseActivity {
    private CameraVideoManager mCameraManager;
    private Camera360Preprocessor mPreprocessor;

    private TextureView mLocalPreview;
    private boolean mFinished;

    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initUI();
        initCamera();
    }

    private void initUI() {
        setContentView(R.layout.video_activity);
        mLocalPreview = findViewById(R.id.video_preview_surface);
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

    private boolean cameraAvailable() {
        if (mCameraManager == null) {
            initCamera();
        }

        return mCameraManager != null;
    }

    public void onCameraSwitched(View view) {
        if (mCameraManager != null) {
            mCameraManager.switchCamera();
        }
    }

    @Override
    public void onStart() {
        super.onStart();
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
    }

    @Override
    public void onStop() {
        super.onStop();
        if (!mFinished && cameraAvailable()) {
            mCameraManager.stopCapture();
        }
    }
}
