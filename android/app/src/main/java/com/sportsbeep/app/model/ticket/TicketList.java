package com.sportsbeep.app.model.ticket;

import java.util.List;

public class TicketList {

    private List<Ticket> tickets;

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        TicketList that = (TicketList) o;

        if (tickets != null ? !tickets.equals(that.tickets) : that.tickets != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        return tickets != null ? tickets.hashCode() : 0;
    }

    public List<Ticket> getTickets() {
        return tickets;
    }

    public void setTickets(List<Ticket> tickets) {
        this.tickets = tickets;
    }
}
