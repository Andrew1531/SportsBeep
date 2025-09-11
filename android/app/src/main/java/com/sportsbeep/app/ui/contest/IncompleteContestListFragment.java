package com.sportsbeep.app.ui.contest;

import com.metova.slim.annotation.Callback;
import com.sportsbeep.app.R;
import com.sportsbeep.app.adapter.IncompleteContestAdapter;
import com.sportsbeep.app.model.ticket.IncompleteTicket;
import com.sportsbeep.app.storage.IncompleteTicketDaoHelper;
import com.sportsbeep.app.ui.base.BaseListFragment;

import android.os.AsyncTask;
import android.os.Bundle;
import android.util.Log;
import android.view.View;

import java.util.Date;
import java.util.List;

import javax.inject.Inject;

import butterknife.OnItemClick;

public class IncompleteContestListFragment extends BaseListFragment {

    private static final String TAG = IncompleteContestListFragment.class.getSimpleName();

    @Inject
    IncompleteTicketDaoHelper mIncompleteTicketDaoHelper;

    @Callback
    IncompleteContestCallback mCallback;

    private IncompleteTicketTask mIncompleteTicketTask;

    public static IncompleteContestListFragment newInstance() {
        return new IncompleteContestListFragment();
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        getListView().setDividerHeight(0);
        setEmptyText(getActivity().getString(R.string.no_contests));

        mIncompleteTicketTask = new IncompleteTicketTask();
        mIncompleteTicketTask.execute();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (mIncompleteTicketTask != null) {
            mIncompleteTicketTask.cancel(true);
        }
    }

    @OnItemClick(android.R.id.list)
    void onTicketClicked(int position) {
        IncompleteTicket ticket = (IncompleteTicket) getListView().getItemAtPosition(position);
        mCallback.onIncompleteContestClicked(ticket);
    }

    public interface IncompleteContestCallback {

        public void onIncompleteContestClicked(IncompleteTicket ticket);
    }

    public class IncompleteTicketTask extends AsyncTask<Void, Void, List<IncompleteTicket>> {

        @Override
        protected List<IncompleteTicket> doInBackground(Void... params) {
            purgeExpiredTickets();
            return mIncompleteTicketDaoHelper.getTickets();
        }

        @Override
        protected void onPostExecute(List<IncompleteTicket> incompleteTickets) {
            super.onPostExecute(incompleteTickets);
            setListAdapter(new IncompleteContestAdapter(getActivity(), incompleteTickets));
        }

        private void purgeExpiredTickets() {
            int count = mIncompleteTicketDaoHelper.deleteTicketsBefore(new Date());
            Log.i(TAG, "Purged " + count + " expired incomplete tickets.");
        }
    }
}
