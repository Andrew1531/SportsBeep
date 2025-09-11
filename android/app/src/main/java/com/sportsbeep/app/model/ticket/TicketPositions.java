package com.sportsbeep.app.model.ticket;

import java.util.List;

public class TicketPositions {

    private List<TicketPlayer> players;

    private List<TicketSquad> squads;

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        TicketPositions that = (TicketPositions) o;

        if (players != null ? !players.equals(that.players) : that.players != null) {
            return false;
        }
        if (squads != null ? !squads.equals(that.squads) : that.squads != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        int result = players != null ? players.hashCode() : 0;
        result = 31 * result + (squads != null ? squads.hashCode() : 0);
        return result;
    }

    public List<TicketPlayer> getPlayers() {
        return players;
    }

    public void setPlayers(List<TicketPlayer> players) {
        this.players = players;
    }

    public List<TicketSquad> getSquads() {
        return squads;
    }

    public void setSquads(List<TicketSquad> squads) {
        this.squads = squads;
    }
}
