package com.sportsbeep.app.ui.contest;

import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.ticket.IncompleteTicket;
import com.sportsbeep.app.model.ticket.Ticket;
import com.sportsbeep.app.network.params.ContestsParams;
import com.sportsbeep.app.ui.base.BaseNavigationActivity;
import com.sportsbeep.app.ui.contest.scoring.ScoringBreakdownActivity;
import com.sportsbeep.app.ui.game.buildteam.BuildTeamActivity;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;

public class ContestDetailsActivity extends BaseNavigationActivity implements ContestDetailsFragment.ContestDetailsCallback {

    public static final String EXTRA_CONTEST_ID = "contest_id";

    public static final String EXTRA_TICKET_ID = "ticket_id";

    public static final String EXTRA_GAME_ID = "game_id";

    public static final String EXTRA_CONTEST_STATUS = "contest_status";

    @Extra(key = EXTRA_CONTEST_ID)
    long mContestId;

    @Extra(key = EXTRA_TICKET_ID)
    long mMyTicketId;

    @Extra(key = EXTRA_GAME_ID)
    long mGameId;

    @Extra(key = EXTRA_CONTEST_STATUS)
    ContestsParams.ContestStatus mContestStatus;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState == null) {
            FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
            ft.add(R.id.content, ContestDetailsFragment.newInstance(mContestId, mMyTicketId, mGameId));
            ft.commit();
        }
    }

    @Override
    public void onTicketClicked(Ticket ticket, Game game) {
        if (mContestStatus == ContestsParams.ContestStatus.UPCOMING) {
            if (ticket.getId() == mMyTicketId) {
                editTicket(ticket, game);
            }
        } else {
            showScoringBreakdown(ticket, game);
        }
    }

    private void showScoringBreakdown(Ticket ticket, Game game) {
        Intent intent = new Intent(this, ScoringBreakdownActivity.class);
        intent.putExtra(ScoringBreakdownActivity.EXTRA_TICKET, ticket);
        intent.putExtra(ScoringBreakdownActivity.EXTRA_SCORE, ticket.getScore());
        intent.putExtra(ScoringBreakdownActivity.EXTRA_GAME, game);
        startActivity(intent);
    }

    private void editTicket(Ticket ticket, Game game) {
        Intent intent = new Intent(this, BuildTeamActivity.class);

        if (ticket.getLeaguePick() != null) {
            IncompleteTicket passedTicket = new IncompleteTicket();
            passedTicket.setGame(game);
            passedTicket.setLeaguePickTeam(ticket.getLeaguePick().getTeam());
            passedTicket.setLeaguePickGame(ticket.getLeaguePick().getGame());
            intent.putExtra(BuildTeamActivity.EXTRA_INCOMPLETE_TICKET, passedTicket);
        }

        intent.putExtra(BuildTeamActivity.EXTRA_TICKET_ID, ticket.getId());
        intent.putExtra(BuildTeamActivity.EXTRA_GAME, game);
        startActivity(intent);
    }
}
