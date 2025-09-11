package com.sportsbeep.app.test.ui;

import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.game.GamePosition;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.network.NetworkClient;
import com.sportsbeep.app.test.BaseActivityInstrumentationTestCase;
import com.sportsbeep.app.test.model.GameTest;
import com.sportsbeep.app.ui.game.buildteam.BuildTeamActivity;
import com.sportsbeep.app.ui.game.buildteam.BuildTeamFragment;

import android.content.Intent;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;

import static org.mockito.Matchers.any;
import static org.mockito.Matchers.anyLong;
import static org.mockito.Mockito.when;

public class BuildTeamActivityTest
        extends BaseActivityInstrumentationTestCase<BuildTeamActivity, BuildTeamFragment> {

    private static final Game GAME;

    static {
        try {
            GAME = GameTest.getTestGame();
        } catch (ParseException e) {
            throw new RuntimeException(e);
        }
    }

    public BuildTeamActivityTest() {
        super(BuildTeamActivity.class);
    }

    public static void mockSuccessfulPlayersResponse(NetworkClient client) {
        Result<List<Player>> result = new Result<List<Player>>(new ArrayList<Player>());
        when(client.getPlayersForGame(any(Sport.class), any(Level.class), anyLong())).thenReturn(result);

        Result<List<Game>> leaguePicksResult = new Result<List<Game>>(new ArrayList<Game>());
        when(client.getLeaguePicks(any(Sport.class), any(Level.class), anyLong())).thenReturn(leaguePicksResult);
    }

    @Override
    protected void setUp() throws Exception {
        super.setUp();

        Intent intent = new Intent();
        intent.putExtra(BuildTeamActivity.EXTRA_GAME, GAME);
        setActivityIntent(intent);
    }

    public void testPositionsDisplayed() {
        mockSuccessfulPlayersResponse(getNetworkClient());

        GamePosition[] positions = Sport.BASEBALL.getGamePositions();
        for (GamePosition position : positions) {
            assertTrue(getSolo().waitForText(position.getPositionGroupTitle(getActivity())));
        }
    }
}
