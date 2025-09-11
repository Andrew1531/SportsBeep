package com.sportsbeep.app.test.ui;

import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.contest.Contest;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.network.params.ContestsParams;
import com.sportsbeep.app.storage.GameDaoHelper;
import com.sportsbeep.app.test.BaseActivityInstrumentationTestCase;
import com.sportsbeep.app.test.model.ContestTest;
import com.sportsbeep.app.test.model.GameTest;
import com.sportsbeep.app.ui.contest.ContestActivity;
import com.sportsbeep.app.ui.contest.ContestListFragment;

import java.text.ParseException;
import java.util.Collections;
import java.util.List;

import javax.inject.Inject;

import static org.mockito.Mockito.any;
import static org.mockito.Mockito.when;

public class ContestActivityTest extends BaseActivityInstrumentationTestCase<ContestActivity, ContestListFragment> {

    @Inject
    GameDaoHelper mGameDaoHelper;

    public ContestActivityTest() {
        super(ContestActivity.class);
    }

    @Override
    protected void setUp() throws Exception {
        super.setUp();

    }

    public void testTitle() throws ParseException {
        mockSingletonContestCall();

        assertTrue(getSolo().waitForText("MY CONTESTS"));
    }

    public void testTabsDisplayed() throws ParseException {
        mockSingletonContestCall();

        assertTrue(getSolo().waitForText("LIVE CONTESTS"));
        assertTrue(getSolo().waitForText("UPCOMING CONTESTS"));
        assertTrue(getSolo().waitForText("CONTESTS HISTORY"));
        assertTrue(getSolo().waitForText("INCOMPLETE CONTESTS"));
    }

    public void testEmptyList() {
        mockEmptyContestCall();

        assertTrue(getSolo().waitForText("No contests."));
    }

    public void mockSingletonContestCall() throws ParseException {
        when(getNetworkClient().getContests(any(Sport.class), any(Level.class), any(ContestsParams.ContestStatus.class)))
                .thenReturn(new Result<List<Contest>>(Collections.singletonList(ContestTest.getTestContest())));
        mockGameDatabaseCall();
    }

    public void mockEmptyContestCall() {
        when(getNetworkClient().getContests(any(Sport.class), any(Level.class), any(ContestsParams.ContestStatus.class)))
                .thenReturn(new Result<List<Contest>>(Collections.<Contest>emptyList()));
    }

    public void mockGameDatabaseCall() throws ParseException {
        when(mGameDaoHelper.getGame(any(Game.class))).thenReturn(GameTest.getTestGame());
    }
}
