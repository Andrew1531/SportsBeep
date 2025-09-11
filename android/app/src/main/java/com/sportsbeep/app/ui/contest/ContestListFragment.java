package com.sportsbeep.app.ui.contest;

import com.metova.slim.annotation.Callback;
import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.adapter.LiveContestAdapter;
import com.sportsbeep.app.adapter.UpcomingContestAdapter;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.contest.Contest;
import com.sportsbeep.app.network.params.ContestsParams;
import com.sportsbeep.app.task.network.NetworkAsyncTask;
import com.sportsbeep.app.ui.base.BaseListFragment;

import android.os.Bundle;
import android.view.View;

import java.util.List;

import butterknife.OnItemClick;

public class ContestListFragment extends BaseListFragment {

    private static final String EXTRA_CONTEST_STATUS = "contest_status";

    @Callback
    ContestCallback mCallback;

    @Extra(key = EXTRA_CONTEST_STATUS)
    private ContestsParams.ContestStatus mContestStatus;

    private ContestTask mContestTask;

    public static ContestListFragment newInstance(ContestsParams.ContestStatus contestStatus) {
        ContestListFragment fragment = new ContestListFragment();

        Bundle args = new Bundle();
        args.putSerializable(EXTRA_CONTEST_STATUS, contestStatus);
        fragment.setArguments(args);

        return fragment;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        getListView().setDividerHeight(0);
        setEmptyText(getActivity().getString(R.string.no_contests));
    }

    @Override
    public void onResume() {
        super.onResume();
        mContestTask = new ContestTask();
        mContestTask.execute();
    }

    @Override
    public void onPause() {
        super.onPause();
        if (mContestTask != null) {
            mContestTask.cancel(true);
        }
    }

    @OnItemClick(android.R.id.list)
    void onContestClicked(int position) {
        Contest contest = (Contest) getListView().getItemAtPosition(position);
        mCallback.onContestClicked(contest, mContestStatus);
    }

    public interface ContestCallback {

        public void onContestClicked(Contest contest, ContestsParams.ContestStatus contestStatus);
    }

    public class ContestTask extends NetworkAsyncTask<Void, Void, List<Contest>> {

        @Override
        protected Result<List<Contest>> doInBackground(Void... params) {
            return getClient().getContests(getSport(), getLevel(), mContestStatus);
        }

        @Override
        protected void onError(String errorMessage) {
            super.onError(errorMessage);
            setListShown(true);
        }

        @Override
        protected void onSuccess(List<Contest> contests) {
            super.onSuccess(contests);

            switch (mContestStatus) {
                case LIVE:
                case PAST:
                    setListAdapter(new LiveContestAdapter(getActivity(), getSport(), getLevel(), contests));
                    break;
                case UPCOMING:
                    setListAdapter(new UpcomingContestAdapter(getActivity(), getSport(), getLevel(), contests));
                    break;
            }
        }
    }
}
