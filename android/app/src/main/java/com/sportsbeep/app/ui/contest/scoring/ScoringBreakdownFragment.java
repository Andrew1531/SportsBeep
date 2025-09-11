package com.sportsbeep.app.ui.contest.scoring;

import com.metova.slim.annotation.Callback;
import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.adapter.ScoringBreakdownAdapter;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.game.GamePosition;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.model.ticket.Ticket;
import com.sportsbeep.app.model.ticket.TicketPlayer;
import com.sportsbeep.app.model.ticket.TicketPositions;
import com.sportsbeep.app.model.ticket.TicketSquad;
import com.sportsbeep.app.storage.TeamDaoHelper;
import com.sportsbeep.app.task.network.NetworkAsyncTask;
import com.sportsbeep.app.ui.base.BaseListFragment;
import com.sportsbeep.app.ui.view.FontTextView;
import com.sportsbeep.app.util.AnimUtil;
import com.sportsbeep.app.util.GameViewHelper;
import com.sportsbeep.app.util.PositionViewHelper;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;

import java.util.List;

import javax.inject.Inject;

import butterknife.InjectView;
import butterknife.OnItemClick;

public class ScoringBreakdownFragment extends BaseListFragment {

    public static final String EXTRA_TICKET = "ticket";

    public static final String EXTRA_GAME = "game";

    public static final String EXTRA_SCORE = "score";

    @Extra(key = EXTRA_TICKET)
    Ticket mTicket;

    @Extra(key = EXTRA_GAME)
    Game mGame;

    @Extra(key = EXTRA_SCORE)
    String mScore;

    @InjectView(android.R.id.progress)
    ProgressBar mProgressBar;

    @InjectView(R.id.points_FontTextView)
    FontTextView mPointsFontTextView;

    @InjectView(R.id.game_LinearLayout)
    View mGameView;

    View mBestBustFooterView;

    View mTeamFooterView;

    List<TicketPlayer> mPlayers;

    List<TicketSquad> mSquads;

    @Callback
    ScoringBreakdownCallback mCallback;

    @Inject
    TeamDaoHelper mTeamDaoHelper;

    DownloadTicketPlayersTask mDownloadTicketTask;

    boolean mPlayersCached;

    public static ScoringBreakdownFragment newInstance(Ticket ticket, Game game, String score) {
        ScoringBreakdownFragment fragment = new ScoringBreakdownFragment();

        Bundle args = new Bundle();
        args.putParcelable(EXTRA_TICKET, ticket);
        args.putParcelable(EXTRA_GAME, game);
        args.putString(EXTRA_SCORE, score);
        fragment.setArguments(args);

        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_scoring_breakdown, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        GameViewHelper.populateWithGame(mGame, new GameViewHelper.Holder(mGameView));
        mPointsFontTextView.setText(getString(R.string.points, mScore));
    }

    @Override
    public void onResume() {
        super.onResume();
        refresh();
    }

    @Override
    public void onPause() {
        super.onPause();
        if (mDownloadTicketTask != null) {
            mDownloadTicketTask.cancel(true);
        }
    }

    @OnItemClick(android.R.id.list)
    public void onPlayerClicked(int position) {
        Object item = getListView().getItemAtPosition(position);
        if (item != null) {
            if (item instanceof GamePosition) {
                GamePosition gamePosition = (GamePosition) item;
                TicketPlayer player = getTicketPlayerForPosition(gamePosition);
                if (player != null) {
                    mCallback.onTicketPlayerClicked(player);
                } else {
                    TicketSquad squad = getTicketSquadForPosition(gamePosition);
                    if (squad != null) {
                        mCallback.onTicketSquadClicked(gamePosition, squad);
                    }
                }
            } else if (item instanceof BestBustPayload) {
                mCallback.onBestBustClicked(((BestBustPayload) item).ticket);
            }
        }
    }

    private TicketPlayer getTicketPlayerForPosition(GamePosition position) {
        for (TicketPlayer ticketPlayer : mPlayers) {
            if (position.getPositionGroupTitleResName().equals(ticketPlayer.getGamePosition())) {
                return ticketPlayer;
            }
        }

        return null;
    }

