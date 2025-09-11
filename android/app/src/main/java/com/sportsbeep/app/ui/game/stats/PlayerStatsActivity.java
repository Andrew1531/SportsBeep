package com.sportsbeep.app.ui.game.stats;

import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.ui.base.BaseNavigationActivity;

import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;

public class PlayerStatsActivity extends BaseNavigationActivity {

    public static final String EXTRA_PLAYER = "player";

    @Extra(key = EXTRA_PLAYER)
    Player mPlayer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState == null) {
            FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
            ft.add(R.id.content, PlayerStatsFragment.newInstance(mPlayer));
            ft.commit();
        }
    }
}
