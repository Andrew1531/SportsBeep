package com.sportsbeep.app.ui.contest.scoring;

import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.ui.base.BaseNavigationActivity;

import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;

public class LeaguePickScoringActivity extends BaseNavigationActivity {

    public static final String EXTRA_TICKET_ID = "ticket_id";

    public static final String EXTRA_GAME = "game";

    @Extra(key = EXTRA_TICKET_ID)
    long mTicketId;

    @Extra(key = EXTRA_GAME)
    Game mGame;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState == null) {
            FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
            ft.add(R.id.content, LeaguePickScoringFragment.newInstance(mTicketId, mGame));
            ft.commit();
        }
    }
}
