package com.sportsbeep.app.task.network;

import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.network.NetworkClient;
import com.sportsbeep.app.storage.TeamDaoHelper;

import javax.inject.Inject;

public class TeamAsyncTask extends NetworkAsyncTask<Long, Void, Team> {

    @Inject
    TeamDaoHelper mTeamDaoHelper;

    public TeamAsyncTask(Sport sport, Level level) {
        super(sport, level);
    }

    @Override
    protected Team queryData(Long... params) {
        return mTeamDaoHelper.getTeam(params[0]);
    }

    @Override
    protected Result<Team> downloadData(NetworkClient client, Long... params) {
        return client.getTeam(getSportTemp(), getLevelTemp(), params[0]);
    }
}
