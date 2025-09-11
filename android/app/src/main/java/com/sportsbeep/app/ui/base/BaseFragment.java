package com.sportsbeep.app.ui.base;

import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.storage.PreferenceHelper;
import com.squareup.otto.Bus;

import android.app.Activity;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.View;

public abstract class BaseFragment extends Fragment {

    private final BaseFragmentImpl mImpl = new BaseFragmentImpl(this);

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mImpl.onCreate(savedInstanceState);
    }

    @Override
    public void onAttach(Activity activity) {
        super.onAttach(activity);
        mImpl.onAttach(activity);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mImpl.onViewCreated(view, savedInstanceState);
    }

    public PreferenceHelper getPreferences() {
        return mImpl.getPreferences();
    }

    public Bus getBus() {
        return mImpl.getBus();
    }

    public Sport getSport() {
        return mImpl.getSport();
    }

    public Level getLevel() {
        return mImpl.getLevel();
    }
}
