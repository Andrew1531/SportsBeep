package com.sportsbeep.app.network;

import com.sportsbeep.app.model.contest.Contest;
import com.sportsbeep.app.model.contest.ContestList;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.game.GameList;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.model.player.PlayerList;
import com.sportsbeep.app.model.player.stats.Stats;
import com.sportsbeep.app.model.pool.PoolResponse;
import com.sportsbeep.app.model.question.AnswerList;
import com.sportsbeep.app.model.question.QuestionList;
import com.sportsbeep.app.model.question.TimerStateList;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.model.team.TeamList;
import com.sportsbeep.app.model.team.TeamRankingList;
import com.sportsbeep.app.model.ticket.Scoresheet;
import com.sportsbeep.app.model.ticket.Ticket;
import com.sportsbeep.app.model.ticket.TicketLeaguePick;
import com.sportsbeep.app.model.ticket.TicketList;
import com.sportsbeep.app.model.ticket.TicketPositions;
import com.sportsbeep.app.model.user.PhotoResponse;
import com.sportsbeep.app.model.user.User;
import com.sportsbeep.app.network.params.AnswerParams;
import com.sportsbeep.app.network.params.ContestsParams;
import com.sportsbeep.app.network.params.CreateAccountParams;
import com.sportsbeep.app.network.params.PutDeviceTokenParams;
import com.sportsbeep.app.network.params.PutFavoriteTeamParams;
import com.sportsbeep.app.network.params.RemoveAvatarParams;
import com.sportsbeep.app.network.params.SignInParams;
import com.sportsbeep.app.network.params.ticket.CreateTicketParams;
import com.sportsbeep.app.network.params.ticket.UpdateTicketParams;
import com.sportsbeep.app.util.typed.TypedUri;

import retrofit.http.Body;
import retrofit.http.GET;
import retrofit.http.Multipart;
import retrofit.http.POST;
import retrofit.http.PUT;
import retrofit.http.Part;
import retrofit.http.Path;
import retrofit.http.Query;

public interface NetworkService {

    @POST("/api/users/login")
    User signIn(@Body SignInParams apiUser);

    @POST("/api/users")
    User createAccount(@Body CreateAccountParams apiUser);

    @PUT("/api/users")
    Void putDeviceToken(@Body PutDeviceTokenParams apiUser);

    @Multipart
    @PUT("/api/users")
    PhotoResponse updateAvatar(@Part("api_user[avatar]") TypedUri avatar);

    @PUT("/api/users")
    PhotoResponse removeAvatar(@Body RemoveAvatarParams apiUser);

    @GET("/api/{sport}/teams")
    TeamList getTeams(@Path("sport") String sport);

    @GET("/api/{sport}/teams/{id}")
    Team getTeam(@Path("sport") String sport, @Path("id") long teamId);

    @GET("/api/{sport}/teams/{id}/rankings")
    TeamRankingList getTeamRankings(@Path("sport") String sport, @Path("id") long teamId);

    @PUT("/api/favorite_team")
    Void putFavoriteTeam(@Body PutFavoriteTeamParams favoriteTeam);

    @GET("/api/{sport}/games")
    GameList getGames(@Path("sport") String sport);

    @GET("/api/{sport}/games")
    GameList getGames(@Path("sport") String sport, @Query("days") int days);

    @GET("/api/{sport}/games/{id}")
    Game getGame(@Path("sport") String sport, @Path("id") long gameId);

    @GET("/api/{sport}/games/{id}/players")
    PlayerList getPlayersForGame(@Path("sport") String sport, @Path("id") long gameId);

    @GET("/api/{sport}/players/{id}")
    Player getPlayer(@Path("sport") String sport, @Path("id") long playerId);

    @GET("/api/{sport}/players/{id}/stats")
    Stats getStatsForPlayers(@Path("sport") String sport, @Path("id") long playerId);

    @GET("/api/{sport}/games/{id}/league_picks")
    GameList getLeaguePicks(@Path("sport") String sport, @Path("id") long gameId);

    @GET("/api/{sport}/games/{id}/pools")
    PoolResponse getPools(@Path("sport") String sport, @Path("id") long gameId);

    @POST("/api/{sport}/tickets")
    Ticket createTicket(@Path("sport") String sport, @Body CreateTicketParams ticket);

    @PUT("/api/{sport}/tickets/{id}")
    Void updateTicket(@Path("sport") String sport, @Path("id") long ticketId, @Body UpdateTicketParams ticket);

    @GET("/api/{sport}/tickets/{id}")
    Ticket getTicket(@Path("sport") String sport, @Path("id") long ticketId);

    @GET("/api/{sport}/tickets/{id}/players")
    TicketPositions getPositionsForTicket(@Path("sport") String sport, @Path("id") long ticketId);

    @GET("/api/{sport}/tickets/{ticket_id}/squads/{squad_name}")
    Scoresheet getSquadScoresheet(@Path("sport") String sport, @Path("ticket_id") long ticketId, @Path("squad_name") String squadName);

    @GET("/api/{sport}/tickets/{ticket_id}/players/{player_id}/scoresheet")
    Scoresheet getPlayerScoresheet(@Path("sport") String sport, @Path("ticket_id") long ticketId, @Path("player_id") long playerId);

    @GET("/api/{sport}/tickets/{id}/questions")
    QuestionList getTicketQuestions(@Path("sport") String sport, @Path("id") long ticketId);

    @GET("/api/{sport}/tickets/{id}/answers")
    AnswerList getTicketAnswers(@Path("sport") String sport, @Path("id") long ticketId);

    @POST("/api/{sport}/tickets/{id}/answers")
    Void submitTicketAnswers(@Path("sport") String sport, @Path("id") long ticketId, @Body AnswerParams answers);

    @GET("/api/{sport}/tickets/{id}/league_pick")
    TicketLeaguePick getTicketLeaguePick(@Path("sport") String sport, @Path("id") long ticketId);

    @GET("/api/{sport}/tickets/{id}/timer_states")
    TimerStateList getTimerStates(@Path("sport") String sport, @Path("id") long ticketId);

    @GET("/api/{sport}/contests")
    ContestList getContests(@Path("sport") String sport, @Query("status") ContestsParams.ContestStatus status);

    @GET("/api/{sport}/contests/{id}")
    Contest getContest(@Path("sport") String sport, @Path("id") long contestId);

    @GET("/api/{sport}/contests/{id}/tickets")
    TicketList getTickets(@Path("sport") String sport, @Path("id") long contestId, @Query("avatar_size") String avatarSize);
}
