package com.sportsbeep.app.storage;

import com.j256.ormlite.dao.Dao;
import com.j256.ormlite.stmt.QueryBuilder;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.model.team.Team;

import java.sql.SQLException;
import java.util.List;
import java.util.concurrent.Callable;

import javax.inject.Inject;
import javax.inject.Singleton;

public class TeamDaoHelper {

    @Inject
    Dao<Team, Long> mTeamDao;

    @Inject
    Dao<Player, Long> mPlayerDao;

    public Team getTeamForPlayer(final long playerId) {

        try {
            QueryBuilder<Player, Long> playerQueryBuilder = mPlayerDao.queryBuilder();
            playerQueryBuilder.where().idEq(playerId);

            QueryBuilder<Team, Long> teamQueryBuilder = mTeamDao.queryBuilder();
            teamQueryBuilder.join(playerQueryBuilder);
            return teamQueryBuilder.queryForFirst();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public List<Team> getTeams() {
        try {
            return mTeamDao.queryForAll();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public Team getTeam(long teamId) {
        try {
            return mTeamDao.queryForId(teamId);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public Team getTeam(Team team) {
        try {
            return mTeamDao.queryForSameId(team);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public void addOrUpdateTeam(Team team) {

        try {
            mTeamDao.createOrUpdate(team);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public void addOrUpdateTeams(final List<? extends Team> teams) {
        try {
            mTeamDao.callBatchTasks(new Callable<Void>() {
                @Override
                public Void call() throws Exception {
                    for (Team team : teams) {
                        addOrUpdateTeam(team);
                    }

                    return null;
                }
            });
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
