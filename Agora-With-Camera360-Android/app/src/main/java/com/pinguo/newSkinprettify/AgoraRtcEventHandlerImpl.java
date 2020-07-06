package com.pinguo.newSkinprettify;

import java.util.ArrayList;
import java.util.List;

import io.agora.rtc.IRtcEngineEventHandler;

public class AgoraRtcEventHandlerImpl extends IRtcEngineEventHandler {
    private List<EventHandler> mHandlers = new ArrayList<>();

    public void registerHandler(EventHandler handler) {
        if (!mHandlers.contains(handler)) {
            mHandlers.add(handler);
        }
    }

    public void removeHandler(EventHandler handler) {
        mHandlers.remove(handler);
    }

    @Override
    public void onJoinChannelSuccess(String channel, int uid, int elapsed) {
        for (EventHandler handler : mHandlers) {
            handler.onJoinChannelSuccess(channel, uid, elapsed);
        }
    }

    @Override
    public void onUserJoined(int uid, int elapsed) {
        for (EventHandler handler : mHandlers) {
            handler.onUserJoined(uid, elapsed);
        }
    }

    @Override
    public void onUserOffline(int uid, int reason) {
        for (EventHandler handler : mHandlers) {
            handler.onUserOffline(uid, reason);
        }
    }

    @Override
    public void onRemoteVideoStateChanged(int uid, int state, int reason, int elapsed) {
        for (EventHandler handler : mHandlers) {
            handler.onRemoteVideoStateChanged(uid, state, reason, elapsed);
        }
    }
}
