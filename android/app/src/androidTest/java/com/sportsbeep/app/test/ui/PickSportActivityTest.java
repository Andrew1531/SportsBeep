package com.sportsbeep.app.test.ui;

import com.sportsbeep.app.R;
import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.network.NetworkClient;
import com.sportsbeep.app.test.BaseActivityInstrumentationTestCase;
import com.sportsbeep.app.test.model.GameTest;
import com.sportsbeep.app.ui.game.pickgame.PickGameActivity;
import com.sportsbeep.app.ui.sport.PickSportActivity;
import com.sportsbeep.app.ui.sport.PickSportFragment;

import android.widget.Button;

import java.text.ParseException;
import java.util.Collections;
import java.util.List;

import javax.inject.Inject;

import static org.mockito.Matchers.any;
import static org.mockito.Mockito.when;

public class PickSportActivityTest
        extends BaseActivityInstrumentationTestCase<PickSportActivity, PickSportFragment> {

    @Inject
    NetworkClient mNetworkClient;

    public PickSportActivityTest() {
        super(PickSportActivity.class);
    }

    public void testEnterNoOptions() {
        Button enter = (Button) getActivity().findViewById(R.id.enter_Button);
        assertFalse(enter.isEnabled());
    }

    public void testLevelEnter() {
        Button enter = (Button) getActivity().findViewById(R.id.enter_Button);

        getSolo().clickOnButton("PROFESSIONAL");
        assertTrue(getSolo().isRadioButtonChecked("PROFESSIONAL"));
        assertFalse(enter.isEnabled());
    }

    public void testSportEnter() {
        Button enter = (Button) getActivity().findViewById(R.id.enter_Button);

        getSolo().clickOnButton("FOOTBALL");
        assertTrue(getSolo().isRadioButtonChecked("FOOTBALL"));
        assertFalse(enter.isEnabled());
    }

    public void testEnterEnable() {
        Button enter = (Button) getActivity().findViewById(R.id.enter_Button);

        getSolo().waitForText("PROFESSIONAL");

        getSolo().clickOnButton("PROFESSIONAL");
        getSolo().clickOnButton("FOOTBALL");
        assertTrue(getSolo().isRadioButtonChecked("FOOTBALL"));
        assertTrue(getSolo().isRadioButtonChecked("PROFESSIONAL"));
        assertTrue(enter.isEnabled());
    }

    public void testProfessionalBaseball() throws ParseException {

        Game game = GameTest.getTestGame();
        Result<List<Game>> result = new Result<List<Game>>(Collections.singletonList(game));

        when(mNetworkClient.getGames(any(Sport.class), any(Level.class))).thenReturn(result);

        getSolo().clickOnButton("PROFESSIONAL");
        getSolo().clickOnButton("BASEBALL");

        assertTrue(getSolo().isRadioButtonChecked("PROFESSIONAL"));
        assertTrue(getSolo().isRadioButtonChecked("BASEBALL"));

        getSolo().clickOnButton("ENTER");

        assertTrue(getSolo().waitForActivity(PickGameActivity.class));
    }

    public void testCollegeFootball() throws ParseException {

        Game game = GameTest.getTestGame();
        Result<List<Game>> result = new Result<List<Game>>(Collections.singletonList(game));

        when(mNetworkClient.getGames(any(Sport.class), any(Level.class))).thenReturn(result);

        getSolo().clickOnButton("COLLEGE");
        getSolo().clickOnButton("FOOTBALL");

        assertTrue(getSolo().isRadioButtonChecked("COLLEGE"));
        assertTrue(getSolo().isRadioButtonChecked("FOOTBALL"));

        getSolo().clickOnButton("ENTER");

        assertTrue(getSolo().waitForActivity(PickGameActivity.class));
    }

    public void testInternationalHockey() throws ParseException {

        Game game = GameTest.getTestGame();
        Result<List<Game>> result = new Result<List<Game>>(Collections.singletonList(game));

        when(mNetworkClient.getGames(any(Sport.class), any(Level.class))).thenReturn(result);

        getSolo().clickOnButton("INTERNATIONAL");
        getSolo().clickOnButton("HOCKEY");

        assertTrue(getSolo().isRadioButtonChecked("INTERNATIONAL"));
        assertTrue(getSolo().isRadioButtonChecked("HOCKEY"));

        getSolo().clickOnButton("ENTER");

        assertTrue(getSolo().waitForActivity(PickGameActivity.class));
    }
}
