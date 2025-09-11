package com.sportsbeep.app.ui.tutorial;

import com.sportsbeep.app.ui.base.BaseActivity;

import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;

public class HowToPlayActivity extends BaseActivity implements HowToPlayFragment.HowToPlayCallback {

    HowToPlayFragment mHowToPlayFragment;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState == null) {
            mHowToPlayFragment = HowToPlayFragment.newInstance();

            FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
            ft.add(android.R.id.content, mHowToPlayFragment);
            ft.commit();
        } else {
            mHowToPlayFragment = (HowToPlayFragment) getSupportFragmentManager().findFragmentById(android.R.id.content);
        }

        getPreferences().setTutorialViewed(true);
    }

    @Override
    public void onCloseClicked() {
        setResult(RESULT_OK);
        finish();
    }

    @Override
    public void onBackPressed() {
        if (!mHowToPlayFragment.onBackPressed()) {
            super.onBackPressed();
        }
    }
}
