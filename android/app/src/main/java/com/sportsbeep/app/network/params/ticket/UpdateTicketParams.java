package com.sportsbeep.app.network.params.ticket;

public class UpdateTicketParams {

    private TicketParams ticket;

    public UpdateTicketParams(TicketParams ticket) {
        this.ticket = ticket;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        UpdateTicketParams that = (UpdateTicketParams) o;

        if (ticket != null ? !ticket.equals(that.ticket) : that.ticket != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        return ticket != null ? ticket.hashCode() : 0;
    }

    public TicketParams getTicket() {
        return ticket;
    }

    public void setTicket(TicketParams ticket) {
        this.ticket = ticket;
    }
}
