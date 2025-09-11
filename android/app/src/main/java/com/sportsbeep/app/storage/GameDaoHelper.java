package com.sportsbeep.app.storage;

import com.j256.ormlite.dao.Dao;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.game.Game;

import java.sql.SQLException;
import java.util.List;
import java.util.concurrent.Callable;

import javax.inject.Inject;
import javax.inject.Singleton;

public class GameDaoHelper {

    @Inject
    Dao<Game, Long> mGameDao;

    @Inject
    TeamDaoHelper mTeamDaoHelper;

    public Game getGame(long id) {
        try {
            return mGameDao.queryForId(id);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public Game getGame(Game game) {
        try {
            return mGameDao.queryForSameId(game);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public List<Game> getGames(Sport sport) {
        try {
            return mGameDao.queryForEq("sport", sport);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public void addOrUpdateGame(Game game) {
        try {
            mTeamDaoHelper.addOrUpdateTeam(game.getHomeTeam());
            mTeamDaoHelper.addOrUpdateTeam(game.getAwayTeam());
            mGameDao.createOrUpdate(game);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public void addOrUpdateGames(final List<? extends Game> games) {
        try {
            mGameDao.callBatchTasks(new Callable<Void>() {
                @Override
                public Void call() throws Exception {
                    for (Game game : games) {
                        addOrUpdateGame(game);
                    }

                    return null;
                }
            });
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
