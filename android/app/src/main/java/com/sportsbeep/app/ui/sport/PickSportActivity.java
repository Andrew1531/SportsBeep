package com.sportsbeep.app.ui.sport;

import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.ui.base.BaseActivity;
import com.sportsbeep.app.ui.game.pickgame.PickGameActivity;
import com.sportsbeep.app.ui.tutorial.HowToPlayActivity;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;

import java.util.Arrays;
import java.util.List;

public class PickSportActivity extends BaseActivity implements PickSportFragment.PickSportCallback {

    public static final String EXTRA_ONBOARDING = "onboarding";

    private static final List<Sport> SPORT_WHITELIST = Arrays.asList(Sport.BASEBALL, Sport.FOOTBALL);

    @Extra(key = EXTRA_ONBOARDING, optional = true)
    boolean mOnboarding;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState == null) {
            FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
            ft.add(android.R.id.content, PickSportFragment.newInstance());
            ft.commit();
        }
    }

    @Override
    public void onEnterClicked(Level level, Sport sport) {
        // TODO: Allow other sports as they become available
        if (!SPORT_WHITELIST.contains(sport)) {
            sport = getPreferences().getSport();
            if (sport == null) {
                sport = SPORT_WHITELIST.get(0);
            }
        }
        getPreferences().setSport(sport);

        level = Level.PROFESSIONAL;
        getPreferences().setLevel(level);

        if (mOnboarding && !getPreferences().isTutorialViewed()) {
            Intent intent = new Intent(this, HowToPlayActivity.class);
            intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            startActivityForResult(intent, 0);
        } else {
            showPickGameScreen();
        }
    }

    private void showPickGameScreen() {
        Intent intent = new Intent(this, PickGameActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        showPickGameScreen();
    }
}
