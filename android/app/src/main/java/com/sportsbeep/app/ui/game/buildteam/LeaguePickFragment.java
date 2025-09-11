package com.sportsbeep.app.ui.game.buildteam;

import com.metova.slim.annotation.Callback;
import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.adapter.GamesAdapter;
import com.sportsbeep.app.event.LeaguePickEvent;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.ui.base.BaseListFragment;
import com.sportsbeep.app.ui.view.FontTextView;
import com.sportsbeep.app.util.AnimUtil;
import com.squareup.otto.Subscribe;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;

import java.util.ArrayList;
import java.util.List;

import butterknife.InjectView;

public class LeaguePickFragment extends BaseListFragment {

    private static final String EXTRA_GAMES = "games";

    @Extra(key = EXTRA_GAMES, optional = true)
    List<Game> mGames;

    @InjectView(android.R.id.progress)
    ProgressBar mProgressBar;

    @InjectView(R.id.leaguePickStat_FontTextView)
    FontTextView mLeaguePickStatFontTextView;

    @Callback
    LeaguePickCallback mCallback;

    public static LeaguePickFragment newInstance() {
        return new LeaguePickFragment();
    }

    public static LeaguePickFragment newInstance(ArrayList<Game> games) {
        LeaguePickFragment fragment = new LeaguePickFragment();

        Bundle args = new Bundle();
        args.putParcelableArrayList(EXTRA_GAMES, games);
        fragment.setArguments(args);

        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_league_pick, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        int resId;
        switch (getSport()) {
            case BASEBALL:
                resId = R.string.most_home_runs;
                break;
            case FOOTBALL:
                resId = R.string.most_touchdowns;
                break;
            default:
                throw new RuntimeException("Unsupported sport: " + getSport().name());
        }
        mLeaguePickStatFontTextView.setText(resId);

        if (mGames != null) {
            registerListAdapter();
        }
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

    @Subscribe
    public void receiveLeaguePicks(LeaguePickEvent event) {
        if (event.getGames() != null && !event.getGames().equals(mGames)) {
            mGames = event.getGames();
            registerListAdapter();
        }
    }

    private void registerListAdapter() {
        setListAdapter(new GamesAdapter(getActivity(), true, mGames,
                new GamesAdapter.OnTeamClickListener() {
                    @Override
                    public void onTeamClicked(Game game, Team team) {
                        mCallback.onLeaguePickSelected(game, team);
                    }

                    @Override
                    public void onTeamLongClicked(Game game, Team team) {
                        mCallback.onLeaguePickLongClicked(game, team);
                    }
                }
        ));

        if (mProgressBar.getVisibility() == View.VISIBLE) {
            AnimUtil.crossfade(mProgressBar, getListView());
        }
    }

    public interface LeaguePickCallback {

        public void onLeaguePickSelected(Game leaguePickGame, Team leaguePickTeam);

        public void onLeaguePickLongClicked(Game leaguePickGame, Team leaguePickTeam);
    }
}
