package com.sportsbeep.app.ui.view;

import com.sportsbeep.app.R;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PointF;
import android.util.AttributeSet;
import android.view.MotionEvent;
import android.view.SoundEffectConstants;
import android.view.View;
import android.widget.RelativeLayout;

public class SplitColorRelativeLayout extends RelativeLayout {

    private final PointF mTopLeftPoint = new PointF();

    private final PointF mTopMiddlePoint = new PointF();

    private final PointF mTopRightPoint = new PointF();

    private final PointF mBottomLeftPoint = new PointF();

    private final PointF mBottomMiddlePoint = new PointF();

    private final PointF mBottomRightPoint = new PointF();

    private final Path mPath = new Path();

    private final Paint mPaint = new Paint(Paint.ANTI_ALIAS_FLAG);

    ;

    private int mTopBackgroundColor;

    private int mBottomBackgroundColor;

    private SplitDirection mSplitDirection = SplitDirection.DIAGONAL;

    private MotionEvent mLastMotionEvent;

    private OnClickListener mOnTopLeftClickListener;

    private OnClickListener mOnBottomRightClickListener;

    private OnLongClickListener mOnTopLeftLongClickListener;

    private OnLongClickListener mOnBottomRightLongClickListener;

    public SplitColorRelativeLayout(Context context) {
        super(context);
        setWillNotDraw(false);
        init();
    }

    public SplitColorRelativeLayout(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public SplitColorRelativeLayout(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        setWillNotDraw(false);

        TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.SplitColorRelativeLayout);
        mTopBackgroundColor = a.getColor(R.styleable.SplitColorRelativeLayout_topBackgroundColor, Color.TRANSPARENT);
        mBottomBackgroundColor = a.getColor(R.styleable.SplitColorRelativeLayout_bottomBackgroundColor, Color.TRANSPARENT);

        int splitDirectionValue = a.getInt(R.styleable.SplitColorRelativeLayout_splitDirection, 0);
        mSplitDirection = SplitDirection.getSplitDirectionFromValue(splitDirectionValue);

        a.recycle();

        init();
    }

    private void init() {
        mPath.setFillType(Path.FillType.EVEN_ODD);
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);

        mTopLeftPoint.set(0, 0);
        mTopMiddlePoint.set(w / 2, 0);
        mTopRightPoint.set(w, 0);
        mBottomLeftPoint.set(0, h);
        mBottomMiddlePoint.set(w / 2, h);
        mBottomRightPoint.set(w, h);

        invalidate();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        switch (getSplitDirection()) {
            case DIAGONAL:
                drawTriangle(canvas, mTopLeftPoint, mTopRightPoint, mBottomLeftPoint, getTopBackgroundColor());
                drawTriangle(canvas, mBottomRightPoint, mBottomLeftPoint, mTopRightPoint, getBottomBackgroundColor());
                break;
            case VERTICAL:
                drawRectangle(canvas, mTopLeftPoint, mTopMiddlePoint, mBottomMiddlePoint, mBottomLeftPoint, getTopBackgroundColor());
                drawRectangle(canvas, mBottomRightPoint, mBottomMiddlePoint, mTopMiddlePoint, mTopRightPoint, getBottomBackgroundColor());
                break;
        }
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {
        mLastMotionEvent = ev;
        return super.onInterceptTouchEvent(ev);
    }

    @Override
    public boolean performLongClick() {
        int[] location = new int[2];
        getLocationInWindow(location);
        float x = mLastMotionEvent.getX() - location[0];
        float y = mLastMotionEvent.getY() - location[1];
        PointF clickPoint = new PointF(x, y);
        if (mOnTopLeftLongClickListener != null && isPointWithinTopLeftTriangle(clickPoint)) {
            mOnTopLeftLongClickListener.onLongClick(this);
        } else if (mOnBottomRightLongClickListener != null && isPointWithinBottomRightTriangle(clickPoint)) {
            mOnBottomRightLongClickListener.onLongClick(this);
        } else {
            return super.performLongClick();
        }

        return true;
    }

    @Override
    public boolean performClick() {
        int[] location = new int[2];
        getLocationInWindow(location);
        float x = mLastMotionEvent.getX() - location[0];
        float y = mLastMotionEvent.getY() - location[1];
        PointF clickPoint = new PointF(x, y);
        if (mOnTopLeftClickListener != null && isPointWithinTopLeftTriangle(clickPoint)) {
            mOnTopLeftClickListener.onClick(this);
            playSoundEffect(SoundEffectConstants.CLICK);
        } else if (mOnBottomRightClickListener != null && isPointWithinBottomRightTriangle(
                clickPoint)) {
            mOnBottomRightClickListener.onClick(this);
            playSoundEffect(SoundEffectConstants.CLICK);
        } else {
            return super.performClick();
        }

        return true;
    }

