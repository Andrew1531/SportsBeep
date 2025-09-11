package com.sportsbeep.app.network;

import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.contest.Contest;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.model.player.stats.Stats;
import com.sportsbeep.app.model.pool.PoolResponse;
import com.sportsbeep.app.model.question.Answer;
import com.sportsbeep.app.model.question.Question;
import com.sportsbeep.app.model.question.TimerState;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.model.team.TeamRanking;
import com.sportsbeep.app.model.ticket.Scoresheet;
import com.sportsbeep.app.model.ticket.Ticket;
import com.sportsbeep.app.model.ticket.TicketLeaguePick;
import com.sportsbeep.app.model.ticket.TicketPositions;
import com.sportsbeep.app.model.user.PhotoResponse;
import com.sportsbeep.app.model.user.User;
import com.sportsbeep.app.module.GraphHolder;
import com.sportsbeep.app.network.params.AnswerParams;
import com.sportsbeep.app.network.params.ContestsParams;
import com.sportsbeep.app.network.params.CreateAccountParams;
import com.sportsbeep.app.network.params.PutDeviceTokenParams;
import com.sportsbeep.app.network.params.PutFavoriteTeamParams;
import com.sportsbeep.app.network.params.RemoveAvatarParams;
import com.sportsbeep.app.network.params.SignInParams;
import com.sportsbeep.app.network.params.ticket.CreateTicketParams;
import com.sportsbeep.app.network.params.ticket.UpdateTicketParams;
import com.sportsbeep.app.storage.GameDaoHelper;
import com.sportsbeep.app.storage.PlayerDaoHelper;
import com.sportsbeep.app.storage.StatsDaoHelper;
import com.sportsbeep.app.storage.TeamDaoHelper;
import com.sportsbeep.app.util.typed.TypedUri;

import android.util.Log;

import java.util.List;

import javax.inject.Inject;
import javax.inject.Singleton;

import retrofit.RetrofitError;

@Singleton
public class NetworkClient {

    private static final String TAG = NetworkClient.class.getSimpleName();

    private static final String PATH_MLB = "mlb";

    private static final String PATH_NFL = "nfl";

    private final NetworkService mService;

    @Inject
    NetworkClient(NetworkService service) {
        mService = service;
    }

    public Result<User> signIn(SignInParams param) {
        try {
            return new Result<User>(mService.signIn(param));
        } catch (RetrofitError e) {
            Log.e(TAG, "Error signing in.", e);
            return new Result<User>(e);
        }
    }

    public Result<User> createAccount(CreateAccountParams param) {
        try {
            return new Result<User>(mService.createAccount(param));
        } catch (RetrofitError e) {
            Log.e(TAG, "Error creating account.", e);
            return new Result<User>(e);
        }
    }

    public Result<Void> putDeviceToken(String deviceToken) {
        PutDeviceTokenParams params = new PutDeviceTokenParams(deviceToken);
        try {
            return new Result<Void>(mService.putDeviceToken(params));
        } catch (RetrofitError e) {
            Log.e(TAG, "Error putting device token.", e);
            return new Result<Void>(e);
        }
    }

    public Result<PhotoResponse> updateAvatar(TypedUri typedUri) {
        try {
            return new Result<PhotoResponse>(mService.updateAvatar(typedUri));
        } catch (RetrofitError e) {
            Log.e(TAG, "Error updating avatar.", e);
            return new Result<PhotoResponse>(e);
        }
    }

    public Result<PhotoResponse> removeAvatar() {
        try {
            return new Result<PhotoResponse>(mService.removeAvatar(new RemoveAvatarParams()));
        } catch (RetrofitError e) {
            Log.e(TAG, "Error removing avatar.", e);
            return new Result<PhotoResponse>(e);
        }
    }

    public Result<List<Team>> getTeams(Sport sport, Level level) {
        try {
            List<Team> teams = mService.getTeams(getSportPath(sport, level)).getTeams();

            TeamDaoHelper helper = GraphHolder.getInstance().get(TeamDaoHelper.class);
            helper.addOrUpdateTeams(teams);

            return new Result<List<Team>>(teams);
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading teams.", e);
            return new Result<List<Team>>(e);
        }
    }

    public Result<Team> getTeam(Sport sport, Level level, long teamId) {
        try {
            Team team = mService.getTeam(getSportPath(sport, level), teamId);

            TeamDaoHelper helper = GraphHolder.getInstance().get(TeamDaoHelper.class);
            helper.addOrUpdateTeam(team);

            return new Result<Team>(team);
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading team {id=" + teamId + "}", e);
            return new Result<Team>(e);
        }
    }

    public Result<List<TeamRanking>> getTeamRankings(Sport sport, Level level, long teamId) {
        try {
            return new Result<List<TeamRanking>>(mService.getTeamRankings(getSportPath(sport, level), teamId).getRankings());
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading team rankings {id=" + teamId + "}", e);
            return new Result<List<TeamRanking>>(e);
        }
    }

