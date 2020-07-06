package com.pinguo.newSkinprettify.utils;

import android.content.Context;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;

public class FileUtils {
    public static byte[] readRawByteArray(Context context, int raw) {
        byte[] result = null;
        BufferedInputStream bis = null;
        try {
            InputStream is = context.getResources().openRawResource(raw);
            bis = new BufferedInputStream(is);
            int size = bis.available();
            if (size > 0) result = new byte[size];
            if (result != null) {
                byte[] buffer = new byte[256];
                int length;
                int index = 0;
                while ((length = bis.read(buffer, 0, 256)) != -1) {
                    System.arraycopy(buffer, 0, result, index, length);
                    index += length;
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (bis != null) {
                try {
                    bis.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }

        return result;
    }
}
