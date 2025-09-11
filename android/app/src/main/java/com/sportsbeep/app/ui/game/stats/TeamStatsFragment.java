package com.sportsbeep.app.ui.game.stats;

import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.adapter.TeamRankingsAdapter;
import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.model.team.TeamRanking;
import com.sportsbeep.app.task.network.TeamRankingsAsyncTask;
import com.sportsbeep.app.ui.base.BaseFragment;
import com.sportsbeep.app.ui.view.FontTextView;
import com.sportsbeep.app.util.AnimUtil;
import com.sportsbeep.app.util.DateFormatUtils;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.GridView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;

import java.util.Date;
import java.util.List;

import butterknife.InjectView;

public class TeamStatsFragment extends BaseFragment {

    public static final String EXTRA_TEAM = "team";

    public static final String EXTRA_GAME = "game";

    @Extra(key = EXTRA_TEAM)
    Team mTeam;

    @Extra(key = EXTRA_GAME)
    Game mGame;

    @InjectView(R.id.rankings_GridView)
    GridView mRankingsGridView;

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

    TeamRankingsTask mTeamRankingsTask;

    public static TeamStatsFragment newInstance(Team team, Game game) {
        TeamStatsFragment fragment = new TeamStatsFragment();

        Bundle args = new Bundle();
        args.putParcelable(EXTRA_TEAM, team);
        if(game != null) {
            args.putParcelable(EXTRA_GAME, game);
        }
        fragment.setArguments(args);

        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_team_stats, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        populateTeamView(mGame.getStartTime(), mTeam);

        mTeamRankingsTask = new TeamRankingsTask(getSport(), getLevel());
        mTeamRankingsTask.execute(mTeam.getId());
    }

    @Override
    public void onDestroyView() {
        if (mTeamRankingsTask != null) {
            mTeamRankingsTask.cancel(true);
        }
        super.onDestroyView();
    }

    private void populateTeamView(Date startTime, Team team) {
        mDateFontTextView.setText(DateFormatUtils.getDateFormat().format(startTime));
        mTimeFontTextView.setText(DateFormatUtils.getTimeFormat().format(startTime));

        mTeamLinearLayout.setBackgroundColor(team.getPrimaryColor());
        mTeamMarketFontTextView.setText(team.getMarket());
        mTeamNameFontTextView.setText(team.getName());
        mTeamNameFontTextView.setTextColor(team.getSecondaryColor());
        mWinLossFontTextView.setText("(" + getString(R.string.wins_losses_stat, team.getWins(), team.getLosses()) + ")");
    }

    public class TeamRankingsTask extends TeamRankingsAsyncTask {

        public TeamRankingsTask(Sport sport, Level level) {
            super(sport, level);
        }

        @Override
        protected void onSuccess(List<TeamRanking> teamRankings) {
            super.onSuccess(teamRankings);
            mRankingsGridView.setAdapter(new TeamRankingsAdapter(getActivity(), mTeam, teamRankings));
            AnimUtil.crossfade(mProgressBar, mRankingsGridView);
        }
    }
}
