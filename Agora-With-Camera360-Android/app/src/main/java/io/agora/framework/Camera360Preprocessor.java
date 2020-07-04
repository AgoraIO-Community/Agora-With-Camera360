package io.agora.framework;

import io.agora.capture.framework.modules.channels.VideoChannel;
import io.agora.capture.framework.modules.processors.IPreprocessor;
import io.agora.capture.video.camera.VideoCaptureFrame;

public class Camera360Preprocessor implements IPreprocessor {
    @Override
    public VideoCaptureFrame onPreProcessFrame(VideoCaptureFrame videoCaptureFrame, VideoChannel.ChannelContext channelContext) {
        return null;
    }

    @Override
    public void initPreprocessor() {

    }

    @Override
    public void enablePreProcess(boolean enabled) {

    }

    @Override
    public void releasePreprocessor(VideoChannel.ChannelContext channelContext) {

    }
}
