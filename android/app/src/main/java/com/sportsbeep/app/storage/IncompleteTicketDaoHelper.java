package com.sportsbeep.app.storage;

import com.j256.ormlite.dao.Dao;
import com.j256.ormlite.stmt.QueryBuilder;
import com.j256.ormlite.table.TableUtils;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.model.ticket.IncompleteTicket;

import android.util.Log;

import java.sql.SQLException;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.concurrent.Callable;

import javax.inject.Inject;
import javax.inject.Singleton;

public class IncompleteTicketDaoHelper {

    private static final String TAG = IncompleteTicketDaoHelper.class.getSimpleName();

    @Inject
    Dao<IncompleteTicket, Long> mIncompleteTicketDao;

    @Inject
    Dao<Game, Long> mGameDao;

    public Dao.CreateOrUpdateStatus addOrUpdateTicket(IncompleteTicket ticket) {
        try {
            return mIncompleteTicketDao.createOrUpdate(ticket);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public boolean deleteTicket(IncompleteTicket ticket) {
        Log.i(TAG, "Removing incomplete ticket: " + ticket.getId());
        try {
            return mIncompleteTicketDao.delete(ticket) != 0;
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public int deleteAllTickets() {
        try {
            return TableUtils.clearTable(mIncompleteTicketDao.getConnectionSource(), IncompleteTicket.class);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public int deleteTicketsBefore(final Date date) {
        final List<IncompleteTicket> tickets = getTickets();
        try {
            return mIncompleteTicketDao.callBatchTasks(new Callable<Integer>() {
                @Override
                public Integer call() throws Exception {
                    int count = 0;
                    for (IncompleteTicket ticket : tickets) {
                        if (ticket.getGame().getStartTime().before(date)) {
                            count += mIncompleteTicketDao.delete(ticket);
                        }
                    }

                    return count;
                }
            });
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    public IncompleteTicket getTicketForGame(Game game) {
        try {
            List<IncompleteTicket> ticketList = mIncompleteTicketDao.queryForEq("game_id", game.getId());
            if (!ticketList.isEmpty()) {
                return ticketList.get(0);
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

        return null;
    }

    public List<IncompleteTicket> getTickets() {
        try {
            QueryBuilder<Game, Long> gameStartTimeQB = mGameDao.queryBuilder();
            gameStartTimeQB.orderBy("startTime", true);

            QueryBuilder<IncompleteTicket, Long> incompleteTicketQueryBuilder = mIncompleteTicketDao.queryBuilder();
            return incompleteTicketQueryBuilder.join(gameStartTimeQB).query();
        } catch (SQLException e) {
            // The model uses serialization for one of its members. The member object likely changed.
            // Purge the table
            Log.e(TAG, "SQLException getting incomplete tickets. Purging table.");
            try {
                TableUtils.clearTable(mIncompleteTicketDao.getConnectionSource(), IncompleteTicket.class);
                return Collections.emptyList();
            } catch (SQLException e1) {
                throw new RuntimeException(e1);
            }
        }
    }
}
