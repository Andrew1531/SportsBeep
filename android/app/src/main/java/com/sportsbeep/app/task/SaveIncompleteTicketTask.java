package com.sportsbeep.app.task;

import com.j256.ormlite.dao.Dao;
import com.sportsbeep.app.R;
import com.sportsbeep.app.model.ticket.IncompleteTicket;
import com.sportsbeep.app.module.GraphHolder;
import com.sportsbeep.app.storage.IncompleteTicketDaoHelper;

import android.content.Context;
import android.os.AsyncTask;
import android.widget.Toast;

import javax.inject.Inject;

public class SaveIncompleteTicketTask extends AsyncTask<IncompleteTicket, Void, Dao.CreateOrUpdateStatus> {

    @Inject
    IncompleteTicketDaoHelper mIncompleteTicketDaoHelper;

    @Inject
    Context mContext;

    public SaveIncompleteTicketTask() {
        GraphHolder.getInstance().inject(this);
    }

    @Override
    protected Dao.CreateOrUpdateStatus doInBackground(IncompleteTicket... params) {
        IncompleteTicket ticket = params[0];
        return mIncompleteTicketDaoHelper.addOrUpdateTicket(ticket);
    }

    @Override
    protected void onPostExecute(Dao.CreateOrUpdateStatus status) {
        super.onPostExecute(status);
        int toastResId;
        if (status.isCreated()) {
            toastResId = R.string.ticket_saved;
        } else {
            toastResId = R.string.ticket_updated;
        }

        Toast.makeText(mContext, toastResId, Toast.LENGTH_LONG).show();
    }
}
