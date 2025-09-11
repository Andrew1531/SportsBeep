package com.sportsbeep.app.task.network;

import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.ticket.TicketLeaguePick;
import com.sportsbeep.app.network.NetworkClient;

public class TicketLeaguePickAsyncTask extends NetworkAsyncTask<Long, Void, TicketLeaguePick> {

    public TicketLeaguePickAsyncTask(Sport sport, Level level) {
        super(sport, level);
    }

    @Override
    protected TicketLeaguePick queryData(Long... params) {
        // TODO Add TicketLeaguePick to database
        return super.queryData(params);
    }

    @Override
    protected Result<TicketLeaguePick> downloadData(NetworkClient client, Long... params) {
        return client.getTicketLeaguePick(getSportTemp(), getLevelTemp(), params[0]);
    }
}
