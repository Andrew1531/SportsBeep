package com.sportsbeep.app.task;

import com.sportsbeep.app.model.ticket.IncompleteTicket;
import com.sportsbeep.app.module.GraphHolder;
import com.sportsbeep.app.storage.IncompleteTicketDaoHelper;

import android.os.AsyncTask;

import javax.inject.Inject;

public class DeleteIncompleteTicketTask extends AsyncTask<IncompleteTicket, Void, Boolean> {

    @Inject
    IncompleteTicketDaoHelper mIncompleteTicketDaoHelper;

    public DeleteIncompleteTicketTask() {
        GraphHolder.getInstance().inject(this);
    }

    @Override
    protected Boolean doInBackground(IncompleteTicket... params) {
        IncompleteTicket ticket = params[0];
        return mIncompleteTicketDaoHelper.deleteTicket(ticket);
    }
}
