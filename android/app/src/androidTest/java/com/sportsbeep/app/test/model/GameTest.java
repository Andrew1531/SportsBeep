package com.sportsbeep.app.test.model;

import com.google.gson.Gson;

import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.game.GameList;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.module.NetworkModule;
import com.sportsbeep.app.util.ISODateAdapter;

import junit.framework.TestCase;

import java.text.ParseException;

public class GameTest extends TestCase {

    private static final String JSON = "{\n"
            + "  \"games\": [\n"
            + "    {\n"
            + "      \"id\": 1,\n"
            + "      \"start_time\": \"2014-06-29T05:17:15Z\",\n"
            + "      \"home_team\": {\n"
            + "        \"id\": 1,\n"
            + "        \"market\": \"HOME_MARKET\",\n"
            + "        \"name\": \"HOME_NAME\",\n"
            + "        \"abbr\": \"QC\",\n"
            + "        \"wins\": \"0\",\n"
            + "        \"losses\": \"0\",\n"
            + "        \"average_hr_per_game\": \"0\",\n"
            + "        \"primary_color\": \"#ff000000\",\n"
            + "        \"secondary_color\": \"#111111\"\n"
            + "      },\n"
            + "      \"away_team\": {\n"
            + "        \"id\": 2,\n"
            + "        \"market\": \"AWAY_MARKET\",\n"
            + "        \"name\": \"AWAY_NAME\",\n"
            + "        \"abbr\": \"RM\",\n"
            + "        \"wins\": \"0\",\n"
            + "        \"losses\": \"0\",\n"
            + "        \"average_hr_per_game\": \"0\",\n"
            + "        \"primary_color\": \"#222222\",\n"
            + "        \"secondary_color\": \"#333333\"\n"
            + "      }\n"
            + "    }\n"
            + "  ]\n"
            + "}";

    public static Game getTestGame() throws ParseException {
        Game game = new Game();
        game.setId(1);
        game.setStartTime(ISODateAdapter.ISO_8601_FORMAT.parse("2014-06-29T05:17:15Z"));

        Team team = new Team();
        team.setId(1);
        team.setAbbr("QC");
        team.setName("HOME_NAME");
        team.setMarket("HOME_MARKET");
        team.setWins("0");
        team.setLosses("0");
        team.setAverageHrPerGame("0");
        team.setPrimaryColor(0xff000000);
        team.setSecondaryColor(0x111111);

        game.setHomeTeam(team);

        team = new Team();
        team.setId(2);
        team.setAbbr("RM");
        team.setName("AWAY_NAME");
        team.setMarket("AWAY_MARKET");
        team.setWins("0");
        team.setLosses("0");
        team.setAverageHrPerGame("0");
        team.setPrimaryColor(0x222222);
        team.setSecondaryColor(0x333333);

        game.setAwayTeam(team);

        return game;
    }

    public void testParse() throws ParseException {
        Gson gson = NetworkModule.createGsonForConverter();
        GameList games = gson.fromJson(JSON, GameList.class);
        Game game = games.getGames().get(0);
        Game testGame = getTestGame();

        assertEquals(game, testGame);
    }
}
