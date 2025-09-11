package com.sportsbeep.app.network.params.ticket;

import java.util.Collection;

public class LeaguePickTicketParams extends TicketParams {

    private long leaguePickGameId;

    private long leaguePickTeamId;

    public LeaguePickTicketParams(Collection<TicketPositionParam> players, Collection<TicketPositionParam> squads, long leaguePickGameId, long leaguePickTeamId) {
        super(players, squads);
        this.leaguePickGameId = leaguePickGameId;
        this.leaguePickTeamId = leaguePickTeamId;
    }

    public long getLeaguePickGameId() {
        return leaguePickGameId;
    }

    public void setLeaguePickGameId(long leaguePickGameId) {
        this.leaguePickGameId = leaguePickGameId;
    }

    public long getLeaguePickTeamId() {
        return leaguePickTeamId;
    }

    public void setLeaguePickTeamId(long leaguePickTeamId) {
        this.leaguePickTeamId = leaguePickTeamId;
    }
}
