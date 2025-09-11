package com.sportsbeep.app.test.model;

import com.google.gson.Gson;

import com.sportsbeep.app.enumeration.Position;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.module.NetworkModule;

import junit.framework.TestCase;

public class PlayerTest extends TestCase {

    private static final String JSON = "{\n"
            + "\"id\":550,\n"
            + "\"name\":\"Ryan Doumit\",\n"
            + "\"number\":4,\n"
            + "\"position\":\"C\",\n"
            + "\"team\":{\n"
            + "\"id\":26\n"
            + "}\n"
            + "}";

    private static Player getTestPlayer() {
        Player player = new Player();
        player.setId(550);
        player.setName("Ryan Doumit");
        player.setNumber(4);
        player.setPosition(Position.Catcher);

        Team team = new Team();
        team.setId(26);
        player.setTeam(team);

        return player;
    }

    public void testParse() {
        Gson gson = NetworkModule.createGsonForConverter();
        Player player = gson.fromJson(JSON, Player.class);
        Player testPlayer = getTestPlayer();

        assertEquals(player, testPlayer);
    }
}
