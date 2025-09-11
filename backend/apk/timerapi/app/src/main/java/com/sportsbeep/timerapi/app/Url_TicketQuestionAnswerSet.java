package com.sportsbeep.timerapi.app;

import android.content.res.Resources;

import java.net.URLEncoder;

public class Url_TicketQuestionAnswerSet
{
    private int ticketNumber;
    private int questionNumber;
    private int answer;
    private String timerStateText;
    private String url;

    public int getTicketNumber() { return this.ticketNumber; }
    public int getQuestionNumber() { return this.questionNumber; }
    public int getAnswer() { return this.answer; }
    public String getTimerStateText() { return this.timerStateText; }
    public String getUrl() { return this.url; }

    public Url_TicketQuestionAnswerSet(Resources r, int ticketNumber, int questionNumber, int answer, String timerStateText)
    {
        this.ticketNumber = ticketNumber;
        this.questionNumber = questionNumber;
        this.answer = answer;
        this.timerStateText = timerStateText;
        this.url = r.getString(R.string.url_base_ticket_question_answer_set)
                .replace(":ticket_number", Integer.toString(ticketNumber))
                .replace(":question_number", Integer.toString(questionNumber))
                .replace(":answer", Integer.toString(answer))
                .replace(":timer_state_text", timerStateText.replace("/", "%2F").replace("+", "%2B").replace("=", "%3D"));
    }
}
