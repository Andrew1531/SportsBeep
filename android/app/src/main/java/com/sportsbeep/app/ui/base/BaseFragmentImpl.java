package com.sportsbeep.app.ui.base;

import com.metova.slim.Slim;
import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.module.GraphHolder;
import com.sportsbeep.app.storage.PreferenceHelper;
import com.squareup.otto.Bus;

import android.app.Activity;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.View;

import javax.inject.Inject;

import butterknife.ButterKnife;

public class BaseFragmentImpl {

    private final Fragment mFragment;

    @Inject
    PreferenceHelper mPreferenceHelper;

    @Inject
    Bus mBus;

    @Inject
    Sport mSport;

    @Inject
    Level mLevel;

    BaseFragmentImpl(Fragment fragment) {
        mFragment = fragment;
        GraphHolder.getInstance().inject(this);
    }

    public void onAttach(Activity activity) {
        GraphHolder.getInstance().inject(mFragment);
        Slim.injectCallbacks(mFragment);
    }

    public void onCreate(Bundle savedInstanceState) {
        Slim.injectExtras(mFragment.getArguments(), mFragment);
    }

    public void onViewCreated(View view, Bundle savedInstanceState) {
        ButterKnife.inject(mFragment, view);
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
}
