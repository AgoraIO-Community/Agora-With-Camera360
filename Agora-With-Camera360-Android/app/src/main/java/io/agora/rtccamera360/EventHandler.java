package io.agora.rtccamera360;

public interface EventHandler {

    void onJoinChannelSuccess(String channel, int uid, int elapsed);

    void onUserJoined(int uid, int elapsed);

    void onUserOffline(int uid, int reason);

    void onRemoteVideoStateChanged(int uid, int state, int reason, int elapsed);
}
