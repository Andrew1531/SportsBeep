package com.sportsbeep.app.util.typed;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URI;

import retrofit.mime.TypedOutput;

public class TypedUri implements TypedOutput {

    private static final int BUFFER_SIZE = 4096;

    private static final int SAMPLE_SIZE = 2;

    private final Context mContext;

    private final Uri mUri;

    private final String mMimeType;

    private final boolean mIsContent;

    private ProgressListener mListener;

    public TypedUri(Context context, Uri uri, String mimeType) {
        mContext = context;
        mUri = uri;
        mMimeType = mimeType;
        mIsContent = mUri.toString().startsWith("content");
    }

    @Override
    public String fileName() {
        return mUri.getLastPathSegment();
    }

    @Override
    public String mimeType() {
        return mMimeType;
    }

    @Override
    public long length() {
        return -1;
    }

    @Override
    public void writeTo(OutputStream out) throws IOException {
        byte[] buffer = new byte[BUFFER_SIZE];
        InputStream in;
        if (mIsContent) {
            in = mContext.getContentResolver().openInputStream(mUri);
        } else {
            in = new FileInputStream(uriToFile(mUri));
        }

        byte[] array;
        try {
            array = getBitmapByteArray(in, SAMPLE_SIZE);
        } finally {
            in.close();
        }

        long length = array.length;
        in = new ByteArrayInputStream(array);

        try {
            int percent = 0;
            int total = 0;
            int read;
            while ((read = in.read(buffer)) != -1) {
                out.write(buffer, 0, read);
                total += read;
                if (mListener != null) {
                    int newPercent = (int) (((float) total / (float) length) * 100f);
                    if (newPercent > percent) {
                        percent = newPercent;
                        mListener.onProgress(percent);
                    }
                }
            }
        } finally {
            in.close();
            if (mListener != null) {
                mListener.onFinish();
            }
        }
    }

    private byte[] getBitmapByteArray(InputStream in, int sampleSize) throws IOException {
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inSampleSize = sampleSize;

        Bitmap bitmap = BitmapFactory.decodeStream(in, null, options);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, baos);

        try {
            return baos.toByteArray();
        } finally {
            baos.close();
            bitmap.recycle();
        }
    }

    private File uriToFile(Uri uri) {
        return new File(URI.create(uri.toString()));
    }

    public void setListener(ProgressListener listener) {
        mListener = listener;
    }

    public static interface ProgressListener {

        public void onProgress(int percent);

        public void onFinish();
    }
}
