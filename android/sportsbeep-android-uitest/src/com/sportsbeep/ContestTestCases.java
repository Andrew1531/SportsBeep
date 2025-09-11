package com.sportsbeep;

import com.android.uiautomator.core.UiObject;
import com.android.uiautomator.core.UiObjectNotFoundException;
import com.android.uiautomator.core.UiSelector;

public class ContestTestCases extends TestCaseHelper {

    @Override
    protected void setUp() throws UiObjectNotFoundException {

        super.setUp();
        selectProBaseball();
    }

    public void testA_ViewContestCategories() throws UiObjectNotFoundException {

        //SBA-111
        logMessage("Starting testA_ViewContestCategories");
        buildTeam(1);

        logMessage("Click slide up menu");
        UiObject menu_button = new UiObject( new UiSelector().resourceId( resourcePrefix + "dragView" ) );
        menu_button.click();
        sleep( 1000 );
        logMessage("Click on my contests button");
        UiObject my_contests_button = new UiObject( new UiSelector().resourceId( resourcePrefix + "myContests_FontTextView" ) );
        my_contests_button.click();

        //existence of elements
        UiObject live_contest_btn = new UiObject(new UiSelector().resourceId(resourcePrefix + "live_contest_button"));
        UiObject upcoming_contest_btn = new UiObject(new UiSelector().resourceId(resourcePrefix + "upcoming_contest_button"));
        UiObject contest_history_btn = new UiObject(new UiSelector().resourceId(resourcePrefix + "contest_history_button"));
        UiObject incomplete_contest_btn = new UiObject(new UiSelector().resourceId(resourcePrefix + "incomplete_contest_button"));

        assertTrue("Live contest button does not exist", live_contest_btn.exists());
        assertTrue("Upcoming contest button does not exist", upcoming_contest_btn.exists());
        assertTrue("Contest history button does not exist", contest_history_btn.exists());
        assertTrue("Incomplete contest button does not exist", incomplete_contest_btn.exists());

        logMessage("Clicking upcoming contests button");
        upcoming_contest_btn.click();
        sleep( 2000 );
        UiObject first_upcoming_contest = new UiObject(new UiSelector().textStartsWith( "Start time" ));
        assertTrue("Upcoming contest does not exist", first_upcoming_contest.exists());

        logMessage("End of contest view test.");

    }

    @Override
    protected void tearDown() throws UiObjectNotFoundException {

        logMessage("Tearing down from test");
        logout();
    }


}
