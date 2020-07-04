package io.agora.rtccamera360;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.AppCompatEditText;

import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextUtils;
import android.view.View;

public class MainActivity extends AppCompatActivity {
    private AppCompatEditText mChannelEdit;

    private boolean mFinished;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        mChannelEdit = findViewById(R.id.channel_name_edit);
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

    @Override
    public void onStart() {
        super.onStart();
    }

    @Override
    public void finish() {
        super.finish();
        mFinished = true;
    }

    @Override
    public void onStop() {
        super.onStop();
        if (!mFinished) {

        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }
}