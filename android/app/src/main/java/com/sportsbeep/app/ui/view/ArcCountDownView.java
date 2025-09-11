package com.sportsbeep.app.ui.view;

import com.sportsbeep.app.R;
import com.sportsbeep.app.util.CustomTypeface;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.Typeface;
import android.os.CountDownTimer;
import android.text.TextPaint;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;

public class ArcCountDownView extends View {

    private static final float DEFAULT_MIN_WIDTH = 64f;

    private static final float DEFAULT_MIN_HEIGHT = 64f;

    private static final float DEFAULT_STROKE_WIDTH = 10f;

    private static final float DEFAULT_START_ANGLE = 315f;

    private static final float DEFAULT_SWEEP_ANGLE = 180f;

    private static final int DEFAULT_TIME_START = 10000;

    private static final long TIME_INTERVAL = 33;

    private static final int DEFAULT_ARC_COLOR = Color.LTGRAY;

    private static final float DEFAULT_TEXT_SIZE = 16f;

    private static final int DEFAULT_TEXT_COLOR = Color.BLACK;

    private final Paint mPaint = new Paint();

    private final TextPaint mTextPaint = new TextPaint();

    private final RectF mOval = new RectF();

    private float mArcStrokeWidth;

    private int mArcColor;

    private float mStartAngle;

    private float mSweepAngle;

    private float mCurrentAngle;

    private float mCurrentSweepAngle;

    private long mTimeStart;

    private long mTimeRemaining;

    private int mTextColor;

    private float mTextSize;

    private float mTextOffsetX;

    private float mTextOffsetY;

    private Typeface mTypeface;

    private CountDown mCountDown;

    private OnCountDownFinishedListener mOnCountDownFinishedListener;

    public ArcCountDownView(Context context) {
        this(context, null, 0);
    }

    public ArcCountDownView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public ArcCountDownView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        if (attrs == null) {
            setMinimumWidth((int) dpToPx(DEFAULT_MIN_WIDTH));
            setMinimumHeight((int) dpToPx(DEFAULT_MIN_HEIGHT));
            return;
        }

        int[] minAttr = new int[]{android.R.attr.minWidth, android.R.attr.minHeight};
        TypedArray a = context.obtainStyledAttributes(attrs, minAttr);
        setMinimumWidth(a.getDimensionPixelSize(0, (int) dpToPx(DEFAULT_MIN_WIDTH)));
        setMinimumHeight(a.getDimensionPixelSize(1, (int) dpToPx(DEFAULT_MIN_HEIGHT)));
        a.recycle();

