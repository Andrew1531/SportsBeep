package com.sportsbeep.app.task.network;

import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.network.NetworkClient;
import com.sportsbeep.app.storage.GameDaoHelper;

import javax.inject.Inject;

public class GameAsyncTask extends NetworkAsyncTask<Long, Void, Game> {

    @Inject
    GameDaoHelper mGameDaoHelper;

    public GameAsyncTask(Sport sport, Level level) {
        super(sport, level);
    }

    @Override
    protected Game queryData(Long... params) {
        return mGameDaoHelper.getGame(params[0]);
    }

    @Override
    protected Result<Game> downloadData(NetworkClient client, Long... params) {
        return client.getGame(getSportTemp(), getLevelTemp(), params[0]);
    }
}
