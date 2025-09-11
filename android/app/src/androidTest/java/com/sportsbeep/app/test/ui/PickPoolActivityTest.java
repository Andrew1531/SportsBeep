package com.sportsbeep.app.test.ui;

import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.game.GamePosition;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.model.pool.Pool;
import com.sportsbeep.app.model.pool.PoolResponse;
import com.sportsbeep.app.model.ticket.IncompleteTicket;
import com.sportsbeep.app.test.BaseActivityInstrumentationTestCase;
import com.sportsbeep.app.test.model.GameTest;
import com.sportsbeep.app.test.model.PoolTest;
import com.sportsbeep.app.ui.game.pickgame.PickGameActivity;
import com.sportsbeep.app.ui.game.pool.PickPoolActivity;
import com.sportsbeep.app.ui.game.pool.PickPoolFragment;

import android.content.Intent;
import android.widget.ListView;

import java.text.ParseException;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

import static org.mockito.Matchers.any;
import static org.mockito.Matchers.anyLong;
import static org.mockito.Mockito.when;

public class PickPoolActivityTest
        extends BaseActivityInstrumentationTestCase<PickPoolActivity, PickPoolFragment> {

    public PickPoolActivityTest() {
        super(PickPoolActivity.class);
    }

    @Override
    protected void setUp() throws Exception {
        super.setUp();

        Intent i = new Intent();
        IncompleteTicket ticket = new IncompleteTicket();
        ticket.setGame(GameTest.getTestGame());
        ticket.setPositionMap(getTestPlayers());
        i.putExtra(PickPoolActivity.EXTRA_TICKET, ticket);
        setActivityIntent(i);
    }

    @Override
    protected void tearDown() throws Exception {
        super.tearDown();
        getInstrumentation().addMonitor(getSolo().getActivityMonitor());
    }

    private HashMap<GamePosition, Object> getTestPlayers() throws ParseException {
        HashMap<GamePosition, Object> players = new HashMap<GamePosition, Object>();
        List<GamePosition> gamePositions = Arrays.asList(Sport.BASEBALL.getGamePositions());
        int i = 1;
        for (GamePosition gamePosition : gamePositions) {
            Player player = new Player();
            player.setId(i++);
            players.put(gamePosition, new Player());
        }

        return players;
    }

    public void testPoolsDisplayed() {
        mockPoolResults(PoolTest.getTestPool());

        ListView lv = getSolo().getView(ListView.class, 0);
        assertEquals(1, lv.getChildCount());
    }

    public void testTextFormatted() {
        Pool pool = new Pool();
        pool.setEntryFee(550);
        pool.setPrizePool(5000);
        mockPoolResults(pool);

        assertTrue(getSolo().waitForText("\\$550.00 TO ENTER A \\$5,000 POOL"));
    }

    public void testTextFree() {
        Pool pool = new Pool();
        pool.setEntryFee(0);
        pool.setPrizePool(0);
        mockPoolResults(pool);

        assertTrue(getSolo().waitForText("PLAY FOR FREE"));
    }

    public void testCommitDialogDisplayed() {
        mockPoolResults(PoolTest.getTestPool());
        getSolo().clickInList(0);

        assertTrue(getSolo().waitForFragmentByTag(PickPoolActivity.TAG_READY_CONTEST));
    }

    public void testCommitDialogCancelShowsSaveDialog() {
        mockPoolResults(PoolTest.getTestPool());
        PickPoolActivity activity = getActivity();
        activity.showReadyContestDialog(PoolTest.getTestPool());

        assertTrue(getSolo().waitForFragmentByTag(PickPoolActivity.TAG_READY_CONTEST));

        getSolo().clickOnText("CANCEL");
        assertTrue(getSolo().waitForFragmentByTag(PickPoolActivity.TAG_SAVE_CONTEST));
    }

    public void testSaveDialogDisplayed() {
        mockPoolResults(PoolTest.getTestPool());
        PickPoolActivity activity = getActivity();
        activity.showSaveContestDialog();

        assertTrue(getSolo().waitForFragmentByTag(PickPoolActivity.TAG_SAVE_CONTEST));
        assertTrue(getSolo().searchText("CONTINUE IT"));
        assertTrue(getSolo().searchText("SAVE IT"));
        assertTrue(getSolo().searchText("CANCEL IT"));
    }

    public void testBalanceDisplayed() {
        mockPoolResults(PoolTest.getTestPool());

        assertTrue(getSolo().waitForText("\\$55.44"));
    }

    public void testCancelIt() throws ParseException {
        mockPoolResults(PoolTest.getTestPool());
        PickGameActivityTest.mockSuccessfulResponse(getNetworkClient());

        PickPoolActivity activity = getActivity();
        activity.showSaveContestDialog();

        getSolo().clickOnText("CANCEL IT");

        assertTrue(getSolo().waitForActivity(PickGameActivity.class));
    }

    public void testContinueIt() {
        mockPoolResults(PoolTest.getTestPool());
        BuildTeamActivityTest.mockSuccessfulPlayersResponse(getNetworkClient());

        PickPoolActivity activity = getActivity();
        activity.showSaveContestDialog();

        // TODO: This will crash as the BuildTeamActivity requires an Intent extra, which I don't know how to inject
        // getSolo().clickOnText("CONTINUE IT");
    }

    private void mockPoolResults(Pool pool) {
        PoolResponse response = new PoolResponse();
        response.setPools(Collections.singletonList(pool));
        response.setBalance("$55.44");
        when(getNetworkClient().getPools(any(Sport.class), any(Level.class), anyLong()))
                .thenReturn(new Result<PoolResponse>(response));
    }
}