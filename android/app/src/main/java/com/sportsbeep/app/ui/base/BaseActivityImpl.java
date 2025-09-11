package com.sportsbeep.app.ui.base;

import com.google.android.gms.analytics.GoogleAnalytics;
import com.google.android.gms.analytics.Tracker;

import com.metova.slim.Slim;
import com.sportsbeep.app.R;
import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.module.GraphHolder;
import com.sportsbeep.app.storage.PreferenceHelper;
import com.squareup.otto.Bus;

import android.os.Bundle;
import android.support.v4.app.FragmentActivity;

import javax.inject.Inject;

public class BaseActivityImpl {

    private final FragmentActivity mActivity;

    @Inject
    GoogleAnalytics mGoogleAnalytics;

    Tracker mTracker;

    @Inject
    PreferenceHelper mPreferenceHelper;

    @Inject
    Bus mBus;

    @Inject
    Sport mSport;

    @Inject
    Level mLevel;

    BaseActivityImpl(FragmentActivity activity) {
        mActivity = activity;
        GraphHolder.getInstance().inject(this);
    }

    void onCreate(Bundle savedInstanceState) {
        GraphHolder.getInstance().inject(mActivity);
        Slim.injectExtras(mActivity.getIntent().getExtras(), mActivity);
    }

    void onStart() {
        mTracker = mGoogleAnalytics.newTracker(R.xml.app_tracker);
        mGoogleAnalytics.reportActivityStart(mActivity);
    }

    void onStop() {
        mGoogleAnalytics.reportActivityStop(mActivity);
    }

    public int getSportTheme() {
        if (mSport == null) {
            return R.style.DefaultTheme;
        }

        switch (mSport) {
            case BASEBALL:
                return R.style.BaseballTheme;
            case FOOTBALL:
                return R.style.FootballTheme;
            default:
                return R.style.DefaultTheme;
        }
    }

    public PreferenceHelper getPreferences() {
        return mPreferenceHelper;
    }

    public Bus getBus() {
        return mBus;
    }

    public Sport getSport() {
        return mSport;
    }

    public Level getLevel() {
        return mLevel;
    }

    public Tracker getTracker() {
        return mTracker;
    }
}
