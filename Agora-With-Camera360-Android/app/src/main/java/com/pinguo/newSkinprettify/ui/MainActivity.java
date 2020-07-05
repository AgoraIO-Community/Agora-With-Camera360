package com.pinguo.newSkinprettify.ui;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatEditText;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.view.View;

import com.pinguo.newSkinprettify.Const;
import com.pinguo.newSkinprettify.R;

public class MainActivity extends AppCompatActivity {
    private static final int PERMISSION_REQ = 1;

    private static final String[] PERMISSIONS = {
            Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.WRITE_EXTERNAL_STORAGE
    };

    private AppCompatEditText mChannelEdit;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        mChannelEdit = findViewById(R.id.channel_name_edit);
        checkPermissions();
    }

    public void onJoinChannel(View view) {
        Editable editable = mChannelEdit.getText();
        if (!TextUtils.isEmpty(editable)) {
            String channelName = editable.toString();
            Intent intent = new Intent(this, VideoActivity.class);
            intent.putExtra(Const.KEY_CHANNEL_NAME, channelName);
            startActivity(intent);
        }
    }

    protected void checkPermissions() {
        if (!permissionArrayGranted()) {
            ActivityCompat.requestPermissions(this, PERMISSIONS, PERMISSION_REQ);
        }
    }

    private boolean permissionGranted(String permission) {
        return ContextCompat.checkSelfPermission(
                this, permission) == PackageManager.PERMISSION_GRANTED;
    }

    private boolean permissionArrayGranted() {
        boolean granted = true;
        for (String per : PERMISSIONS) {
            if (!permissionGranted(per)) {
                granted = false;
                break;
            }
        }
        return granted;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == PERMISSION_REQ) {
            checkPermissions();
        }
    }

}