    public Result<Void> putFavoriteTeams(long mlbTeamId) {
        try {
            return new Result<Void>(mService.putFavoriteTeam(new PutFavoriteTeamParams(mlbTeamId)));
        } catch (RetrofitError e) {
            Log.e(TAG, "Error submitting favorite teams.", e);
            return new Result<Void>(e);
        }
    }

    public Result<List<Game>> getGames(Sport sport, Level level) {
        try {
            List<Game> games = mService.getGames(getSportPath(sport, level)).getGames();

            GameDaoHelper helper = GraphHolder.getInstance().get(GameDaoHelper.class);
            helper.addOrUpdateGames(games);

            return new Result<List<Game>>(games);
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading game list.", e);
            return new Result<List<Game>>(e);
        }
    }

    public Result<List<Game>> getGames(Sport sport, Level level, int days) {
        try {
            List<Game> games = mService.getGames(getSportPath(sport, level), days).getGames();

            GameDaoHelper helper = GraphHolder.getInstance().get(GameDaoHelper.class);
            helper.addOrUpdateGames(games);

            return new Result<List<Game>>(games);
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading game list.", e);
            return new Result<List<Game>>(e);
        }
    }

    public Result<Game> getGame(Sport sport, Level level, long gameId) {
        try {
            Game game = mService.getGame(getSportPath(sport, level), gameId);

            GameDaoHelper helper = GraphHolder.getInstance().get(GameDaoHelper.class);
            helper.addOrUpdateGame(game);

            return new Result<Game>(game);
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading game {id=" + gameId + "}", e);
            return new Result<Game>(e);
        }
    }

    public Result<List<Player>> getPlayersForGame(Sport sport, Level level, long gameId) {
        try {
            List<Player> players = mService.getPlayersForGame(getSportPath(sport, level), gameId).getPlayers();

            PlayerDaoHelper helper = GraphHolder.getInstance().get(PlayerDaoHelper.class);
            helper.addOrUpdatePlayers(gameId, players);

            return new Result<List<Player>>(players);
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading players list.", e);
            return new Result<List<Player>>(e);
        }
    }

    public Result<Player> getPlayer(Sport sport, Level level, long playerId) {
        try {
            Player player = mService.getPlayer(getSportPath(sport, level), playerId);

            PlayerDaoHelper helper = GraphHolder.getInstance().get(PlayerDaoHelper.class);
            helper.addOrUpdatePlayer(player);

            return new Result<Player>(player);
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading player.", e);
            return new Result<Player>(e);
        }
    }

    public Result<Stats> getStatsForPlayers(Sport sport, Level level, Player player) {
        try {
            Stats stats = mService.getStatsForPlayers(getSportPath(sport, level), player.getId());

            StatsDaoHelper helper = GraphHolder.getInstance().get(StatsDaoHelper.class);
            helper.createStats(stats.getRecentStats(), stats.getSeasonStats(), player);

            return new Result<Stats>(stats);
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading player stats.", e);
            return new Result<Stats>(e);
        }
    }

    public Result<List<Game>> getLeaguePicks(Sport sport, Level level, long gameId) {
        try {
            List<Game> games = mService.getLeaguePicks(getSportPath(sport, level), gameId).getGames();

            GameDaoHelper helper = GraphHolder.getInstance().get(GameDaoHelper.class);
            helper.addOrUpdateGames(games);

            return new Result<List<Game>>(games);
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading league picks.", e);
            return new Result<List<Game>>(e);
        }
    }

    public Result<PoolResponse> getPools(Sport sport, Level level, long gameId) {
        try {
            return new Result<PoolResponse>(mService.getPools(getSportPath(sport, level), gameId));
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading pools.", e);
            return new Result<PoolResponse>(e);
        }
    }

    public Result<Ticket> createTicket(Sport sport, Level level, CreateTicketParams params) {
        try {
            return new Result<Ticket>(mService.createTicket(getSportPath(sport, level), params));
        } catch (RetrofitError e) {
            Log.e(TAG, "Error creating ticket.", e);
            return new Result<Ticket>(e);
        }
    }

    public Result<Void> updateTicket(Sport sport, Level level, long ticketId, UpdateTicketParams params) {
        try {
            return new Result<Void>(mService.updateTicket(getSportPath(sport, level), ticketId, params));
        } catch (RetrofitError e) {
            Log.e(TAG, "Error updating ticket {id=" + ticketId + "}", e);
            return new Result<Void>(e);
        }
    }

    public Result<List<Question>> getQuestions(Sport sport, Level level, long ticketId) {
        try {
            return new Result<List<Question>>(mService.getTicketQuestions(getSportPath(sport, level), ticketId).getQuestions());
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading questions {id=" + ticketId + "}", e);
            return new Result<List<Question>>(e);
        }
    }

