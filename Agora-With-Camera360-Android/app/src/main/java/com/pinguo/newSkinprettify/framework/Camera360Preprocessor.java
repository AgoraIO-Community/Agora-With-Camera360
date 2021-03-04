package com.pinguo.newSkinprettify.framework;

import android.content.Context;
import android.opengl.GLES20;
import android.opengl.Matrix;
import android.util.Log;
import androidx.annotation.FloatRange;
import androidx.annotation.IntRange;
import com.pinguo.newSkinprettify.R;
import com.pinguo.newSkinprettify.utils.FileUtils;
import io.agora.capture.framework.modules.channels.VideoChannel;
import io.agora.capture.framework.modules.processors.IPreprocessor;
import io.agora.capture.video.camera.VideoCaptureFrame;
import us.pinguo.pgskinprettifyengine.PGSkinPrettifyEngine;
import us.pinguo.pgskinprettifyengine.PGSkinPrettifyEngine.PG_Orientation;
import us.pinguo.pgskinprettifyengine.PGSkinPrettifyEngine.PG_SoftenAlgorithm;
import us.pinguo.prettifyengine.PGPrettifySDK;
import us.pinguo.prettifyengine.entity.CameraInfo;

public class Camera360Preprocessor implements IPreprocessor {

  private static final String TAG = "Camera360Preprocessor";
  private static final int CAMERA_360_MODEL = R.raw.megvii_facepp;

  private PGPrettifySDK mCameraPrettyBase;
  private Context mContext;
  private boolean mEnabled;

  private float mSkinPink = 0.6f;
  private float mSkinWhiten = 0.5f;
  private float mSkinRedden = 0.6f;
  private int mSkinSoftStrength = 70;
  private PGSkinPrettifyEngine.PG_SoftenAlgorithm mAlgorithm = PG_SoftenAlgorithm.PG_SoftenAlgorithmContrast;
  private int iBigEyeStrength = 50;
  private int iThinFaceStrength = 50;

  private volatile boolean isFirst = true;

  private boolean mSkinColorChanged = true;
  private boolean mSkinSoftStrengthChanged = true;
  private boolean mAlgorithmChanged = true;
  private boolean mFaceShapingParamChanged = true;

  private volatile CameraInfo mCameraInfo = new CameraInfo(-1, -1, 0, 0, true);

  public Camera360Preprocessor(Context context) {
    mContext = context.getApplicationContext();
    mEnabled = true;
  }

  public void setIsFront(boolean isFront) {
    this.mCameraInfo.isFront = isFront;
  }

  @Override
  public VideoCaptureFrame onPreProcessFrame(VideoCaptureFrame videoCaptureFrame,
      VideoChannel.ChannelContext channelContext) {
    if (!mEnabled) {
      return videoCaptureFrame;
    }

    if (isFirst) {
      int width = videoCaptureFrame.format.getWidth();
      int height = videoCaptureFrame.format.getHeight();
      int rotation = videoCaptureFrame.rotation;

      CameraInfo mCameraInfo = new CameraInfo(width, height, 0, rotation, this.mCameraInfo.isFront);
      mCameraPrettyBase.setCameraInfo(mCameraInfo);
      this.mCameraInfo = mCameraInfo;

      //设置一个尺寸，用于调整输入帧的宽高，也是最终输出帧的宽高
      if (mCameraInfo.cameraOri == 0 || mCameraInfo.cameraOri == 180) {
        mCameraPrettyBase.SetSizeForAdjustInput(width, height);
      } else {
        mCameraPrettyBase.SetSizeForAdjustInput(height, width);
      }

      //设置一个方向，用于校正输入的预览帧（必须设置项 &需要在SetSizeForAdjustInput之后）
      if (mCameraInfo.isFront) {
        mCameraPrettyBase.SetOrientForAdjustInput(PG_Orientation.PG_OrientationRightRotate90);
      } else {
        mCameraPrettyBase.SetOrientForAdjustInput(
            PGSkinPrettifyEngine.PG_Orientation.PG_OrientationRightRotate270Mirrored);
      }

      //设置输出方向（必须设置项 &需要在SetSizeForAdjustInput之后）
      mCameraPrettyBase.SetOutputOrientation(PG_Orientation.PG_OrientationFlipped);

      //设置输出格式
      mCameraPrettyBase.SetOutputFormat(PGSkinPrettifyEngine.PG_PixelFormat.PG_Pixel_NV21);

      mCameraPrettyBase.Switch2DStickerWH(true);
      mCameraPrettyBase.setUseBigEyeSlimFace(true);

      isFirst = false;
    }

    VideoCaptureFrame output = new VideoCaptureFrame(videoCaptureFrame);
    setParameters(output);

    mCameraPrettyBase.RunEngine();
    output.textureId = mCameraPrettyBase.GetOutputTextureID();
    output.format.setTexFormat(GLES20.GL_TEXTURE_2D);
    Matrix.setIdentityM(output.textureTransform, 0);
    return output;
  }

