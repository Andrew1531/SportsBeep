package com.sportsbeep.app.test.model;

import com.google.gson.Gson;

import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.module.NetworkModule;

import junit.framework.TestCase;

public class TeamTest extends TestCase {

    private static final String JSON = "{\n"
            + "      \"id\": 1,\n"
            + "      \"market\": \"Merlinview\",\n"
            + "      \"name\": \"Lia Hartmann Jr.\",\n"
            + "      \"abbr\": \"BL\",\n"
            + "      \"wins\": \"0\",\n"
            + "      \"losses\": \"0\",\n"
            + "      \"average_hr_per_game\": \"0\",\n"
            + "      \"primary_color\": \"#9ab74e\",\n"
            + "      \"secondary_color\": \"#ff000000\"\n"
            + "    }";

    public static Team getTestModel() {
        Team team = new Team();
        team.setId(1);
        team.setMarket("Merlinview");
        team.setName("Lia Hartmann Jr.");
        team.setAbbr("BL");
        team.setWins("0");
        team.setLosses("0");
        team.setAverageHrPerGame("0");
        team.setPrimaryColor(0x9ab74e);
        team.setSecondaryColor(0xff000000);

        return team;
    }

    public void testParse() {
        Gson gson = NetworkModule.createGsonForConverter();
        Team team = gson.fromJson(JSON, Team.class);
        Team testTeam = getTestModel();

        assertEquals(team, testTeam);
    }
}
