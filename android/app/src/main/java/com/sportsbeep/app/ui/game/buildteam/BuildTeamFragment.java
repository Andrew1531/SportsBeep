package com.sportsbeep.app.ui.game.buildteam;

import com.metova.slim.annotation.Callback;
import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.adapter.PositionsAdapter;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.game.GamePosition;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.ui.base.BaseListFragment;
import com.sportsbeep.app.util.AnimUtil;
import com.sportsbeep.app.util.GameViewHelper;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;

import java.util.Arrays;
import java.util.HashMap;

import butterknife.InjectView;
import butterknife.OnItemClick;

public class BuildTeamFragment extends BaseListFragment {

    private static final String EXTRA_GAME = "game";

    private static final String EXTRA_SHOW_PROGRESS = "show_progress";

    @InjectView(R.id.game_LinearLayout)
    View mGameView;

    @InjectView(android.R.id.progress)
    ProgressBar mProgressBar;

    @Extra(key = EXTRA_GAME)
    Game mGame;

    @Extra(key = EXTRA_SHOW_PROGRESS)
    boolean mShowProgress;

    @Callback
    BuildTeamCallback mCallback;

    private boolean mScrollToBottom;

    private boolean mSubmitButtonEnabled;

    public static BuildTeamFragment newInstance(Game game, boolean showProgress) {
        BuildTeamFragment fragment = new BuildTeamFragment();

        Bundle args = new Bundle();
        args.putParcelable(EXTRA_GAME, game);
        args.putBoolean(EXTRA_SHOW_PROGRESS, showProgress);
        fragment.setArguments(args);

        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_build_team, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        GameViewHelper.populateWithGame(mGame, new GameViewHelper.Holder(mGameView));

        View footerView = getActivity().getLayoutInflater().inflate(R.layout.footer_set_your_team, getListView(), false);
        View setYourTeamView = footerView.findViewById(R.id.setYourTeam_FontTextView);
        setYourTeamView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mCallback.onSubmitTeam();
            }
        });
        getListView().addFooterView(footerView, null, false);

        GamePosition[] gamePositions = getSport().getGamePositions();
        setListAdapter(new PositionsAdapter(getActivity(), Arrays.asList(gamePositions)));

        if (!mShowProgress) {
            mProgressBar.setVisibility(View.INVISIBLE);
            getListView().setVisibility(View.VISIBLE);
        }

        // Don't show progress on subsequent view creations
        mShowProgress = false;
        getArguments().putBoolean(EXTRA_SHOW_PROGRESS, false);

        if (mScrollToBottom) {
            getListView().setSelection(getListView().getCount() - 1);
            mScrollToBottom = false;
        }

        setSubmitButtonEnabled(mSubmitButtonEnabled);

        mCallback.onBuildTeamFragmentViewCreated();
    }

    @OnItemClick(android.R.id.list)
    public void OnGamePositionClicked(int position) {
        GamePosition gamePosition = (GamePosition) getListView().getItemAtPosition(position);
        if (gamePosition != null) {
            mCallback.onPositionClicked(gamePosition);
        }
    }

    @Override
    public PositionsAdapter getListAdapter() {
        if (super.getListAdapter() == null) {
            GamePosition[] gamePositions = getSport().getGamePositions();
            setListAdapter(new PositionsAdapter(getActivity(), Arrays.asList(gamePositions)));
        }

        return (PositionsAdapter) super.getListAdapter();
    }

    public void displayList() {
        AnimUtil.crossfade(mProgressBar, getListView());
    }

    public void setPosition(GamePosition gamePosition, Player player) {
        if (gamePosition.isSquad()) {
            throw new IllegalArgumentException("Game position expects a player, but got a squad.");
        }
        getListAdapter().setPosition(gamePosition, player);
    }

    public void setPosition(GamePosition gamePosition, Team team) {
        if (!gamePosition.isSquad() && !GamePosition.LEAGUE_PICK.equals(gamePosition)) {
            throw new IllegalArgumentException("Game position expects a squad, but got a player.");
        }
        getListAdapter().setPosition(gamePosition, team);
    }

    public void setPositionMap(HashMap<GamePosition, Object> playerMap) {
        getListAdapter().setPositionMap(playerMap);
    }

    public void setSubmitButtonEnabled(boolean enable) {
        mSubmitButtonEnabled = enable;
        if (getView() != null) {
            getListView().findViewById(R.id.setYourTeam_FontTextView).setEnabled(enable);
        }
    }

    public void scrollToBottom() {
        if (getView() != null) {
            getListView().setSelection(getListView().getCount() - 1);
        } else {
            mScrollToBottom = true;
        }
    }

    public interface BuildTeamCallback {

        public void onBuildTeamFragmentViewCreated();

        public void onPositionClicked(GamePosition gamePosition);

        public void onSubmitTeam();
    }
}
