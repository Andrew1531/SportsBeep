package com.sportsbeep.app.test.ui;

import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.question.Question;
import com.sportsbeep.app.model.question.TimerState;
import com.sportsbeep.app.test.BaseActivityInstrumentationTestCase;
import com.sportsbeep.app.test.model.GameTest;
import com.sportsbeep.app.test.model.QuestionListTest;
import com.sportsbeep.app.test.model.TimerStateListTest;
import com.sportsbeep.app.ui.game.questions.BestBustActivity;
import com.sportsbeep.app.ui.game.questions.CountDownFragment;

import android.content.Intent;
import android.os.Parcelable;
import android.test.FlakyTest;

import java.util.ArrayList;
import java.util.List;

public class BestBustActivityTest
        extends BaseActivityInstrumentationTestCase<BestBustActivity, CountDownFragment> {

    private Game mGame;

    private List<Question> mQuestionList;

    private List<TimerState> mTimerStateList;

    public BestBustActivityTest() {
        super(BestBustActivity.class);
    }

    @Override
    protected void setUp() throws Exception {
        super.setUp();
        mGame = GameTest.getTestGame();
        mQuestionList = QuestionListTest.getTestQuestionList();
        mTimerStateList = TimerStateListTest.getTestTimerStateList();

        Intent i = new Intent();
        i.putExtra(BestBustActivity.EXTRA_TICKET_ID, 1);
        i.putExtra(BestBustActivity.EXTRA_GAME, mGame);
        i.putParcelableArrayListExtra(BestBustActivity.EXTRA_QUESTIONS,
                new ArrayList<Parcelable>(mQuestionList));
        i.putParcelableArrayListExtra(BestBustActivity.EXTRA_TIMER_STATES,
                new ArrayList<Parcelable>(mTimerStateList));

        setActivityIntent(i);
    }

    @FlakyTest(tolerance = 3)
    public void testCountDown() {
        assertTrue(getSolo().waitForText("READY"));
        assertTrue(getSolo().waitForText("SET"));
        assertTrue(getSolo().waitForText("GO!"));
    }

    public void testQuestionDisplayed() throws Throwable {
        transitionToBestBustFragment();
        assertTrue(getSolo().waitForText(mQuestionList.get(0).getText()));
    }

    public void testGameDisplayed() throws Throwable {
        transitionToBestBustFragment();
        assertTrue(getSolo().waitForText(mGame.getHomeTeam().getMarket()));
        assertTrue(getSolo().waitForText(mGame.getHomeTeam().getName()));
        assertTrue(getSolo().waitForText(mGame.getAwayTeam().getMarket()));
        assertTrue(getSolo().waitForText(mGame.getAwayTeam().getName()));
    }

    public void testNextQuestionDisplayed() throws Throwable {
        transitionToBestBustFragment();
        getSolo().clickOnText(mGame.getHomeTeam().getMarket());
        assertTrue(getSolo().waitForText(mQuestionList.get(1).getText()));
    }

    private void transitionToBestBustFragment() throws Throwable {
        getActivity();
        runTestOnUiThread(new Runnable() {
            @Override
            public void run() {
                getActivity().onCountDownFinished();
            }
        });
    }
}
