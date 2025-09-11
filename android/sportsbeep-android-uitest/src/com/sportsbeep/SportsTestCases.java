package com.sportsbeep;

import com.android.uiautomator.core.UiObject;
import com.android.uiautomator.core.UiObjectNotFoundException;
import com.android.uiautomator.core.UiSelector;

public class SportsTestCases extends TestCaseHelper {

    @Override
    protected void setUp() throws UiObjectNotFoundException {

        logMessage( "Setting up for test" );
        login();
    }

    public void testA_SelectSportAndProfession() throws UiObjectNotFoundException {

        //SBA-265
        logMessage( "Starting testA_SelectSportAndProfession" );
        //existence of elements
        UiObject professional_btn = new UiObject( new UiSelector().resourceId( resourcePrefix + "professional_btn" ) );
        UiObject college_btn = new UiObject( new UiSelector().resourceId( resourcePrefix + "college_btn" ) );
        UiObject international_btn = new UiObject( new UiSelector().resourceId( resourcePrefix + "international_btn" ) );

        assertTrue( "professional button does not exist.", professional_btn.exists() );
        assertTrue( "college button does not exist.", college_btn.exists() );
        assertTrue( "international button does not exist.", international_btn.exists() );

        UiObject baseball_btn = new UiObject( new UiSelector().resourceId( resourcePrefix + "baseball_btn" ) );
        UiObject football_btn = new UiObject( new UiSelector().resourceId( resourcePrefix + "football_btn" ) );
        UiObject basketball_btn = new UiObject( new UiSelector().resourceId( resourcePrefix + "basketball_btn" ) );
        UiObject hockey_btn = new UiObject( new UiSelector().resourceId( resourcePrefix + "hockey_btn" ) );

        assertTrue( "baseball button does not exist.", baseball_btn.exists() );
        assertTrue( "football button does not exist.", football_btn.exists() );
        assertTrue( "basketball button does not exist.", basketball_btn.exists() );
        assertTrue( "hockey button does not exist.", hockey_btn.exists() );

        UiObject enter_btn = new UiObject( new UiSelector().resourceId( resourcePrefix + "enter_Button" ) );
        assertTrue( "enter button does not exist.", enter_btn.exists() );

        UiObject title = new UiObject( new UiSelector().text( "NEW GAME" ) );
        UiObject select_level_text = new UiObject( new UiSelector().text( "SELECT A LEVEL" ) );
        UiObject select_sport_text = new UiObject( new UiSelector().text( "SELECT A SPORT" ) );
        assertTrue( "title does not exist.", title.exists() );
        assertTrue( "select_level_text does not exist.", select_level_text.exists() );
        assertTrue( "select_sport_script does not exist.", select_sport_text.exists() );

        //proper behaviour 
        logMessage( "enter with no option selected" );
        enter_btn.click();
        sleep( 2000 );
        assertTrue( "enter without options lead to next screen.", title.exists() );

        logMessage( "enter with only baseball selected" );
        baseball_btn.click();
        enter_btn.click();
        sleep( 2000 );
        assertTrue( "enter with only sport lead to next screen.", title.exists() );

        logMessage( "enter with professional and baseball selected" );
        professional_btn.click();
        enter_btn.click();
        sleep( 2000 );
        assertFalse( "enter with sport and level did not lead to next screen.", title.exists() );

        //this can no longer be done since sport level is only picked after initial login.
        //can move to another suite or wait for setting
        //        //reset because option cant be unselected
        //        logMessage( "resetting" );
        //        logout();
        //        login();
        //
        //        logMessage( "enter with only professional selected" );
        //        professional_btn.click();
        //        enter_btn.click();
        //        sleep( 2000 );
        //        assertTrue( "enter with only level lead to next screen.", title.exists() );
        //
        //        logMessage( "enter with professional and baseball selected" );
        //        baseball_btn.click();
        //        enter_btn.click();
        //        sleep( 2000 );
        //        assertFalse( "enter with sport and level did not lead to next screen.", title.exists() );

        //on games list
        UiObject pick_prompt = new UiObject( new UiSelector().text( "PICK A GAME" ) );
        assertTrue( "Pick Game prompt does not exist.", pick_prompt.exists() );

        logMessage( "End of sport and level selection test." );

    }

}
