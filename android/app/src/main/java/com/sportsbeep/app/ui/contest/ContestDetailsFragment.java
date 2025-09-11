package com.sportsbeep.app.ui.contest;

import com.metova.slim.annotation.Callback;
import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.adapter.TicketsAdapter;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.ticket.Ticket;
import com.sportsbeep.app.storage.GameDaoHelper;
import com.sportsbeep.app.task.network.NetworkAsyncTask;
import com.sportsbeep.app.ui.base.BaseListFragment;
import com.sportsbeep.app.util.AnimUtil;
import com.sportsbeep.app.util.ContestViewHelper;

import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ProgressBar;

import java.util.List;

import javax.inject.Inject;

import butterknife.InjectView;
import butterknife.OnItemClick;

public class ContestDetailsFragment extends BaseListFragment {

    public static final String EXTRA_CONTEST_ID = "contest_id";

    public static final String EXTRA_TICKET_ID = "ticket_id";

    public static final String EXTRA_GAME_ID = "game_id";

    @Extra(key = EXTRA_CONTEST_ID)
    long mContestId;

    @Extra(key = EXTRA_TICKET_ID)
    long mMyTicketId;

    @Extra(key = EXTRA_GAME_ID)
    long mGameId;

    @InjectView(R.id.contest_View)
    View mContestView;

    @InjectView(android.R.id.progress)
    ProgressBar mProgressBar;

    @InjectView(R.id.content_LinearLayout)
    LinearLayout mContentLinearLayout;

    @Inject
    GameDaoHelper mGameDaoHelper;

    @Callback
    ContestDetailsCallback mCallback;

    Game mGame;

    TicketsTask mTicketsTask;

    public static ContestDetailsFragment newInstance(long contestId, long ticketId, long gameId) {
        ContestDetailsFragment fragment = new ContestDetailsFragment();

        Bundle args = new Bundle();
        args.putLong(EXTRA_CONTEST_ID, contestId);
        args.putLong(EXTRA_TICKET_ID, ticketId);
        args.putLong(EXTRA_GAME_ID, gameId);
        fragment.setArguments(args);

        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_contest_details, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mGame = mGameDaoHelper.getGame(mGameId);
    }

    @Override
    public void onResume() {
        super.onResume();
        mTicketsTask = new TicketsTask(getDpiBucket());
        mTicketsTask.execute(mContestId);
    }

    @Override
    public void onPause() {
        super.onPause();
        cancelContestTask();
    }

    @OnItemClick(android.R.id.list)
    public void onTicketClicked(int position) {
        Ticket ticket = (Ticket) getListView().getItemAtPosition(position);
        mCallback.onTicketClicked(ticket, mGame);
    }

    private String getDpiBucket() {
        int densityDpi = getResources().getDisplayMetrics().densityDpi;
        switch (densityDpi) {
            case DisplayMetrics.DENSITY_MEDIUM:
                return "mdpi";
            case DisplayMetrics.DENSITY_HIGH:
                return "hdpi";
            case DisplayMetrics.DENSITY_XHIGH:
                return "xhdpi";
            case DisplayMetrics.DENSITY_XXHIGH:
                return "xxhdpi";
            case DisplayMetrics.DENSITY_XXXHIGH:
            default:
                return "xxxhdpi";
        }
    }

    private void cancelContestTask() {
        if (mTicketsTask != null) {
            mTicketsTask.cancel(true);
        }
    }

    private Ticket findTicketById(List<Ticket> tickets, long id) {
        for (Ticket ticket : tickets) {
            if (ticket.getId() == id) {
                return ticket;
            }
        }

        return null;
    }

    public interface ContestDetailsCallback {

        public void onTicketClicked(Ticket ticket, Game game);
    }

    public class TicketsTask extends NetworkAsyncTask<Long, Void, List<Ticket>> {

        private String mDpiBucket;

        public TicketsTask(String dpiBucket) {
            mDpiBucket = dpiBucket;
        }


        @Override
        protected Result<List<Ticket>> doInBackground(Long... params) {
            if (mGame == null) {
                getClient().getGame(getSport(), getLevel(), mGameId);
            }

            long contestId = params[0];
            return getClient().getTickets(getSport(), getLevel(), contestId, mDpiBucket);
        }

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            mProgressBar.setVisibility(View.VISIBLE);
        }

        @Override
        protected void onError(String errorMessage) {
            super.onError(errorMessage);
            getActivity().finish();
        }

        @Override
        protected void onSuccess(List<Ticket> tickets) {
            super.onSuccess(tickets);

            Ticket myTicket = findTicketById(tickets, mMyTicketId);

            if (mGame == null) {
                mGame = mGameDaoHelper.getGame(mGameId);
            }

            ContestViewHelper.Holder holder = new ContestViewHelper.Holder(mContestView);
            ContestViewHelper.populateWithContest(getActivity(), myTicket, holder);
            ContestViewHelper.populateWithGame(mGame, holder);

            setListAdapter(new TicketsAdapter(getActivity(), tickets));

            if (mContentLinearLayout.getVisibility() != View.VISIBLE) {
                AnimUtil.crossfade(mProgressBar, mContentLinearLayout);
            } else {
                AnimUtil.fadeOut(mProgressBar);
            }
        }
    }
}
