package com.sportsbeep.app.network.params.ticket;

import java.util.Collection;

public class TicketParams {

    private Collection<TicketPositionParam> players;

    private Collection<TicketPositionParam> squads;

    public TicketParams(Collection<TicketPositionParam> players, Collection<TicketPositionParam> squads) {
        this.players = players;
        this.squads = squads;
    }

    public Collection<TicketPositionParam> getPlayerIds() {
        return players;
    }

    public void setPlayerIds(Collection<TicketPositionParam> playerIds) {
        this.players = playerIds;
    }

    public Collection<TicketPositionParam> getSquads() {
        return squads;
    }

    public void setSquads(Collection<TicketPositionParam> squads) {
        this.squads = squads;
    }

    public static class TicketPositionParam {

        private long id;

        private String position;

        public TicketPositionParam(long id, String position) {
            this.id = id;
            this.position = position;
        }

        public String getPosition() {
            return position;
        }

        public void setPosition(String position) {
            this.position = position;
        }

        public long getId() {
            return id;
        }

        public void setId(long id) {
            this.id = id;
        }
    }
}
