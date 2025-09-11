package com.sportsbeep.app.ui.base;

import com.google.android.gms.analytics.Tracker;

import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.storage.PreferenceHelper;
import com.squareup.otto.Bus;

import android.os.Bundle;
import android.support.v4.app.FragmentActivity;

public abstract class BaseActivity extends FragmentActivity {

    private final BaseActivityImpl mImpl = new BaseActivityImpl(this);

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        setTheme(mImpl.getSportTheme());
        super.onCreate(savedInstanceState);
        mImpl.onCreate(savedInstanceState);
    }

    @Override
    protected void onStart() {
        super.onStart();
        mImpl.onStart();
    }

    @Override
    protected void onStop() {
        super.onStop();
        mImpl.onStop();
    }

    protected PreferenceHelper getPreferences() {
        return mImpl.getPreferences();
    }

    protected Bus getBus() {
        return mImpl.getBus();
    }

    public Sport getSport() {
        return mImpl.getSport();
    }

    public Level getLevel() {
        return mImpl.getLevel();
    }

    public Tracker getTracker() {
        return mImpl.getTracker();
    }
}
