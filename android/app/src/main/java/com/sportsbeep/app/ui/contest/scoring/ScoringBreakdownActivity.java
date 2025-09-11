package com.sportsbeep.app.ui.contest.scoring;

import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.game.GamePosition;
import com.sportsbeep.app.model.ticket.Ticket;
import com.sportsbeep.app.model.ticket.TicketPlayer;
import com.sportsbeep.app.model.ticket.TicketSquad;
import com.sportsbeep.app.ui.base.BaseNavigationActivity;

import android.content.Intent;
import android.os.Bundle;
import android.os.Parcelable;
import android.support.v4.app.FragmentTransaction;

import java.util.Timer;
import java.util.TimerTask;

public class ScoringBreakdownActivity extends BaseNavigationActivity implements ScoringBreakdownFragment.ScoringBreakdownCallback {

    public static final String EXTRA_TICKET = "ticket";

    public static final String EXTRA_GAME = "game";

    public static final String EXTRA_SCORE = "score";

    private static final long REFRESH_INTERVAL = 60000;

    @Extra(key = EXTRA_TICKET)
    Ticket mTicket;

    @Extra(key = EXTRA_GAME)
    Game mGame;

    @Extra(key = EXTRA_SCORE)
    String mScore;

    ScoringBreakdownFragment mScoringBreakdownFragment;

    Timer mTimer;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState == null) {
            mScoringBreakdownFragment = ScoringBreakdownFragment.newInstance(mTicket, mGame, mScore);

            FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
            ft.add(R.id.content, mScoringBreakdownFragment);
            ft.commit();
        } else {
            mScoringBreakdownFragment = (ScoringBreakdownFragment) getSupportFragmentManager().findFragmentById(R.id.content);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        startTimer();
    }

    @Override
    protected void onPause() {
        super.onPause();
        cancelTimer();
    }

    @Override
    public void onTicketPlayerClicked(TicketPlayer player) {
        Intent intent = new Intent(this, PlayerScoringActivity.class);
        intent.putExtra(PlayerScoringActivity.EXTRA_TICKET_ID, mTicket.getId());
        intent.putExtra(PlayerScoringActivity.EXTRA_TICKET_PLAYER, player);
        intent.putExtra(PlayerScoringActivity.EXTRA_GAME, mGame);
        startActivity(intent);
    }

    @Override
    public void onBestBustClicked(Ticket ticket) {
        Intent intent = new Intent(this, BestBustScoringActivity.class);
        intent.putExtra(BestBustScoringActivity.EXTRA_TICKET_ID, ticket.getId());
        intent.putExtra(BestBustScoringActivity.EXTRA_GAME, mGame);
        startActivity(intent);
    }

    @Override
    public void onTicketSquadClicked(GamePosition gamePosition, TicketSquad squad) {
        Intent intent = new Intent(this, SquadScoringActivity.class);
        intent.putExtra(SquadScoringActivity.EXTRA_TICKET_ID, mTicket.getId());
        intent.putExtra(SquadScoringActivity.EXTRA_TICKET_SQUAD, squad);
        intent.putExtra(SquadScoringActivity.EXTRA_GAME, mGame);
        intent.putExtra(SquadScoringActivity.EXTRA_GAME_POSITION, (Parcelable) gamePosition);
        startActivity(intent);
    }

    private void startTimer() {
        mTimer = new Timer();
        mTimer.schedule(new TimerTask() {
            @Override
            public void run() {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mScoringBreakdownFragment.refresh();
                    }
                });
            }
        }, 0, REFRESH_INTERVAL);
    }

    private void cancelTimer() {
        if (mTimer != null) {
            mTimer.cancel();
            mTimer = null;
        }
    }
}
