package com.sportsbeep.app.storage;

import com.j256.ormlite.dao.Dao;
import com.j256.ormlite.stmt.DeleteBuilder;
import com.j256.ormlite.stmt.QueryBuilder;
import com.sportsbeep.app.enumeration.Position;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.player.GamePlayer;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.model.player.stats.Stats;

import java.sql.SQLException;
import java.util.List;
import java.util.concurrent.Callable;

import javax.inject.Inject;

public class PlayerDaoHelper {

    @Inject
    Dao<Player, Long> mPlayerDao;

    @Inject
    Dao<GamePlayer, Long> mGamePlayerDao;

    @Inject
    StatsDaoHelper mStatsDaoHelper;

    public List<Player> getPlayersForPosition(final long gameId, final Position[] positions, final long... excludeIds) {
        try {
            QueryBuilder<GamePlayer, Long> gamePlayerQueryBuilder = mGamePlayerDao.queryBuilder();
            gamePlayerQueryBuilder.where().eq("game_id", gameId);

            QueryBuilder<Player, Long> playerQueryBuilder = mPlayerDao.queryBuilder();
            playerQueryBuilder.join(gamePlayerQueryBuilder);
            playerQueryBuilder.where().in("position", (Object[]) positions).and().notIn("_id", convertToObjectArray(excludeIds));
            playerQueryBuilder.orderBy("name", true);

            return playerQueryBuilder.query();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public Player getPlayer(long playerId) {
        try {
            return mPlayerDao.queryForId(playerId);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    private Object[] convertToObjectArray(long[] values) {
        Object[] objArray = new Object[values.length];
        for (int i = 0; i < values.length; i++) {
            objArray[i] = values[i];
        }

        return objArray;
    }

    public void addOrUpdatePlayer(Player player) {
        try {
            for (Stats.RecentStat stat : player.getStats()) {
                stat.setShownOnSummary(true);
            }
            mStatsDaoHelper.createRecentStats(player.getStats(), player);
            mPlayerDao.createOrUpdate(player);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public void addOrUpdatePlayer(long gameId, Player player) {
        addOrUpdatePlayer(player);

        Game game = new Game();
        game.setId(gameId);

        try {
            mGamePlayerDao.createIfNotExists(new GamePlayer(game, player));
        } catch (SQLException e) {
            // Expected if the game and player combo are already in the database
        }
    }

    public void addOrUpdatePlayers(final long gameId, final List<? extends Player> players) {
        try {
            DeleteBuilder<GamePlayer, Long> mDeleteBuilder = mGamePlayerDao.deleteBuilder();
            mDeleteBuilder.where().eq("game_id", gameId);
            mDeleteBuilder.delete();

            mPlayerDao.callBatchTasks(new Callable<Void>() {
                @Override
                public Void call() throws Exception {
                    for (Player player : players) {
                        addOrUpdatePlayer(gameId, player);
                    }

                    return null;
                }
            });
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
