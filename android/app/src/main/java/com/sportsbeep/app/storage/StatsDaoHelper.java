package com.sportsbeep.app.storage;

import com.j256.ormlite.dao.Dao;
import com.j256.ormlite.stmt.QueryBuilder;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.model.player.stats.Stats;

import java.sql.SQLException;
import java.util.List;
import java.util.concurrent.Callable;

import javax.inject.Inject;
import javax.inject.Singleton;

public class StatsDaoHelper {

    @Inject
    Dao<Stats.RecentStat, Long> mRecentStatDao;

    @Inject
    Dao<Stats.SeasonStat, Long> mSeasonStatDao;

    public List<? extends Stats.Stat> getStatsForSummary(long playerId) {
        QueryBuilder<Stats.RecentStat, Long> queryBuilder = mRecentStatDao.queryBuilder();
        try {
            queryBuilder.where().eq("shownOnSummary", true).and().eq("player_id", playerId);
            return queryBuilder.query();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public void createStats(final List<Stats.RecentStat> recentStats, final List<Stats.SeasonStat> seasonStats, final Player player) {
        try {
            mRecentStatDao.callBatchTasks(new Callable<Void>() {
                @Override
                public Void call() throws Exception {
                    if (recentStats != null) {
                        for (Stats.RecentStat stat : recentStats) {
                            createRecentStat(stat, player);
                        }
                    }

                    if (seasonStats != null) {
                        for (Stats.SeasonStat stat : seasonStats) {
                            createSeasonStat(stat, player);
                        }
                    }

                    return null;
                }
            });
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public void createRecentStats(final List<Stats.RecentStat> recentStats, final Player player) {
        try {
            mRecentStatDao.callBatchTasks(new Callable<Void>() {
                @Override
                public Void call() throws Exception {
                    for (Stats.RecentStat stat : recentStats) {
                        createRecentStat(stat, player);
                    }

                    return null;
                }
            });
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public void createRecentStat(Stats.RecentStat stat, Player player) {
        createStat(mRecentStatDao, stat, player);
    }

    public void createSeasonStat(Stats.SeasonStat stat, Player player) {
        createStat(mSeasonStatDao, stat, player);
    }

    private <T extends Stats.Stat> void createStat(Dao<T, Long> dao, T stat, Player player) {
        stat.setPlayer(player);
        try {
            if (!updateStat(dao, stat, player)) {
                dao.create(stat);
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    private <T extends Stats.Stat> boolean updateStat(Dao<T, Long> dao, T stat, Player player) throws SQLException {
        QueryBuilder<T, Long> queryBuilder = dao.queryBuilder();
        queryBuilder.where().eq("name", stat.getName()).and().eq("player_id", player.getId());
        T dbStat = queryBuilder.queryForFirst();
        if (dbStat != null) {
            stat.setId(dbStat.getId());
            stat.setShownOnSummary(stat.isShownOnSummary() || dbStat.isShownOnSummary());
            dao.update(stat);

            return true;
        }

        return false;
    }
}