    private TicketSquad getTicketSquadForPosition(GamePosition position) {
        for (TicketSquad ticketSquad : mSquads) {
            if (position.getPositionGroupTitleResName().equals(ticketSquad.getGamePosition())) {
                return ticketSquad;
            }
        }

        return null;
    }

    private View createBestBustFooterView(String score) {
        View bestBustView = LayoutInflater.from(getActivity()).inflate(R.layout.item_ticket_best_bust, getListView(), false);
        updateBestBustFooterView(bestBustView, score);

        return bestBustView;
    }

    private void updateBestBustFooterView(View view, String score) {
        FontTextView pointsFontTextView = (FontTextView) view.findViewById(R.id.points_FontTextView);
        pointsFontTextView.setText(score);
    }

    private View createTeamFooterView(Team team, String score) {
        View teamView = LayoutInflater.from(getActivity()).inflate(R.layout.item_ticket_team, getListView(), false);
        updateTeamFooterView(teamView, team, score);

        return teamView;
    }

    private void updateTeamFooterView(View view, Team team, String score) {
        PositionViewHelper.Holder holder = new PositionViewHelper.Holder(view);
        PositionViewHelper.populateWithTeam(holder, team);

        FontTextView teamPointsFontTextView = (FontTextView) view.findViewById(R.id.teamPoints_FontTextView);
        teamPointsFontTextView.setText(score);
    }

    public void refresh() {
        if (mDownloadTicketTask != null) {
            mDownloadTicketTask.cancel(true);
        }

        mDownloadTicketTask = new DownloadTicketPlayersTask();
        mDownloadTicketTask.execute(mTicket.getId());
    }

    public interface ScoringBreakdownCallback {

        public void onTicketPlayerClicked(TicketPlayer player);

        public void onTicketSquadClicked(GamePosition gamePosition, TicketSquad squad);

        public void onBestBustClicked(Ticket ticket);
    }

    public class DownloadTicketPlayersTask extends NetworkAsyncTask<Long, Void, TicketPositions> {

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            mProgressBar.setVisibility(View.VISIBLE);
            mProgressBar.setAlpha(1);
        }

        @Override
        protected Result<TicketPositions> doInBackground(Long... params) {
            long ticketId = params[0];
            Result<TicketPositions> result = getClient().getPositionsForTicket(getSport(), getLevel(), ticketId);

            if (result.getException() == null) {
                if (!mPlayersCached) {
                    getClient().getPlayersForGame(getSport(), getLevel(), mGame.getId());
                    mPlayersCached = true;
                }

                if (mTicket.getLeaguePick() != null) {
                    Team team = mTeamDaoHelper.getTeam(mTicket.getLeaguePick().getTeam().getId());
                    if (team == null) {
                        getClient().getTeams(getSport(), getLevel());
                    }
                }
            }

            return result;
        }

        @Override
        protected void onSuccess(TicketPositions positions) {
            super.onSuccess(positions);
            if (mTicket.getLeaguePick() != null) {
                Team team = mTeamDaoHelper.getTeam(mTicket.getLeaguePick().getTeam().getId());
                if (mTeamFooterView == null) {
                    mTeamFooterView = createTeamFooterView(team, mTicket.getLeaguePick().getScore());
                    getListView().addFooterView(mTeamFooterView);
                } else {
                    updateTeamFooterView(mTeamFooterView, team, mTicket.getLeaguePick().getScore());
                }
            }

            if (mBestBustFooterView == null) {
                mBestBustFooterView = createBestBustFooterView(mTicket.getBestOrBustScore());
                getListView().addFooterView(mBestBustFooterView, new BestBustPayload(mTicket), true);
            } else {
                updateBestBustFooterView(mBestBustFooterView, mTicket.getBestOrBustScore());
            }

            mPlayers = positions.getPlayers();
            mSquads = positions.getSquads();
            setListAdapter(new ScoringBreakdownAdapter(mPlayers, mSquads, getSport(), getLevel()));

            if (getListView().getVisibility() != View.VISIBLE) {
                AnimUtil.crossfade(mProgressBar, getListView());
            } else {
                AnimUtil.fadeOut(mProgressBar);
            }
        }
    }

    private class BestBustPayload {

        public Ticket ticket;

        public BestBustPayload(Ticket ticket) {
            this.ticket = ticket;
        }
    }
}
