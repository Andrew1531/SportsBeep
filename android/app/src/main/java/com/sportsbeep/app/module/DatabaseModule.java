package com.sportsbeep.app.module;

import com.j256.ormlite.dao.Dao;
import com.sportsbeep.app.adapter.AnswersAdapter;
import com.sportsbeep.app.adapter.LiveContestAdapter;
import com.sportsbeep.app.adapter.PlayersAdapter;
import com.sportsbeep.app.adapter.PositionsAdapter;
import com.sportsbeep.app.adapter.ScoringBreakdownAdapter;
import com.sportsbeep.app.adapter.UpcomingContestAdapter;
import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.player.GamePlayer;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.model.player.stats.Stats;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.model.ticket.IncompleteTicket;
import com.sportsbeep.app.storage.DatabaseHelper;
import com.sportsbeep.app.storage.GameDaoHelper;
import com.sportsbeep.app.storage.IncompleteTicketDaoHelper;
import com.sportsbeep.app.storage.PlayerDaoHelper;
import com.sportsbeep.app.storage.StatsDaoHelper;
import com.sportsbeep.app.storage.TeamDaoHelper;
import com.sportsbeep.app.task.DeleteIncompleteTicketTask;
import com.sportsbeep.app.task.SaveIncompleteTicketTask;

import android.content.Context;

import java.util.HashMap;
import java.util.Map;

import dagger.Module;
import dagger.Provides;

@Module(
        injects = {
                TeamDaoHelper.class,
                GameDaoHelper.class,
                PlayerDaoHelper.class,
                StatsDaoHelper.class,
                IncompleteTicketDaoHelper.class,
                SaveIncompleteTicketTask.class,
                DeleteIncompleteTicketTask.class,
                PlayersAdapter.class,
                PositionsAdapter.class,
                AnswersAdapter.class,
                ScoringBreakdownAdapter.class,
                LiveContestAdapter.class,
                UpcomingContestAdapter.class,
                UpcomingContestAdapter.GameTask.class,
                LiveContestAdapter.class,
                LiveContestAdapter.GameTask.class,
                ScoringBreakdownAdapter.class,
                ScoringBreakdownAdapter.PlayerTask.class
        },
        complete = false,
        library = true
)
class DatabaseModule {

    Map<Sport, DatabaseHelper> mDatabaseMap = new HashMap<Sport, DatabaseHelper>();

    @Provides
    DatabaseHelper providesDatabaseHelper(Context context, Sport sport, Level level) {
        if (!mDatabaseMap.containsKey(sport)) {
            mDatabaseMap.put(sport, new DatabaseHelper(context, getDatabaseName(sport, level)));
        }

        return mDatabaseMap.get(sport);
    }

    @Provides
    Dao<Team, Long> providesTeamDao(DatabaseHelper helper) {
        return helper.getTeamDao();
    }

    @Provides
    Dao<Game, Long> providesGameDao(DatabaseHelper helper) {
        return helper.getGameDao();
    }

    @Provides
    Dao<Player, Long> providesPlayerDao(DatabaseHelper helper) {
        return helper.getPlayerDao();
    }

    @Provides
    Dao<GamePlayer, Long> providesGamePlayerDao(DatabaseHelper helper) {
        return helper.getGamePlayerDao();
    }

    @Provides
    Dao<Stats.RecentStat, Long> providesRecentStatDao(DatabaseHelper helper) {
        return helper.getRecentStatDao();
    }

    @Provides
    Dao<Stats.SeasonStat, Long> providesSeasonStatDao(DatabaseHelper helper) {
        return helper.getSeasonStatDao();
    }

    @Provides
    Dao<IncompleteTicket, Long> providesIncompleteTicketDao(DatabaseHelper helper) {
        return helper.getIncompleteTicketDao();
    }

    private String getDatabaseName(Sport sport, Level level) {
        return sport.name() + "-" + level.name() + ".db";
    }
}
