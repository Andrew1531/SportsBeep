package com.sportsbeep.app.ui.game.buildteam;

import com.metova.slim.annotation.Callback;
import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.adapter.PlayersAdapter;
import com.sportsbeep.app.event.PlayersEvent;
import com.sportsbeep.app.model.game.GamePosition;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.storage.PlayerDaoHelper;
import com.sportsbeep.app.ui.base.BaseListFragment;
import com.sportsbeep.app.ui.view.FontTextView;
import com.sportsbeep.app.util.AnimUtil;
import com.squareup.otto.Subscribe;

import android.os.AsyncTask;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;

import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.List;
import java.util.Queue;

import javax.inject.Inject;

import butterknife.InjectView;
import butterknife.OnItemClick;
import butterknife.OnItemLongClick;

public class PickPlayerFragment extends BaseListFragment {

    private static final String EXTRA_GAME_POSITION = "game_position";

    private static final String EXTRA_GAME_ID = "game_id";

    private static final String EXTRA_HOME_TEAM_ID = "home_team_id";

    private static final String EXTRA_EXCLUDED_IDS = "excluded_ids";

    @InjectView(R.id.title_FontTextView)
    FontTextView mTitleFontTextView;

    @InjectView(android.R.id.progress)
    ProgressBar mProgressBar;

    @Extra(key = EXTRA_GAME_ID)
    long mGameId;

    @Extra(key = EXTRA_HOME_TEAM_ID)
    long mHomeTeamId;

    @Extra(key = EXTRA_GAME_POSITION)
    GamePosition mGamePosition;

    @Extra(key = EXTRA_EXCLUDED_IDS)
    long[] mExcludedIds;

    @Callback
    PickPlayerCallback mCallback;

    @Inject
    PlayerDaoHelper mPlayerDaoHelper;

    private PlayersTask mPlayersTask;

    public static PickPlayerFragment newInstance(long gameId, long homeTeamId, GamePosition gamePosition, long[] excludedIds) {
        PickPlayerFragment fragment = new PickPlayerFragment();

        Bundle args = new Bundle();
        args.putLong(EXTRA_GAME_ID, gameId);
        args.putLong(EXTRA_HOME_TEAM_ID, homeTeamId);
        args.putParcelable(EXTRA_GAME_POSITION, gamePosition);
        args.putLongArray(EXTRA_EXCLUDED_IDS, excludedIds);
        fragment.setArguments(args);

        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_pick_player, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mTitleFontTextView.setText(getString(R.string.pick_your_position, mGamePosition.getPositionGroupTitle(getActivity())));

        queryPlayers();
    }

    @Override
    public void onResume() {
        super.onResume();
        getBus().register(this);
    }

    @Override
    public void onPause() {
        super.onPause();
        getBus().unregister(this);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        if (mPlayersTask != null) {
            mPlayersTask.cancel(true);
        }
    }

    @OnItemClick(android.R.id.list)
    public void onPlayerClicked(int position) {
        Player player = (Player) getListAdapter().getItem(position);
        mCallback.onPlayerClicked(mGamePosition, player);
    }

    @OnItemLongClick(android.R.id.list)
    public boolean onPlayerLongClicked(int position) {
        Player player = (Player) getListAdapter().getItem(position);
        mCallback.onPlayerLongClicked(player);

        return true;
    }

    @Subscribe
    public void receivePlayers(PlayersEvent event) {
        queryPlayers();
    }

    private void queryPlayers() {
        if (mPlayersTask != null) {
            mPlayersTask.cancel(true);
        }

        mPlayersTask = new PlayersTask();
        mPlayersTask.execute();
    }

    private List<Player> alternateTeams(List<Player> players) {
        List<Player> alternatingPlayers = new ArrayList<Player>(players.size());
        Queue<Player> team1Queue = new ArrayDeque<Player>();
        Queue<Player> team2Queue = new ArrayDeque<Player>();

        String team1 = null;
        String team2 = null;

        for (Player player : players) {
            if (mHomeTeamId == 0) {
                mHomeTeamId = player.getTeam().getId();
            }

            String team = player.getTeam().getAbbr();
            if (team1 == null) {
                team1 = team;
            }

            if (team2 == null && !team.equals(team1)) {
                team2 = team;
            }

            if (alternatingPlayers.isEmpty()) {
                if (player.getTeam().getId() == mHomeTeamId) {
                    alternatingPlayers.add(player);
                } else {
                    team1Queue.add(player);
                }
            } else {
                String lastTeam = alternatingPlayers.get(alternatingPlayers.size() - 1).getTeam().getAbbr();
                if (!lastTeam.equals(team)) {
                    alternatingPlayers.add(player);
                    lastTeam = team;
                } else {
                    if (team.equals(team1)) {
                        team1Queue.add(player);
                    } else {
                        team2Queue.add(player);
                    }
                }

                boolean canPop = true;
                while (canPop) {
                    if (!team1Queue.isEmpty() && !team1.equals(lastTeam)) {
                        alternatingPlayers.add(team1Queue.remove());
                        lastTeam = team1;
                    } else if (!team2Queue.isEmpty() && !team2.equals(lastTeam)) {
                        alternatingPlayers.add(team2Queue.remove());
                        lastTeam = team2;
                    } else {
                        canPop = false;
                    }
                }
            }
        }

        // Unload the queues
        alternatingPlayers.addAll(team1Queue);
        alternatingPlayers.addAll(team2Queue);

        return alternatingPlayers;
    }

    public interface PickPlayerCallback {

        public void onPlayerClicked(GamePosition gamePosition, Player player);

        public void onPlayerLongClicked(Player player);
    }

    private class PlayersTask extends AsyncTask<Void, Void, List<Player>> {

        @Override
        protected List<Player> doInBackground(Void... params) {
            List<Player> players = mPlayerDaoHelper.getPlayersForPosition(mGameId, mGamePosition.getPositions(), mExcludedIds);
            return alternateTeams(players);
        }

        @Override
        protected void onPostExecute(List<Player> players) {
            super.onPostExecute(players);
            if (players != null && !players.isEmpty()) {
                setListAdapter(new PlayersAdapter(getActivity(), players));

                if (mProgressBar.getVisibility() == View.VISIBLE) {
                    AnimUtil.crossfade(mProgressBar, getListView());
                }
            }
        }
    }
}