    private boolean isPointWithinTopLeftTriangle(PointF point) {
        return isPointWithinTriangle(point, mTopLeftPoint, mTopRightPoint, mBottomLeftPoint);
    }

    private boolean isPointWithinBottomRightTriangle(PointF point) {
        return isPointWithinTriangle(point, mBottomRightPoint, mBottomLeftPoint, mTopRightPoint);
    }

    // Computed using barycentric coordinates
    private boolean isPointWithinTriangle(PointF p, PointF p1, PointF p2, PointF p3) {
        float alpha = ((p2.y - p3.y) * (p.x - p3.x) + (p3.x - p2.x) * (p.y - p3.y)) /
                ((p2.y - p3.y) * (p1.x - p3.x) + (p3.x - p2.x) * (p1.y - p3.y));
        float beta = ((p3.y - p1.y) * (p.x - p3.x) + (p1.x - p3.x) * (p.y - p3.y)) /
                ((p2.y - p3.y) * (p1.x - p3.x) + (p3.x - p2.x) * (p1.y - p3.y));
        float gamma = 1.0f - alpha - beta;

        return alpha > 0.f && beta > 0.f && gamma > 0.f;
    }

    private void drawTriangle(Canvas canvas, PointF p1, PointF p2, PointF p3, int color) {
        mPaint.reset();
        mPaint.setFlags(Paint.ANTI_ALIAS_FLAG);
        mPaint.setStyle(Paint.Style.FILL_AND_STROKE);
        mPaint.setColor(color);

        mPath.reset();
        mPath.moveTo(p1.x, p1.y);
        mPath.lineTo(p2.x, p2.y);
        mPath.lineTo(p3.x, p3.y);
        mPath.lineTo(p1.x, p1.y);
        mPath.close();

        canvas.drawPath(mPath, mPaint);
    }

    private void drawRectangle(Canvas canvas, PointF p1, PointF p2, PointF p3, PointF p4, int color) {
        mPaint.reset();
        mPaint.setFlags(Paint.ANTI_ALIAS_FLAG);
        mPaint.setStyle(Paint.Style.FILL_AND_STROKE);
        mPaint.setColor(color);

        mPath.reset();
        mPath.moveTo(p1.x, p1.y);
        mPath.lineTo(p2.x, p2.y);
        mPath.lineTo(p3.x, p3.y);
        mPath.lineTo(p4.x, p4.y);
        mPath.lineTo(p1.x, p1.y);
        mPath.close();

        canvas.drawPath(mPath, mPaint);
    }

    private void performRegisterLongClickListener() {
        if (mOnBottomRightLongClickListener != null || mOnTopLeftLongClickListener != null) {
            setOnLongClickListener(new OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    return true;
                }
            });
        } else {
            setOnClickListener(null);
        }
    }

    private void performRegisterClickListener() {
        if (mOnBottomRightClickListener != null || mOnTopLeftClickListener != null) {
            setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    // no-op
                }
            });
        } else {
            setOnClickListener(null);
        }
    }

    public void setOnTopLeftClickListener(OnClickListener l) {
        mOnTopLeftClickListener = l;
        performRegisterClickListener();
    }

    public void setOnBottomRightClickListener(OnClickListener l) {
        mOnBottomRightClickListener = l;
        performRegisterClickListener();
    }

    int getBottomBackgroundColor() {
        return mBottomBackgroundColor;
    }

    public void setBottomRightBackgroundColor(int bottomBackgroundColor) {
        mBottomBackgroundColor = bottomBackgroundColor;
        invalidate();
    }

    int getTopBackgroundColor() {
        return mTopBackgroundColor;
    }

    public void setTopLeftBackgroundColor(int topBackgroundColor) {
        mTopBackgroundColor = topBackgroundColor;
        invalidate();
    }

    SplitDirection getSplitDirection() {
        return mSplitDirection;
    }

    public void setSplitDirection(SplitDirection splitDirection) {
        mSplitDirection = splitDirection;
        invalidate();
    }

    public void setOnTopLeftLongClickListener(OnLongClickListener onTopLeftLongClickListener) {
        mOnTopLeftLongClickListener = onTopLeftLongClickListener;
        performRegisterLongClickListener();
    }

    public void setOnBottomRightLongClickListener(OnLongClickListener onBottomRightLongClickListener) {
        mOnBottomRightLongClickListener = onBottomRightLongClickListener;
        performRegisterLongClickListener();
    }

    public enum SplitDirection {
        DIAGONAL(0),
        VERTICAL(1);

        int value;

        SplitDirection(int value) {
            this.value = value;
        }

        public static SplitDirection getSplitDirectionFromValue(int value) {
            for (SplitDirection splitDirection : values()) {
                if (splitDirection.value == value) {
                    return splitDirection;
                }
            }

            return null;
        }
    }
}
