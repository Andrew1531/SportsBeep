package com.sportsbeep.app.ui.game.stats;

import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.ui.base.BaseNavigationActivity;

import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;

public class TeamStatsActivity extends BaseNavigationActivity {

    public static final String EXTRA_TEAM = "team";

    public static final String EXTRA_GAME = "game";

    @Extra(key = EXTRA_TEAM)
    Team mTeam;

    @Extra(key = EXTRA_GAME)
    Game mGame;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState == null) {
            FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
            ft.add(R.id.content, TeamStatsFragment.newInstance(mTeam, mGame));
            ft.commit();
        }
    }
}
