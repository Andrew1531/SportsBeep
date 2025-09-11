package com.sportsbeep.app.adapter;

import com.sportsbeep.app.R;
import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.contest.Contest;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.ticket.Ticket;
import com.sportsbeep.app.module.GraphHolder;
import com.sportsbeep.app.network.NetworkClient;
import com.sportsbeep.app.storage.GameDaoHelper;
import com.sportsbeep.app.task.network.NetworkAsyncTask;
import com.sportsbeep.app.util.ContestViewHelper;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import java.util.List;

import javax.inject.Inject;

public class LiveContestAdapter extends ArrayAdapter<Contest> {

    @Inject
    GameDaoHelper mGameDaoHelper;

    Sport mSport;

    Level mLevel;

    public LiveContestAdapter(Context context, Sport sport, Level level, List<Contest> objects) {
        super(context, 0, objects);
        GraphHolder.getInstance().inject(this);
        mSport = sport;
        mLevel = level;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view = convertView;
        if (view == null) {
            view = LayoutInflater.from(getContext()).inflate(R.layout.item_live_contest, parent, false);
            view.setTag(R.id.tag_holder, new ContestViewHelper.Holder(view));
        }

        GameTask task = (GameTask) view.getTag(R.id.tag_task);
        if (task != null) {
            task.cancel(false);
        }

        Contest contest = getItem(position);
        ContestViewHelper.Holder holder = (ContestViewHelper.Holder) view.getTag(R.id.tag_holder);

        ContestViewHelper.populateWithContest(getContext(), contest.getTicket(), holder);

        Game game = mGameDaoHelper.getGame(contest.getGame());
        if (game != null) {
            ContestViewHelper.populateWithGame(game, holder);
            ContestViewHelper.hideProgress(holder);

        } else {
            task = new GameTask(mSport, mLevel, contest.getTicket(), holder);
            task.execute(contest.getGame().getId());
            view.setTag(R.id.tag_task, task);
        }

        view.setTag(R.id.tag_task, task);

        return view;
    }

    public static class GameTask extends NetworkAsyncTask<Long, Void, Game> {

        @Inject
        GameDaoHelper mGameDaoHelper;

        Sport mSport;

        Level mLevel;

        Ticket mTicket;

        ContestViewHelper.Holder mHolder;

        public GameTask(Sport sport, Level level, Ticket ticket, ContestViewHelper.Holder holder) {
            GraphHolder.getInstance().inject(this);
            mSport = sport;
            mLevel = level;
            mTicket = ticket;
            mHolder = holder;
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            ContestViewHelper.showProgress(mHolder);
        }

        @Override
        protected Game queryData(Long... params) {
            long gameId = params[0];
            return mGameDaoHelper.getGame(gameId);
        }

        @Override
        protected Result<Game> downloadData(NetworkClient client, Long... params) {
            long gameId = params[0];
            return client.getGame(mSport, mLevel, gameId);
        }

        @Override
        protected void onSuccess(Game game) {
            super.onSuccess(game);
            ContestViewHelper.populateWithGame(game, mHolder);
        }
    }
}
