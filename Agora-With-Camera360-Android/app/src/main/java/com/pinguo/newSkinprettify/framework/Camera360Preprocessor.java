package com.pinguo.newSkinprettify.framework;

import android.content.Context;
import android.opengl.GLES20;
import android.util.Log;

import com.pinguo.newSkinprettify.R;
import com.pinguo.newSkinprettify.utils.FileUtils;

import io.agora.capture.framework.modules.channels.VideoChannel;
import io.agora.capture.framework.modules.processors.IPreprocessor;
import io.agora.capture.video.camera.VideoCaptureFrame;
import us.pinguo.pgskinprettifyengine.PGSkinPrettifyEngine;
import us.pinguo.prettifyengine.PGPrettifySDK;

public class Camera360Preprocessor implements IPreprocessor {
    private static final String TAG = "Camera360Preprocessor";
    private static final int CAMERA_360_MODEL = R.raw.megvii_facepp;

    private PGPrettifySDK mCameraPrettyBase;
    private Context mContext;
    private boolean mEnabled;

    private float mSkinPink = 0.5f;
    private float mSkinWhiten = 0.6f;
    private float mSkinRedden = 0.4f;
    private int mSkinSoftStrength = 100;

    public Camera360Preprocessor(Context context) {
        mContext = context;
        mEnabled = true;
    }

    @Override
    public VideoCaptureFrame onPreProcessFrame(VideoCaptureFrame videoCaptureFrame, VideoChannel.ChannelContext channelContext) {
        if (!mEnabled) return videoCaptureFrame;

        VideoCaptureFrame output = new VideoCaptureFrame(videoCaptureFrame);
        setParameters(output);
        output.textureId = runPrettify();
        output.format.setTexFormat(GLES20.GL_TEXTURE_2D);
        return output;
    }

    private void setParameters(VideoCaptureFrame frame) {
        int width = frame.format.getWidth();
        int height = frame.format.getHeight();

        mCameraPrettyBase.SetSizeForAdjustInput(width, height);

        mCameraPrettyBase.SetInputFrameByTexture(frame.textureId, width, height, 1);

        // The frames are already rotated to the desired direction
        mCameraPrettyBase.SetOrientForAdjustInput(PGSkinPrettifyEngine.PG_Orientation.PG_OrientationNormal);

        mCameraPrettyBase.SetSkinSoftenStrength(mSkinSoftStrength);
        mCameraPrettyBase.SetSkinColor(mSkinPink, mSkinWhiten, mSkinRedden);

        // mCameraPrettyBase.SetOutputFormat(PGSkinPrettifyEngine.PG_PixelFormat.PG_Pixel_I420);
        mCameraPrettyBase.SetOutputOrientation(PGSkinPrettifyEngine.PG_Orientation.PG_OrientationNormal);
    }

    private int runPrettify() {
        mCameraPrettyBase.RunEngine();
        int width = mCameraPrettyBase.GetActualOutputWidth();
        int height = mCameraPrettyBase.GetActualOutputHeight();
        int id = mCameraPrettyBase.GetOutputTextureID();
        Log.i(TAG, "runPrettify: id " + id + " width " + width + "height " + height);
        return id;
    }

    @Override
    public void initPreprocessor() {
        Log.i(TAG, "initPreprocessor");
        mCameraPrettyBase = new PGPrettifySDK(mContext, false);
        byte[] modelData = FileUtils.readRawByteArray(mContext, CAMERA_360_MODEL);

        if (mCameraPrettyBase.InitialiseEngine(mContext.getString(
                R.string.camera_360_licence), false, modelData)) {
            Log.i(TAG, "Camera360 prettify initialize success");
        } else {
            Log.e(TAG, "Camera360 prettify initialize error");
        }
    }

    @Override
    public void enablePreProcess(boolean enabled) {
        mEnabled = enabled;
    }

    @Override
    public void releasePreprocessor(VideoChannel.ChannelContext channelContext) {
        mCameraPrettyBase.release();
    }

    public void setSkinStrength(int strength) {
        mSkinSoftStrength = strength;
    }

    private float shrinkValue(float value) {
        if (value <= 0) {
            return 0;
        } else if (value > 1) {
            return 1;
        } else {
            return value;
        }
    }

    public void setSkinPink(float pink) {
        mSkinPink = shrinkValue(pink);
    }

    public void setSkinWhiten(float whiten) {
        mSkinWhiten = shrinkValue(whiten);
    }

    public void setSkinRedden(int redden) {
        mSkinRedden = shrinkValue(redden);
    }
}
