package com.sportsbeep.app.ui.view;

import com.sportsbeep.app.R;
import com.sportsbeep.app.util.CustomTypeface;

import android.content.Context;
import android.content.res.TypedArray;
import android.util.AttributeSet;
import android.widget.RadioButton;

public class FontRadioButton extends RadioButton {

    public FontRadioButton(Context context) {
        super(context);
    }

    public FontRadioButton(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    public FontRadioButton(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attrs) {
        TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.FontRadioButton);
        int font = a.getInt(R.styleable.FontRadioButton_font, 0);
        a.recycle();

        if (!isInEditMode()) {
            setTypeface(CustomTypeface.getForValue(font).get(context));
        }
    }
}
