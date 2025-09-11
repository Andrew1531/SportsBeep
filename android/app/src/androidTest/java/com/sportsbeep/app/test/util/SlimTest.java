package com.sportsbeep.app.test.util;

import com.metova.slim.Slim;
import com.metova.slim.annotation.Callback;
import com.metova.slim.internal.AnnotationUtil;

import junit.framework.TestCase;

import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;

public class SlimTest extends TestCase {

    public void testCallbackSuccess() {
        AnnotationTestFragment fragment = new AnnotationTestFragment();
        AnnotationTestGoodActivity activity = new AnnotationTestGoodActivity();

        try {
            Slim.injectCallbacks(fragment, activity);
        } catch (Exception e) {
            fail(e.getMessage());
        }

        assertNotNull(fragment.callback);
    }

    public void testCallbackFailure() {
        AnnotationTestFragment fragment = new AnnotationTestFragment();
        AnnotationTestBadActivity activity = new AnnotationTestBadActivity();

        try {
            Slim.injectCallbacks(fragment, activity);
        } catch (Exception e) {
            // pass
            return;
        }

        fail();
    }

    public static class AnnotationTestGoodActivity extends FragmentActivity
            implements AnnotationTestFragment.AnnotationTestCallback {

    }

    public static class AnnotationTestBadActivity extends FragmentActivity {

    }

    public static class AnnotationTestFragment extends Fragment {

        @Callback
        AnnotationTestCallback callback;

        public interface AnnotationTestCallback {

        }
    }
}
