package com.sportsbeep.timerapi.app;

import android.content.res.Resources;

public class Url_TicketTimerStatesGet
{
    private int ticketNumber;
    private int seconds;
    private int precision;
    private String url;

    public int getTicketNumber() { return this.ticketNumber; }
    public int getSeconds() { return this.seconds; }
    public int getPrecision() { return this.precision; }
    public String getUrl() { return this.url; }

    public Url_TicketTimerStatesGet(Resources r, int ticketNumber, int seconds, int precision)
    {
        this.ticketNumber = ticketNumber;
        this.seconds = seconds;
        this.precision = precision;
        this.url = r.getString(R.string.url_base_ticket_timer_states_get)
                .replace(":ticket_number", Integer.toString(ticketNumber))
                .replace(":seconds", Integer.toString(seconds))
                .replace(":precision", Integer.toString(precision));
    }
}
