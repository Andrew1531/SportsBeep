package com.sportsbeep.app.test;

import com.robotium.solo.Solo;
import com.sportsbeep.app.module.GraphHolder;
import com.sportsbeep.app.network.NetworkClient;
import com.sportsbeep.app.test.module.TestModule;

import android.app.Activity;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.test.ActivityInstrumentationTestCase2;

import javax.inject.Inject;

public abstract class BaseActivityInstrumentationTestCase<T extends Activity, F extends Fragment>
        extends ActivityInstrumentationTestCase2<T> {

    @Inject
    NetworkClient mNetworkClient;

    private F mFragment;

    private Solo mSolo;

    public BaseActivityInstrumentationTestCase(Class<T> activityClass) {
        super(activityClass);
    }

    @Override
    protected void setUp() throws Exception {
        super.setUp();
        Object[] modules = getModules();
        if (modules != null) {
            GraphHolder.getInstance().addModules(new TestModule());
        }

        if (modules != null) {
            GraphHolder.getInstance().inject(this);
        }
    }

    @Override
    protected void tearDown() throws Exception {
        super.tearDown();
        getSolo().finishOpenedActivities();
    }

    int getContainerId() {
        return android.R.id.content;
    }

    Object[] getModules() {
        return new Object[]{new TestModule()};
    }

    protected F getFragment() {
        if (mFragment == null) {
            mFragment = (F) ((FragmentActivity) getActivity()).getSupportFragmentManager()
                    .findFragmentById(getContainerId());
        }
        return mFragment;
    }

    protected Solo getSolo() {
        if (mSolo == null) {
            mSolo = new Solo(getInstrumentation(), getActivity());
        }
        return mSolo;
    }

    protected NetworkClient getNetworkClient() {
        return mNetworkClient;
    }
}
