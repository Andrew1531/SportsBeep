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
import com.sportsbeep.app.ui.view.FontTextView;
import com.sportsbeep.app.util.GameViewHelper;

import android.content.Context;
import android.os.CountDownTimer;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import java.util.List;
import java.util.concurrent.TimeUnit;

import javax.inject.Inject;

import butterknife.ButterKnife;
import butterknife.InjectView;

public class UpcomingContestAdapter extends ArrayAdapter<Contest> {

    @Inject
    GameDaoHelper mGameDaoHelper;

    Sport mSport;

    Level mLevel;

    public UpcomingContestAdapter(Context context, Sport sport, Level level, List<Contest> objects) {
        super(context, 0, objects);
        GraphHolder.getInstance().inject(this);
        mSport = sport;
        mLevel = level;
    }

    private static long getMillisUntilStart(Game game) {
        return game.getStartTime().getTime() - System.currentTimeMillis();
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view = convertView;
        if (view == null) {
            view = LayoutInflater.from(getContext()).inflate(R.layout.item_upcoming_contest, parent, false);
            view.setTag(R.id.tag_holder, new Holder(view));
        }

        GameTask task = (GameTask) view.getTag(R.id.tag_task);
        if (task != null) {
            task.cancel(false);
        }

        Holder holder = (Holder) view.getTag(R.id.tag_holder);
        if (holder.timer != null) {
            holder.timer.cancel();
        }

        Contest contest = getItem(position);
        Game game = mGameDaoHelper.getGame(contest.getGame());
        if (game != null) {
            GameViewHelper.populateWithGame(game, holder.gameViewHolder);
            holder.timer = new ContestTimer(holder, getMillisUntilStart(game));
            holder.timer.start();
        } else {
            task = new GameTask(mSport, mLevel, contest.getTicket(), holder);
            task.execute(contest.getGame().getId());
            view.setTag(R.id.tag_task, task);
        }

        return view;
    }

    public static class GameTask extends NetworkAsyncTask<Long, Void, Game> {

        @Inject
        GameDaoHelper mGameDaoHelper;

        Sport mSport;

        Level mLevel;

        Ticket mTicket;

        Holder mHolder;

        public GameTask(Sport sport, Level level, Ticket ticket, Holder holder) {
            GraphHolder.getInstance().inject(this);
            mSport = sport;
            mLevel = level;
            mTicket = ticket;
            mHolder = holder;
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
            GameViewHelper.populateWithGame(game, mHolder.gameViewHolder);

            mHolder.timer = new ContestTimer(mHolder, getMillisUntilStart(game));
            mHolder.timer.start();
        }
    }

    private static class ContestTimer extends CountDownTimer {

        private final Holder mHolder;

        public ContestTimer(Holder holder, long millisInFuture) {
            super(millisInFuture, 1000);
            mHolder = holder;
        }

        @Override
        public void onTick(long millisUntilFinished) {
            long days = TimeUnit.MILLISECONDS.toDays(millisUntilFinished);
            long hours = TimeUnit.MILLISECONDS.toHours(millisUntilFinished) - TimeUnit.DAYS
                    .toHours(TimeUnit.MILLISECONDS.toDays(millisUntilFinished));
            long minutes = TimeUnit.MILLISECONDS.toMinutes(millisUntilFinished) - TimeUnit.HOURS
                    .toMinutes(TimeUnit.MILLISECONDS.toHours(millisUntilFinished));
            long seconds = TimeUnit.MILLISECONDS.toSeconds(millisUntilFinished) - TimeUnit.MINUTES
                    .toSeconds(TimeUnit.MILLISECONDS.toMinutes(millisUntilFinished));

            mHolder.daysFontTextView.setText(String.format("%02d", days));
            mHolder.hoursFontTextView.setText(String.format("%02d", hours));
            mHolder.minutesFontTextView.setText(String.format("%02d", minutes));
            mHolder.secondsFontTextView.setText(String.format("%02d", seconds));
        }

        @Override
        public void onFinish() {

        }
    }

    class Holder {

        final GameViewHelper.Holder gameViewHolder;

        @InjectView(R.id.days_FontTextView)
        FontTextView daysFontTextView;

        @InjectView(R.id.hours_FontTextView)
        FontTextView hoursFontTextView;

        @InjectView(R.id.minutes_FontTextView)
        FontTextView minutesFontTextView;

        @InjectView(R.id.seconds_FontTextView)
        FontTextView secondsFontTextView;

        CountDownTimer timer;

        public Holder(View v) {
            ButterKnife.inject(this, v);
            gameViewHolder = new GameViewHelper.Holder(v);
        }
    }
}
