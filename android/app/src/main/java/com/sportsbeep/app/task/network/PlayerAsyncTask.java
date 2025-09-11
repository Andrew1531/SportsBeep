package com.sportsbeep.app.task.network;

import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.network.NetworkClient;
import com.sportsbeep.app.storage.PlayerDaoHelper;

import javax.inject.Inject;

public class PlayerAsyncTask extends NetworkAsyncTask<Long, Void, Player> {

    @Inject
    PlayerDaoHelper mPlayerDaoHelper;

    public PlayerAsyncTask(Sport sport, Level level) {
        super(sport, level);
    }

    @Override
    protected Player queryData(Long... params) {
        return mPlayerDaoHelper.getPlayer(params[0]);
    }

    @Override
    protected Result<Player> downloadData(NetworkClient client, Long... params) {
        return client.getPlayer(getSportTemp(), getLevelTemp(), params[0]);
    }
}
