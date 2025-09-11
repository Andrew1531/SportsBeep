package com.sportsbeep.app.task.network;

import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.team.TeamRanking;
import com.sportsbeep.app.network.NetworkClient;
import com.sportsbeep.app.storage.TeamDaoHelper;

import java.util.List;

import javax.inject.Inject;

public class TeamRankingsAsyncTask extends NetworkAsyncTask<Long, Void, List<TeamRanking>> {

    public TeamRankingsAsyncTask(Sport sport, Level level) {
        super(sport, level);
    }

    @Override
    protected List<TeamRanking> queryData(Long... params) {
        // TODO
        return super.queryData(params);
    }

    @Override
    protected Result<List<TeamRanking>> downloadData(NetworkClient client, Long... params) {
        return client.getTeamRankings(getSportTemp(), getLevelTemp(), params[0]);
    }
}
