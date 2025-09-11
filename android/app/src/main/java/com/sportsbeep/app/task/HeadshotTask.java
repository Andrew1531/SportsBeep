package com.sportsbeep.app.task;

import com.sportsbeep.app.R;
import com.squareup.picasso.Picasso;
import com.squareup.picasso.Target;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.LayerDrawable;
import android.util.TypedValue;
import android.view.Gravity;
import android.widget.ImageView;

public class HeadshotTask implements Target {

    private static final float SIZE_DP = 182f;

    private final int mSize;

    private Context mContext;

    private ImageView mImageView;

    public HeadshotTask(Context context, ImageView imageView) {
        mContext = context;
        mImageView = imageView;
        mSize = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, SIZE_DP, mContext.getResources().getDisplayMetrics());
    }

    public void execute(String path) {
        Picasso.with(mContext).load(path).resize(mSize, mSize).centerCrop().into(this);
    }

    public void cancel() {
        Picasso.with(mContext).cancelRequest(this);

        mContext = null;
        mImageView = null;
    }

    @Override
    public void onBitmapLoaded(Bitmap bitmap, Picasso.LoadedFrom from) {
        BitmapDrawable bd = new BitmapDrawable(mContext.getResources(), bitmap);
        bd.setGravity(Gravity.CENTER);

        LayerDrawable ld = (LayerDrawable) mContext.getResources().getDrawable(R.drawable.player_silhouette_circle);
        ld.mutate();

        ld.setDrawableByLayerId(R.id.playerPortrait_Bitmap, bd);

        mImageView.setImageDrawable(ld);
    }

    @Override
    public void onBitmapFailed(Drawable errorDrawable) {
        // no-op
    }

    @Override
    public void onPrepareLoad(Drawable placeHolderDrawable) {
        // no-op
    }
}