        a = context.obtainStyledAttributes(attrs, R.styleable.ArcCountDownView);
        mArcStrokeWidth = a.getDimension(R.styleable.ArcCountDownView_arcStrokeWidth,
                TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, DEFAULT_STROKE_WIDTH,
                        context.getResources().getDisplayMetrics()));
        mArcColor = a.getColor(R.styleable.ArcCountDownView_arcColor, DEFAULT_ARC_COLOR);
        mTimeStart = a.getInteger(R.styleable.ArcCountDownView_timeStart, DEFAULT_TIME_START);
        mStartAngle = a.getFloat(R.styleable.ArcCountDownView_arcAngleStart, DEFAULT_START_ANGLE);
        mSweepAngle = a.getFloat(R.styleable.ArcCountDownView_arcAngleSweep, DEFAULT_SWEEP_ANGLE);
        mTextSize = a
                .getDimension(R.styleable.ArcCountDownView_textSize, dpToPx(DEFAULT_TEXT_SIZE));
        mTextColor = a.getColor(R.styleable.ArcCountDownView_textColor, DEFAULT_TEXT_COLOR);
        mTextOffsetX = a.getDimension(R.styleable.ArcCountDownView_textOffsetX, 0);
        mTextOffsetY = a.getDimension(R.styleable.ArcCountDownView_textOffsetY, 0);
        int font = a.getInt(R.styleable.ArcCountDownView_font, 0);
        a.recycle();

        if (!isInEditMode()) {
            setTypeface(CustomTypeface.getForValue(font).get(context));
        }

        updatePaint();
        updateTextPaint();
        reset();
    }

    private static int getSize(int size, int minSize, int measureSpec) {
        int specMode = MeasureSpec.getMode(measureSpec);
        int specSize = MeasureSpec.getSize(measureSpec);

        int result;
        if (size == ViewGroup.LayoutParams.MATCH_PARENT) {
            result = specSize;
        } else if (size == ViewGroup.LayoutParams.WRAP_CONTENT) {
            result = minSize;
        } else {
            result = size;
        }

        switch (specMode) {
            case MeasureSpec.AT_MOST:
                result = Math.min(result, specSize);
                break;
            case MeasureSpec.EXACTLY:
                result = specSize;
                break;
        }

        return result;
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        ViewGroup.LayoutParams params = getLayoutParams();
        int userWidth = params.width;
        int userHeight = params.height;

        int width = getSize(userWidth, getSuggestedMinimumWidth(), widthMeasureSpec);
        int height = getSize(userHeight, getSuggestedMinimumHeight(), heightMeasureSpec);
        setMeasuredDimension(width, height);
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        //noinspection SuspiciousNameCombination
        mOval.set(mArcStrokeWidth, mArcStrokeWidth, w - mArcStrokeWidth, h - mArcStrokeWidth);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        canvas.drawArc(mOval, mCurrentAngle, mCurrentSweepAngle, false, mPaint);

        double seconds = (double) mTimeRemaining / 1000f;
        canvas.drawText(String.format("%.1f", seconds), getTextX(canvas), getTextY(canvas),
                mTextPaint);
    }

    private float getTextX(Canvas canvas) {
        return canvas.getWidth() / 2 + mTextOffsetX;
    }

    private float getTextY(Canvas canvas) {
        return canvas.getHeight() / 2 - (mTextPaint.descent() + mTextPaint.ascent()) / 2
                + mTextOffsetY;
    }

    void onCountDownFinished() {
        if (mOnCountDownFinishedListener != null) {
            mOnCountDownFinishedListener.onFinished();
        }
    }

    public void start() {
        if (isInProgress()) {
            return;
        }

        mCountDown = new CountDown(mTimeRemaining);
        mCountDown.start();
    }

    public void pause() {
        if (isInProgress()) {
            mCountDown.cancel();
            mCountDown = null;
        }
    }

    public void reset() {
        mTimeRemaining = mTimeStart;
        mCurrentAngle = mStartAngle;
        mCurrentSweepAngle = mSweepAngle;

        if (isInProgress()) {
            pause();
        }

        invalidate();
    }

    private float dpToPx(float dp) {
        return TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp,
                getResources().getDisplayMetrics());
    }

    private void updatePaint() {
        mPaint.setColor(mArcColor);
        mPaint.setStyle(Paint.Style.STROKE);
        mPaint.setStrokeWidth(mArcStrokeWidth);
    }

    private void updateTextPaint() {
        mTextPaint.setColor(mTextColor);
        mTextPaint.setTextSize(mTextSize);
        mTextPaint.setTypeface(mTypeface);
        mTextPaint.setTextAlign(Paint.Align.CENTER);
    }

    public Typeface getTypeface() {
        return mTypeface;
    }

    void setTypeface(Typeface typeface) {
        mTypeface = typeface;
    }

    boolean isInProgress() {
        return mCountDown != null;
    }

    public float getArcStrokeWidth() {
        return mArcStrokeWidth;
    }

    public void setArcStrokeWidth(float arcStrokeWidth) {
        mArcStrokeWidth = arcStrokeWidth;
    }

    public float getStartAngle() {
        return mStartAngle;
    }

    public void setStartAngle(float startAngle) {
        mStartAngle = startAngle;
        reset();
    }

    public float getSweepAngle() {
        return mSweepAngle;
    }

    public void setSweepAngle(float sweepAngle) {
        mSweepAngle = sweepAngle;
        reset();
    }

    public int getTextColor() {
        return mTextColor;
    }

    public void setTextColor(int textColor) {
        mTextColor = textColor;
    }

    public int getArcColor() {
        return mArcColor;
    }

    public void setArcColor(int arcColor) {
        mArcColor = arcColor;
    }

    public long getTimeStart() {
        return mTimeStart;
    }

    public void setTimeStart(long timeStart) {
        mTimeStart = timeStart;
        reset();
    }

    public long getTimeRemaining() {
        return mTimeRemaining;
    }

    public float getTextOffsetY() {
        return mTextOffsetY;
    }

    public void setTextOffsetY(float textOffsetY) {
        mTextOffsetY = textOffsetY;
    }

    public float getTextOffsetX() {
        return mTextOffsetX;
    }

    public void setTextOffsetX(float textOffsetX) {
        mTextOffsetX = textOffsetX;
    }

    public void setOnCountDownFinishedListener(
            OnCountDownFinishedListener onCountDownFinishedListener) {
        mOnCountDownFinishedListener = onCountDownFinishedListener;
    }

    public interface OnCountDownFinishedListener {

        public void onFinished();
    }

    private class CountDown extends CountDownTimer {

        public CountDown(long millisInFuture) {
            super(millisInFuture, ArcCountDownView.TIME_INTERVAL);
        }

        @Override
        public void onTick(long millisUntilFinished) {
            mTimeRemaining = millisUntilFinished;

            float percentRemaining = (float) mTimeRemaining / (float) mTimeStart;
            float delta = mSweepAngle - (mSweepAngle * percentRemaining);
            mCurrentAngle = mStartAngle + delta;
            mCurrentSweepAngle = mSweepAngle - delta;

            postInvalidate();
        }

        @Override
        public void onFinish() {
            mCountDown = null;
            mCurrentAngle = 0;
            mCurrentSweepAngle = 0;
            mTimeRemaining = 0;

            onCountDownFinished();
            postInvalidate();
        }
    }
}
