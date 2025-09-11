package com.sportsbeep.app.network.params.ticket;

public class CreateTicketParams {

    private TicketParams ticket;

    private long gameId;

    private long poolId;

    public CreateTicketParams(TicketParams ticket, long gameId, long poolId) {
        this.ticket = ticket;
        this.gameId = gameId;
        this.poolId = poolId;
    }

    public long getPoolId() {
        return poolId;
    }

    public void setPoolId(long poolId) {
        this.poolId = poolId;
    }

    public long getGameId() {
        return gameId;
    }

    public void setGameId(long gameId) {
        this.gameId = gameId;
    }

    public TicketParams getTicket() {
        return ticket;
    }

    public void setTicket(TicketParams ticket) {
        this.ticket = ticket;
    }
}
