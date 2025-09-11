package com.sportsbeep.app.test.ui;

import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.gcm.GCMManager;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.network.NetworkClient;
import com.sportsbeep.app.test.BaseActivityInstrumentationTestCase;
import com.sportsbeep.app.test.model.GameTest;
import com.sportsbeep.app.ui.game.buildteam.BuildTeamActivity;
import com.sportsbeep.app.ui.game.pickgame.PickGameActivity;
import com.sportsbeep.app.ui.game.pickgame.PickGameFragment;

import android.app.Activity;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import javax.inject.Inject;

import static org.mockito.Matchers.any;
import static org.mockito.Matchers.anyLong;
import static org.mockito.Mockito.when;

public class PickGameActivityTest extends BaseActivityInstrumentationTestCase<PickGameActivity, PickGameFragment> {

    @Inject
    GCMManager mGCMManager;

    public PickGameActivityTest() {
        super(PickGameActivity.class);
    }

    public static Game mockSuccessfulResponse(NetworkClient client) throws ParseException {
        Game game = GameTest.getTestGame();
        Result<List<Game>> result = new Result<List<Game>>(Collections.singletonList(game));

        when(client.getGames(any(Sport.class), any(Level.class))).thenReturn(result);

        return game;
    }

    private static String mockErrorResponse(NetworkClient client) {
        String error = "Error1234";
        Result<List<Game>> result = new Result<List<Game>>(error);

        when(client.getGames(any(Sport.class), any(Level.class))).thenReturn(result);

        return error;
    }

    private static void mockGCMManager(GCMManager gcmManager) {
        when(gcmManager.checkPlayServices(any(Activity.class))).thenReturn(true);
        when(gcmManager.getRegistrationId()).thenReturn("abc123");
    }

    public void testListDisplayed() throws ParseException {
        mockGCMManager(mGCMManager);
        Game game = mockSuccessfulResponse(getNetworkClient());

        assertTrue(getSolo().waitForText(game.getHomeTeam().getMarket()));
        assertTrue(getSolo().waitForText(game.getHomeTeam().getName()));
        assertTrue(getSolo().waitForText(game.getAwayTeam().getMarket()));
        assertTrue(getSolo().waitForText(game.getAwayTeam().getName()));
    }

    public void testListClickStartsActivity() throws ParseException {
        mockGCMManager(mGCMManager);
        mockSuccessfulResponse(getNetworkClient());

        Result<List<Player>> playerResult = new Result<List<Player>>(new ArrayList<Player>());
        when(getNetworkClient().getPlayersForGame(any(Sport.class), any(Level.class), anyLong())).thenReturn(playerResult);

        Result<List<Game>> leaguePickResult = new Result<List<Game>>(new ArrayList<Game>());
        when(getNetworkClient().getLeaguePicks(any(Sport.class), any(Level.class), anyLong())).thenReturn(leaguePickResult);

        getSolo().clickInList(1);
        assertTrue(getSolo().waitForActivity(BuildTeamActivity.class));
    }

    public void testErrorDisplayed() {
        mockGCMManager(mGCMManager);
        String error = mockErrorResponse(getNetworkClient());

        assertTrue(getSolo().waitForText(error));
    }

    public void testNavigationDrawer() throws ParseException {
        mockGCMManager(mGCMManager);
        mockSuccessfulResponse(getNetworkClient());

        getSolo().clickOnText("MENU BOX");
        assertTrue(getSolo().waitForText("PICK A GAME"));
    }
}