  private void setParameters(VideoCaptureFrame frame) {
    int width = frame.format.getWidth();
    int height = frame.format.getHeight();

    /**
     * FAQ
     * Android美颜有没有推荐的参数
     *
     * 大部分机型上推荐的参数是：
     * 1.粉嫩0.4，红润0.7，白皙0.5，美肤70
     * 2.粉嫩0.6，红润0.5，白皙0.6，美肤70
     * 这两组参数附近都是较好的效果，美是一个很主观的问题，可根据实际自行调整
     * */
    if (mSkinColorChanged) {
      mCameraPrettyBase.SetSkinColor(mSkinPink, mSkinWhiten, mSkinRedden);
      mSkinColorChanged = false;
    }

    if (mSkinSoftStrengthChanged) {
      mCameraPrettyBase.SetSkinSoftenStrength(mSkinSoftStrength);
      mSkinSoftStrengthChanged = false;
    }

    if (mFaceShapingParamChanged) {
      mCameraPrettyBase.SetFaceShapingParam(iBigEyeStrength, iThinFaceStrength);
      mFaceShapingParamChanged = false;
    }

    if (mAlgorithmChanged) {
      mCameraPrettyBase.SetSkinSoftenAlgorithm(mAlgorithm);
      mAlgorithmChanged = false;
    }

    //设置输入帧
    mCameraPrettyBase.SetInputFrameByTexture(frame.textureId, width, height,
        toTextureType(frame.format.getTexFormat()));

    //瘦脸大眼功能才会生效
    mCameraPrettyBase.renderSticker(frame.image);
  }

  private int toTextureType(int texture) {
    return texture == GLES20.GL_TEXTURE_2D ? 1 : 0;
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

  }

  public void resume() {
    mCameraPrettyBase.prePare();
  }

  public void pause() {
    isFirst = true;
  }

  public void destory() {
    this.mCameraInfo.isFront = true;
    mCameraPrettyBase.release();
    isFirst = true;
  }

  /**
   * 控制整体的美肤强度(磨皮强度)
   *
   * @param strength 0-100
   */
  public void setSkinStrength(@IntRange(from = 0, to = 100) int strength) {
    mSkinSoftStrength = strength;
    mSkinSoftStrengthChanged = true;
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

  /**
   * 控制滤镜效果的强度-粉嫩程度
   *
   * @param pink 0.0-1.0
   */
  public void setSkinPink(@FloatRange(from = 0.0f, to = 1.0f) float pink) {
    mSkinPink = shrinkValue(pink);
    mSkinColorChanged = true;
  }

  /**
   * 控制滤镜效果的强度-白皙程度
   *
   * @param whiten 0.0-1.0
   */
  public void setSkinWhiten(@FloatRange(from = 0.0f, to = 1.0f) float whiten) {
    mSkinWhiten = shrinkValue(whiten);
    mSkinColorChanged = true;
  }

  /**
   * 控制滤镜效果的强度-红润程度
   *
   * @param redden 0.0-1.0
   */
  public void setSkinRedden(@FloatRange(from = 0.0f, to = 1.0f) float redden) {
    mSkinRedden = shrinkValue(redden);
    mSkinColorChanged = true;
  }

  public float getSkinPink() {
    return mSkinPink;
  }

  public float getSkinWhiten() {
    return mSkinWhiten;
  }

  public float getSkinRedden() {
    return mSkinRedden;
  }

  public int getSkinSoftStrength() {
    return mSkinSoftStrength;
  }

  /**
   * 瘦脸大眼功能-开关
   *
   * @param flag
   */
  public void setUseBigEyeSlimFace(boolean flag) {
    mCameraPrettyBase.setUseBigEyeSlimFace(flag);
  }

  /**
   * 瘦脸大眼功能-设置程度
   *
   * @param iBigEyeStrength   0-100
   * @param iThinFaceStrength 0-100
   */
  public void setFaceShapingParam(@IntRange(from = 0, to = 100) int iBigEyeStrength,
      @IntRange(from = 0, to = 100) int iThinFaceStrength) {
    this.iBigEyeStrength = iBigEyeStrength;
    this.iThinFaceStrength = iThinFaceStrength;
    mFaceShapingParamChanged = true;
  }

  public int getBigEyeStrength() {
    return iBigEyeStrength;
  }

  public int getThinFaceStrength() {
    return iThinFaceStrength;
  }

  /**
   * 设置磨皮算法
   *
   * @param iAlgorithm
   */
  public void setSkinSoftenAlgorithm(PG_SoftenAlgorithm iAlgorithm) {
    this.mAlgorithm = iAlgorithm;
    mAlgorithmChanged = true;
  }

  public void onOrientationChanged(int orientation) {
    mCameraPrettyBase.onSreenOriChanged(orientation, this.mCameraInfo.isFront);
  }

  public void switchCamera() {
    this.mCameraInfo.isFront = !this.mCameraInfo.isFront;
    mCameraPrettyBase.setCameraInfo(this.mCameraInfo);
    mCameraPrettyBase.onCameraOriChanged(this.mCameraInfo.cameraOri, this.mCameraInfo.isFront);

    if (this.mCameraInfo.isFront) {
      mCameraPrettyBase.SetOrientForAdjustInput(PG_Orientation.PG_OrientationRightRotate90);
    } else {
      mCameraPrettyBase.SetOrientForAdjustInput(
          PG_Orientation.PG_OrientationRightRotate270Mirrored);
    }

    mCameraPrettyBase.SetOutputOrientation(PG_Orientation.PG_OrientationFlipped);
  }
}
