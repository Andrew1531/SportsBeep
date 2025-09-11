package com.sportsbeep.app.ui.contest.scoring;

import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.model.ticket.TicketLeaguePick;
import com.sportsbeep.app.task.network.GameAsyncTask;
import com.sportsbeep.app.task.network.TeamAsyncTask;
import com.sportsbeep.app.task.network.TicketLeaguePickAsyncTask;
import com.sportsbeep.app.ui.base.BaseFragment;
import com.sportsbeep.app.ui.view.FontTextView;
import com.sportsbeep.app.util.AnimUtil;
import com.sportsbeep.app.util.DateFormatUtils;
import com.sportsbeep.app.util.GameViewHelper;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.ScrollView;

import butterknife.InjectView;

public class LeaguePickScoringFragment extends BaseFragment {

    public static final String EXTRA_TICKET_ID = "ticket_id";

    public static final String EXTRA_GAME = "game";

    @Extra(key = EXTRA_TICKET_ID)
    long mTicketId;

    @Extra(key = EXTRA_GAME)
    Game mGame;

    @InjectView(R.id.scrollView)
    ScrollView mScrollView;

    @InjectView(android.R.id.progress)
    ProgressBar mProgressBar;

    @InjectView(R.id.gameTime_FontTextView)
    FontTextView mTimeFontTextView;

    @InjectView(R.id.gameDate_FontTextView)
    FontTextView mDateFontTextView;

    @InjectView(R.id.team_LinearLayout)
    LinearLayout mTeamLinearLayout;

    @InjectView(R.id.teamMarket_FontTextView)
    FontTextView mTeamMarketFontTextView;

    @InjectView(R.id.teamName_FontTextView)
    FontTextView mTeamNameFontTextView;

    @InjectView(R.id.winLoss_FontTextView)
    FontTextView mWinLossFontTextView;

    @InjectView(R.id.homeRunsText_FontTextView)
    FontTextView mHomeRunsTextFontTextView;

    @InjectView(R.id.homeRuns_FontTextView)
    FontTextView mHomeRunsFontTextView;

    @InjectView(R.id.pointsText_FontTextView)
    FontTextView mPointsTextFontTextView;

    @InjectView(R.id.points_FontTextView)
    FontTextView mPointsFontTextView;

    @InjectView(R.id.homeRunsByText_FontTextView)
    FontTextView mHomeRunsByTextFontTextView;

    @InjectView(R.id.homeRunsBy_FontTextView)
    FontTextView mHomeRunsByFontTextView;

    @InjectView(R.id.game_LinearLayout)
    View mGameView;

    TicketLeaguePickTask mTicketLeaguePickTask;

    GameTask mGameTask;

    TeamTask mTeamTask;

    public static LeaguePickScoringFragment newInstance(long ticketId, Game game) {
        LeaguePickScoringFragment fragment = new LeaguePickScoringFragment();

        Bundle args = new Bundle();
        args.putLong(EXTRA_TICKET_ID, ticketId);
        args.putParcelable(EXTRA_GAME, game);
        fragment.setArguments(args);

        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_league_pick_scoring, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        GameViewHelper.populateWithGame(mGame, new GameViewHelper.Holder(mGameView));

        mTicketLeaguePickTask = new TicketLeaguePickTask(getSport(), getLevel());
        mTicketLeaguePickTask.execute(mTicketId);
    }

    @Override
    public void onDestroyView() {
        if (mTicketLeaguePickTask != null) {
            mTicketLeaguePickTask.cancel(true);
        }

        if (mGameTask != null) {
            mGameTask.cancel(true);
        }

        if (mTeamTask != null) {
            mTeamTask.cancel(true);
        }

        super.onDestroyView();
    }

    private void populateView(TicketLeaguePick ticketLeaguePick) {
        Game game = ticketLeaguePick.getGame();
        mDateFontTextView.setText(DateFormatUtils.getDateFormat().format(game.getStartTime()));
        mTimeFontTextView.setText(DateFormatUtils.getTimeFormat().format(game.getStartTime()));

        Team team = ticketLeaguePick.getTeam();
        mTeamLinearLayout.setBackgroundColor(team.getPrimaryColor());
        mTeamMarketFontTextView.setText(team.getMarket());
        mTeamNameFontTextView.setText(team.getName());
        mTeamNameFontTextView.setTextColor(team.getSecondaryColor());
        mWinLossFontTextView.setText("(" + getString(R.string.wins_losses_stat, team.getWins(), team.getLosses()) + ")");
        mHomeRunsTextFontTextView.setBackgroundColor(team.getPrimaryColor());
        mHomeRunsTextFontTextView.setTextColor(team.getSecondaryColor());
        mPointsTextFontTextView.setBackgroundColor(team.getPrimaryColor());
        mPointsTextFontTextView.setTextColor(team.getSecondaryColor());
        mHomeRunsByTextFontTextView.setBackgroundColor(team.getPrimaryColor());
        mHomeRunsByTextFontTextView.setTextColor(team.getSecondaryColor());

        mHomeRunsFontTextView.setText(ticketLeaguePick.getAmount());
        mPointsFontTextView.setText(ticketLeaguePick.getScore());

        StringBuilder sb = new StringBuilder();
        for (TicketLeaguePick.Scorer scorer : ticketLeaguePick.getScorers()) {
            if (sb.length() > 0) {
                sb.append(", ");
            }
            sb.append(getString(R.string.home_run_player, scorer.getName(), scorer.getSeasonTotal()));
        }
        mHomeRunsByFontTextView.setText(sb.toString());
    }

    public class TicketLeaguePickTask extends TicketLeaguePickAsyncTask {

        public TicketLeaguePickTask(Sport sport, Level level) {
            super(sport, level);
        }

        @Override
        protected void onSuccess(TicketLeaguePick ticketLeaguePick) {
            super.onSuccess(ticketLeaguePick);
            mGameTask = new GameTask(getSport(), getLevel(), ticketLeaguePick);
            mGameTask.execute(ticketLeaguePick.getGame().getId());
        }
    }

    public class GameTask extends GameAsyncTask {

        TicketLeaguePick mTicketLeaguePick;

        public GameTask(Sport sport, Level level, TicketLeaguePick ticketLeaguePick) {
            super(sport, level);
            mTicketLeaguePick = ticketLeaguePick;
        }

        @Override
        protected void onSuccess(Game game) {
            super.onSuccess(game);
            mTicketLeaguePick.setGame(game);

            mTeamTask = new TeamTask(getSport(), getLevel(), mTicketLeaguePick);
            mTeamTask.execute(mTicketLeaguePick.getTeam().getId());
        }
    }

    public class TeamTask extends TeamAsyncTask {

        TicketLeaguePick mTicketLeaguePick;

        public TeamTask(Sport sport, Level level, TicketLeaguePick ticketLeaguePick) {
            super(sport, level);
            mTicketLeaguePick = ticketLeaguePick;
        }

        @Override
        protected void onSuccess(Team team) {
            super.onSuccess(team);
            mTicketLeaguePick.setTeam(team);
            populateView(mTicketLeaguePick);
            AnimUtil.crossfade(mProgressBar, mScrollView);
        }
    }
}
