package com.sportsbeep.app.ui.contest.scoring;

import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.game.GamePosition;
import com.sportsbeep.app.model.ticket.TicketSquad;
import com.sportsbeep.app.ui.base.BaseNavigationActivity;

import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;

public class SquadScoringActivity extends BaseNavigationActivity {

    public static final String EXTRA_TICKET_ID = "ticket_id";

    public static final String EXTRA_TICKET_SQUAD = "ticket_squad";

    public static final String EXTRA_GAME = "game";

    public static final String EXTRA_GAME_POSITION = "game_position";

    @Extra(key = EXTRA_TICKET_ID)
    long mTicketId;

    @Extra(key = EXTRA_TICKET_SQUAD)
    TicketSquad mTicketSquad;

    @Extra(key = EXTRA_GAME)
    Game mGame;

    @Extra(key = EXTRA_GAME_POSITION)
    GamePosition mGamePosition;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState == null) {
            FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
            ft.add(R.id.content, SquadScoringFragment.newInstance(mTicketId, mTicketSquad, mGame, mGamePosition));
            ft.commit();
        }
    }
}
