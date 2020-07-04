package io.agora.rtccamera360;

import android.os.Bundle;

import io.agora.capture.video.camera.CameraVideoManager;
import io.agora.framework.Camera360Preprocessor;

public class VideoActivity extends BaseActivity {
    private CameraVideoManager mCameraManager;
    private Camera360Preprocessor mPreprocessor;

    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initCamera();
        initUI();
    }

    private void initCamera() {
        mPreprocessor = new Camera360Preprocessor();
        mCameraManager = new CameraVideoManager(this, mPreprocessor);

        mCameraManager.setPictureSize(1920, 1080);
    }

    private void initUI() {

    }
}
