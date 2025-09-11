package com.sportsbeep.app.ui.game.pickgame;

import com.metova.slim.annotation.Callback;
import com.sportsbeep.app.R;
import com.sportsbeep.app.adapter.GamesAdapter;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.task.network.NetworkAsyncTask;
import com.sportsbeep.app.ui.base.BaseFragment;
import com.sportsbeep.app.util.AnimUtil;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.GridView;
import android.widget.ProgressBar;
import android.widget.TextView;

import java.util.List;

import butterknife.InjectView;
import butterknife.OnItemClick;

public class PickGameFragment extends BaseFragment {

    @InjectView(R.id.progress_ProgressBar)
    ProgressBar mProgressBar;

    @InjectView(R.id.games_GridView)
    GridView mGridView;

    @InjectView(R.id.empty_TextView)
    TextView mEmptyView;

    @Callback
    PickGameCallback mCallback;

    private GamesTask mGamesTask;

    public static PickGameFragment newInstance() {
        return new PickGameFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_pick_game, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mGamesTask = new GamesTask();
        mGamesTask.execute();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        if (mGamesTask != null) {
            mGamesTask.cancel(true);
        }
    }

    @OnItemClick(R.id.games_GridView)
    void onGameClicked(int position) {
        Game game = (Game) mGridView.getItemAtPosition(position);
        mCallback.onGameClicked(game);
    }

    public interface PickGameCallback {

        public void onGameClicked(Game game);
    }

    public class GamesTask extends NetworkAsyncTask<Void, Void, List<Game>> {

        @Override
        protected Result<List<Game>> doInBackground(Void... params) {
            return getClient().getGames(getSport(), getLevel());
        }

        @Override
        protected void onFinished() {
            super.onFinished();
            mGridView.setEmptyView(mEmptyView);
            AnimUtil.crossfade(mProgressBar, mGridView);
        }

        @Override
        protected void onSuccess(List<Game> gameList) {
            super.onSuccess(gameList);
            mGridView.setAdapter(new GamesAdapter(getActivity(), false, gameList));
        }
    }


}
