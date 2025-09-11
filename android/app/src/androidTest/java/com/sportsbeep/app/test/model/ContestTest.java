package com.sportsbeep.app.test.model;

import com.google.gson.Gson;

import com.sportsbeep.app.model.user.User;
import com.sportsbeep.app.model.contest.Contest;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.ticket.Ticket;
import com.sportsbeep.app.module.NetworkModule;

import junit.framework.TestCase;

import java.text.ParseException;

public class ContestTest extends TestCase {

    private static final String JSON = "{\n"
            + "      \"id\": 1,\n"
            + "      \"game\": {\n"
            + "        \"id\": 1\n"
            + "      },\n"
            + "      \"ticket\": {\n"
            + "        \"id\": 1,\n"
            + "        \"score\": \"8.0\",\n"
            + "        \"prize_pool\": 24,\n"
            + "        \"placing\": 1,\n"
            + "        \"user\": {\n"
            + "          \"username\": \"user-f4e1ef117ad6ab8907df2da8fb617b27\"\n"
            + "        },\n"
            + "        \"contest\": {\n"
            + "          \"id\": 1\n"
            + "        },\n"
            + "        \"best_or_bust_score\": \"0.0\"\n"
            + "      }\n"
            + "    }";

    public static Contest getTestContest() throws ParseException {

        Contest contest = new Contest();

        contest.setId(1);

        Ticket ticket = new Ticket();
        ticket.setId(1);
        ticket.setScore("8.0");
        ticket.setPrizePool(24);
        ticket.setPlacing(1);

        User user = new User();
        user.setUsername("user-f4e1ef117ad6ab8907df2da8fb617b27");
        ticket.setUser(user);

        Contest ticketContest = new Contest();
        ticketContest.setId(1);
        ticket.setContest(ticketContest);

        ticket.setBestOrBustScore("0.0");

        contest.setTicket(ticket);

        Game contestGame = new Game();
        contestGame.setId(1);
        contest.setGame(contestGame);

        return contest;
    }

    public void testParse() throws ParseException {

        Gson gson = NetworkModule.createGsonForConverter();
        Contest contest = gson.fromJson(JSON, Contest.class);
        Contest testContest = getTestContest();

        assertEquals(contest, testContest);
    }

}
