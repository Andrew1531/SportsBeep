package com.sportsbeep.app.storage;

import com.j256.ormlite.android.apptools.OrmLiteSqliteOpenHelper;
import com.j256.ormlite.dao.Dao;
import com.j256.ormlite.support.ConnectionSource;
import com.j256.ormlite.table.TableUtils;
import com.sportsbeep.app.model.user.User;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.player.GamePlayer;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.model.player.stats.Stats;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.model.ticket.IncompleteTicket;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.util.Log;

import java.sql.SQLException;

import javax.inject.Inject;
import javax.inject.Singleton;

@Singleton
public class DatabaseHelper extends OrmLiteSqliteOpenHelper {

    private static final String TAG = DatabaseHelper.class.getSimpleName();

    private static final int VERSION = 41;

    private Dao<Team, Long> mTeamDao;

    private Dao<Player, Long> mPlayerDao;

    private Dao<Stats.RecentStat, Long> mRecentStatDao;

    private Dao<Stats.SeasonStat, Long> mSeasonStatDao;

    private Dao<Game, Long> mGameDao;

    private Dao<GamePlayer, Long> mGamePlayerDao;

    private Dao<IncompleteTicket, Long> mIncompleteTicketDao;

    @Inject
    public DatabaseHelper(Context context, String name) {
        super(context, name, null, VERSION);
    }

    @Override
    public void onCreate(SQLiteDatabase database, ConnectionSource connectionSource) {
        database.beginTransaction();
        try {
            TableUtils.createTable(connectionSource, Team.class);
            TableUtils.createTable(connectionSource, Player.class);
            TableUtils.createTable(connectionSource, Stats.RecentStat.class);
            TableUtils.createTable(connectionSource, Stats.SeasonStat.class);
            TableUtils.createTable(connectionSource, Game.class);
            TableUtils.createTable(connectionSource, GamePlayer.class);
            TableUtils.createTable(connectionSource, IncompleteTicket.class);
            database.setTransactionSuccessful();
        } catch (SQLException e) {
            Log.e(TAG, "Failed to create database", e);
            throw new RuntimeException(e);
        }
        database.endTransaction();
    }

    @Override
    public void onUpgrade(SQLiteDatabase database, ConnectionSource connectionSource, int oldVersion, int newVersion) {
        database.beginTransaction();
        try {
            if (oldVersion < 39) {
                dropAllTables();
                onCreate(database, connectionSource);
            } else if (oldVersion < 41) {
                TableUtils.dropTable(connectionSource, User.class, true);
                mIncompleteTicketDao.executeRaw("ALTER TABLE `incompleteTicket` ADD COLUMN leaguePickGame_id INTEGER DEFAULT 0;");
                mIncompleteTicketDao.executeRaw("ALTER TABLE `incompleteTicket` ADD COLUMN leaguePickTeam_id INTEGER DEFAULT 0;");
            }

            database.setVersion(newVersion);
            database.setTransactionSuccessful();
        } catch (SQLException e) {
            Log.e(TAG, "Failed to upgrade database. Dropping and recreating all tables.", e);
            try {
                dropAllTables();
                onCreate(database, connectionSource);
                database.setVersion(newVersion);
                database.setTransactionSuccessful();
            } catch (SQLException e1) {
                Log.e(TAG, "Failed to drop tables.", e);
                throw new RuntimeException(e1);
            }
            throw new RuntimeException(e);
        } finally {
            database.endTransaction();
        }
    }

    private void dropAllTables() throws SQLException {
        TableUtils.dropTable(connectionSource, Team.class, true);
        TableUtils.dropTable(connectionSource, Player.class, true);
        TableUtils.dropTable(connectionSource, Stats.RecentStat.class, true);
        TableUtils.dropTable(connectionSource, Stats.SeasonStat.class, true);
        TableUtils.dropTable(connectionSource, Game.class, true);
        TableUtils.dropTable(connectionSource, GamePlayer.class, true);
        TableUtils.dropTable(connectionSource, IncompleteTicket.class, true);
    }

    public Dao<Team, Long> getTeamDao() {
        if (mTeamDao == null) {
            try {
                mTeamDao = getDao(Team.class);
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        }

        return mTeamDao;
    }

    public Dao<Game, Long> getGameDao() {
        if (mGameDao == null) {
            try {
                mGameDao = getDao(Game.class);
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        }

        return mGameDao;
    }

    public Dao<Player, Long> getPlayerDao() {
        if (mPlayerDao == null) {
            try {
                mPlayerDao = getDao(Player.class);
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        }

        return mPlayerDao;
    }

    public Dao<Stats.RecentStat, Long> getRecentStatDao() {
        if (mRecentStatDao == null) {
            try {
                mRecentStatDao = getDao(Stats.RecentStat.class);
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        }

        return mRecentStatDao;
    }

    public Dao<Stats.SeasonStat, Long> getSeasonStatDao() {
        if (mSeasonStatDao == null) {
            try {
                mSeasonStatDao = getDao(Stats.SeasonStat.class);
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        }

        return mSeasonStatDao;
    }

    public Dao<GamePlayer, Long> getGamePlayerDao() {
        if (mGamePlayerDao == null) {
            try {
                mGamePlayerDao = getDao(GamePlayer.class);
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        }

        return mGamePlayerDao;
    }

    public Dao<IncompleteTicket, Long> getIncompleteTicketDao() {
        if (mIncompleteTicketDao == null) {
            try {
                mIncompleteTicketDao = getDao(IncompleteTicket.class);
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        }

        return mIncompleteTicketDao;
    }
}
