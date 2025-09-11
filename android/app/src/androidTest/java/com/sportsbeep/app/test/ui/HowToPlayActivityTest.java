package com.sportsbeep.app.test.ui;

import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.test.BaseActivityInstrumentationTestCase;
import com.sportsbeep.app.test.model.GameTest;
import com.sportsbeep.app.ui.game.pickgame.PickGameActivity;
import com.sportsbeep.app.ui.tutorial.HowToPlayActivity;
import com.sportsbeep.app.ui.tutorial.HowToPlayFragment;

import java.text.ParseException;
import java.util.Collections;
import java.util.List;

import static org.mockito.Mockito.any;
import static org.mockito.Mockito.when;

public class HowToPlayActivityTest extends BaseActivityInstrumentationTestCase<HowToPlayActivity, HowToPlayFragment> {

    public HowToPlayActivityTest() {
        super(HowToPlayActivity.class);
    }

    public void testCloseButton() throws ParseException {
        when(getNetworkClient().getGames(any(Sport.class), any(Level.class))).thenReturn(new Result<List<Game>>(Collections.singletonList(GameTest.getTestGame())));
        getSolo().clickOnText("CLOSE");
        getSolo().waitForActivity(PickGameActivity.class);
    }
}
