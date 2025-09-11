package com.sportsbeep.app.ui.view;

import com.sportsbeep.app.R;
import com.sportsbeep.app.util.CustomTypeface;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.widget.TextView;

public class FontTextView extends TextView {

    public FontTextView(Context context) {
        super(context);
    }

    public FontTextView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    public FontTextView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attrs) {
        TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.FontTextView);
        int font = a.getInt(R.styleable.FontTextView_font, -1);
        a.recycle();

        if (font != -1 && !isInEditMode()) {
            setTypeface(CustomTypeface.getForValue(font).get(context));
        }
    }
}
