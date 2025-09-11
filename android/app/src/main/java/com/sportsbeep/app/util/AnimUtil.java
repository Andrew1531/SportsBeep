package com.sportsbeep.app.util;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.view.View;

public class AnimUtil {

    private static final int DURATION = 400;

    private AnimUtil() {
        // no-op
    }

    public static void fadeIn(final View view) {
        view.setAlpha(0f);
        view.setVisibility(View.VISIBLE);

        view.animate()
                .alpha(1f)
                .setDuration(DURATION)
                .setListener(null);
    }

    public static void fadeOut(final View view) {
        view.animate()
                .alpha(0f)
                .setDuration(DURATION)
                .setListener(new AnimatorListenerAdapter() {
                    @Override
                    public void onAnimationEnd(Animator animation) {
                        view.setVisibility(View.INVISIBLE);
                    }
                });
    }

    public static void crossfade(final View fadeOutView, final View fadeInView) {
        fadeIn(fadeInView);
        fadeOut(fadeOutView);
    }
}