    public Result<List<Answer>> getAnswers(Sport sport, Level level, long ticketId) {
        try {
            return new Result<List<Answer>>(mService.getTicketAnswers(getSportPath(sport, level), ticketId).getAnswers());
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading answers {id=" + ticketId + "}", e);
            return new Result<List<Answer>>(e);
        }
    }

    public Result<TicketLeaguePick> getTicketLeaguePick(Sport sport, Level level, long ticketId) {
        try {
            return new Result<TicketLeaguePick>(mService.getTicketLeaguePick(getSportPath(sport, level), ticketId));
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading ticket league pic {id=" + ticketId + "}", e);
            return new Result<TicketLeaguePick>(e);
        }
    }

    public Result<List<TimerState>> getTimerStates(Sport sport, Level level, long ticketId) {
        try {
            return new Result<List<TimerState>>(mService.getTimerStates(getSportPath(sport, level), ticketId).getTimerStates());
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading timer states {id=" + ticketId + "}", e);
            return new Result<List<TimerState>>(e);
        }
    }

    public Result<List<Contest>> getContests(Sport sport, Level level, ContestsParams.ContestStatus status) {
        try {
            return new Result<List<Contest>>(mService.getContests(getSportPath(sport, level), status).getContests());
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading contests.", e);
            return new Result<List<Contest>>(e);
        }
    }

    public Result<Void> submitTicketAnswers(Sport sport, Level level, long ticketId, AnswerParams params) {
        try {
            return new Result<Void>(mService.submitTicketAnswers(getSportPath(sport, level), ticketId, params));
        } catch (RetrofitError e) {
            Log.e(TAG, "Error submitting ticket answers {id=" + ticketId + "}", e);
            return new Result<Void>(e);
        }
    }

    public Result<Contest> getContest(Sport sport, Level level, long contestId) {
        try {
            return new Result<Contest>(mService.getContest(getSportPath(sport, level), contestId));
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading contest {id=" + contestId + "}");
            return new Result<Contest>(e);
        }
    }

    public Result<List<Ticket>> getTickets(Sport sport, Level level, long contestId, String dpiBucket) {
        try {
            return new Result<List<Ticket>>(mService.getTickets(getSportPath(sport, level), contestId, dpiBucket).getTickets());
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading tickets {id=" + contestId + "}");
            return new Result<List<Ticket>>(e);
        }
    }

    public Result<Ticket> getTicket(Sport sport, Level level, long ticketId) {
        try {
            return new Result<Ticket>(mService.getTicket(getSportPath(sport, level), ticketId));
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading ticket {id=" + ticketId + "}");
            return new Result<Ticket>(e);
        }
    }

    public Result<TicketPositions> getPositionsForTicket(Sport sport, Level level, long ticketId) {
        try {
            return new Result<TicketPositions>(mService.getPositionsForTicket(getSportPath(sport, level), ticketId));
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading positions for ticket {id=" + ticketId + "}");
            return new Result<TicketPositions>(e);
        }
    }

    public Result<Scoresheet> getSquadScoresheet(Sport sport, Level level, long ticketId, String squadName) {
        try {
            return new Result<Scoresheet>(mService.getSquadScoresheet(getSportPath(sport, level), ticketId, squadName));
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading squad scoresheet {ticket_id=" + ticketId + ", " + "squad_name=" + squadName + "}");
            return new Result<Scoresheet>(e);
        }
    }

    public Result<Scoresheet> getPlayerScoresheet(Sport sport, Level level, long ticketId, long playerId) {
        try {
            return new Result<Scoresheet>(mService.getPlayerScoresheet(getSportPath(sport, level), ticketId, playerId));
        } catch (RetrofitError e) {
            Log.e(TAG, "Error downloading player scoresheet {ticket_id=" + ticketId + ", " + "player_id=" + playerId + "}");
            return new Result<Scoresheet>(e);
        }
    }

    private String getSportPath(Sport sport, Level level) {
        switch (sport) {
            case BASEBALL:
                switch (level) {
                    case PROFESSIONAL:
                        return PATH_MLB;
                    default:
                        throw new UnsupportedSportException(getSportExceptionMessage(sport, level));
                }
            case FOOTBALL:
                switch (level) {
                    case PROFESSIONAL:
                        return PATH_NFL;
                    default:
                        throw new UnsupportedSportException(getSportExceptionMessage(sport, level));
                }
            default:
                throw new UnsupportedSportException(getSportExceptionMessage(sport, level));
        }
    }

    private String getSportExceptionMessage(Sport sport, Level level) {
        final StackTraceElement[] ste = Thread.currentThread().getStackTrace();
        String methodName = ste[ste.length - 3].getMethodName();
        return "Sport '" + sport.name() + "' and level '" + level.name() + "' is not implemented for " + methodName;
    }

    public class UnsupportedSportException extends RuntimeException {

        public UnsupportedSportException(String message) {
            super(message);
        }
    }
}
