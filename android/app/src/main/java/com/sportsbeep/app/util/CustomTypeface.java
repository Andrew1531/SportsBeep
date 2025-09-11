package com.sportsbeep.app.util;

import android.content.Context;
import android.graphics.Typeface;

import java.util.HashMap;
import java.util.Map;

public enum CustomTypeface {

    ROBOTO(null, 0),
    BEBAS_NEUE("fonts/bebas_neue.otf", 1);

    private final String mPath;

    private final int mValue;

    private final Map<CustomTypeface, Typeface> mMap = new HashMap<CustomTypeface, Typeface>();

    CustomTypeface(String path, int value) {
        mPath = path;
        mValue = value;
    }

    public static CustomTypeface getForValue(int value) {
        CustomTypeface[] typefaces = values();
        for (CustomTypeface typeface : typefaces) {
            if (typeface.mValue == value) {
                return typeface;
            }
        }

        throw new IllegalArgumentException(
                "Value '" + value + "' does not exist in " + CustomTypeface.class.getSimpleName());
    }

    public Typeface get(Context context) {
        if (this == ROBOTO) {
            return null;
        }

        if (!mMap.containsKey(this)) {
            Typeface typeface = Typeface.createFromAsset(context.getAssets(), mPath);
            mMap.put(this, typeface);
        }

        return mMap.get(this);
    }
}
