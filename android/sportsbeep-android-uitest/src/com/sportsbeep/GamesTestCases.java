package com.sportsbeep;

import java.util.ArrayList;

import com.android.uiautomator.core.UiObject;
import com.android.uiautomator.core.UiObjectNotFoundException;
import com.android.uiautomator.core.UiSelector;

public class GamesTestCases extends TestCaseHelper {

    public void testA_ListOfGames() throws UiObjectNotFoundException {

        logMessage( "Starting SBA-95: The user will see a list of playable baseball games" );
        UiObject games_layout = new UiObject( new UiSelector().resourceId( resourcePrefix + "games_GridView" ) );
        UiObject first_game = games_layout.getChild( new UiSelector().index( 0 ) );
        UiObject team1_name = first_game.getChild( new UiSelector().resourceId( resourcePrefix + "teamName1_FontTextView" ) );
        UiObject team1_city = first_game.getChild( new UiSelector().resourceId( resourcePrefix + "teamMarket1_FontTextView" ) );
        UiObject team2_city = first_game.getChild( new UiSelector().resourceId( resourcePrefix + "teamMarket2_FontTextView" ) );
        UiObject team2_name = first_game.getChild( new UiSelector().resourceId( resourcePrefix + "teamName2_FontTextView" ) );
        UiObject date_label = first_game.getChild( new UiSelector().resourceId( resourcePrefix + "date_FontTextView" ) );
        UiObject time_label = first_game.getChild( new UiSelector().resourceId( resourcePrefix + "time_FontTextView" ) );
        UiObject pick_prompt = new UiObject( new UiSelector().text( "PICK A GAME" ) );
        UiObject instruction = new UiObject( new UiSelector().text( "CLICK TO PLAY" ) );

        assertTrue( "First game does not exist.", first_game.exists() );
        assertTrue( "Team2 name game does not exist.", team2_name.exists() );
        assertTrue( "Team2 market does not exist.", team2_city.exists() );
        assertTrue( "Team1 name does not exist.", team1_name.exists() );
        assertTrue( "Team1 market does not exist.", team1_city.exists() );
        assertTrue( "Date label does not exist.", date_label.exists() );
        assertTrue( "Time label does not exist.", time_label.exists() );
        assertTrue( "Pick Game prompt does not exist.", pick_prompt.exists() );
        assertTrue( "'click to play' text does not exist.", instruction.exists() );
        logMessage( "End of SBA-95 test." );
    }

    public void testB_BuildYourTeam() throws UiObjectNotFoundException {

        logMessage( "Starting SBA-328: A user can view the Build Your Team screen" );

        UiObject games_layout = new UiObject( new UiSelector().resourceId( resourcePrefix + "games_GridView" ) );
        UiObject first_game = games_layout.getChild( new UiSelector().index( 2 ) );
        first_game.clickAndWaitForNewWindow( 3000 );
        ArrayList<String> picks = new ArrayList<String>();

        validateBuildTeamMenu();
        UiObject pitcher = new UiObject( new UiSelector().text( "PITCHER" ) );
        pitcher.clickAndWaitForNewWindow( 2000 );
        UiObject player_list = new UiObject( new UiSelector().resourceId( "android:id/list" ) );

        picks.add( pickPlayer( player_list, "pitcher", 0 ) );
        picks.add( pickPlayer( player_list, "catcher", 0 ) );
        picks.add( pickPlayer( player_list, "corner", 0 ) );
        picks.add( pickPlayer( player_list, "middle", 0 ) );
        picks.add( pickPlayer( player_list, "outfielder", 0 ) );

        UiObject title = new UiObject( new UiSelector().resourceId( resourcePrefix + "title_FontTextView" ) );
        assertEquals( "PICK YOUR FLEX PLAYER", title.getText() );//make sure we are on flex player
        //pick team 0 again see if still on flex then pick team 1 and see if still on flex
        pickPlayer( player_list, "flex", 0 );
        title = new UiObject( new UiSelector().resourceId( resourcePrefix + "title_FontTextView" ) );
        assertEquals( "PICK YOUR FLEX PLAYER", title.getText() );//should still be on outfielder because 5 from same team is max
        picks.add( pickPlayer( player_list, "flex", 1 ) );//pick from other team and add to picks
        title = new UiObject( new UiSelector().resourceId( resourcePrefix + "title_FontTextView" ) );

        UiObject league_pick_text = new UiObject( new UiSelector().text( "LEAGUE PICK" ) );
        UiObject instruction_text = new UiObject( new UiSelector().text( "Most Home Runs" ) );
        UiObject home_run_games_list = new UiObject( new UiSelector().resourceId( "android:id/list" ) );
        UiObject home_run_game = home_run_games_list.getChild( new UiSelector().index( 0 ) );
        UiObject home_run_game_rel = home_run_game.getChild( new UiSelector().resourceId( resourcePrefix + "parent_SplitColorRelativeLayout" ) );
        UiObject home_run_team = home_run_game_rel.getChild( new UiSelector().index( 0 ) );
        UiObject home_run_team_city = home_run_team.getChild( new UiSelector().resourceId( resourcePrefix + "teamMarket1_FontTextView" ) );
        UiObject home_run_team_name = home_run_team.getChild( new UiSelector().resourceId( resourcePrefix + "teamName1_FontTextView" ) );
        assertTrue( "No game found.", home_run_game.exists() );
        assertTrue( "League Pick text does not exist.", league_pick_text.exists() );
        assertTrue( "instruction_text not found.", instruction_text.exists() );
        assertTrue( "home_run_team not found.", home_run_team.exists() );

        logMessage( "Selecting home run leader: " + home_run_team_city.getText() );
        picks.add( home_run_team_city.getText() + ' ' + home_run_team_name.getText() );
        home_run_team.clickAndWaitForNewWindow( 2000 );

        checkPicks( picks );//make sure all previous picks are present on set team screen

        UiObject set_your_team = new UiObject( new UiSelector().resourceId( resourcePrefix + "setYourTeam_FontTextView" ) );
        scrollUntilFound( "android:id/list", 4, set_your_team );
        assertTrue( "set_your_team not found.", set_your_team.exists() );
        set_your_team.clickAndWaitForNewWindow( 2000 );
        sleep( 1000 );
        UiObject play_for_free = new UiObject( new UiSelector().text( "PLAY FOR FREE" ) );
        UiObject pick_a_pool_text = new UiObject( new UiSelector().resourceId( resourcePrefix + "title_FontTextView" ) );
        assertTrue( "PICK A POOL not found.", pick_a_pool_text.exists() );
        assertTrue( "PLAY FOR FREE not found.", play_for_free.exists() );
        logMessage( "picking free pool" );
        play_for_free.click();

        //are you sure? modal
        UiObject yes_pool = findAndAssertWithResourceID( resourcePrefix + "yes_FontTextView" );
        UiObject cancel_pool = findAndAssertWithResourceID( resourcePrefix + "cancel_FontTextView" );

        yes_pool.click();
        validateReadySetGo();
        validateBestsAndBusts();
        sleep( 5000 );

    }

    public void checkPicks( ArrayList<String> picks ) throws UiObjectNotFoundException {

        UiObject pick_to_check;
        logMessage( "Checking picks." );
        for (String pick_text : picks) {
            pick_to_check = new UiObject( new UiSelector().text( pick_text ) );
            logMessage( "Checking for " + pick_text );
            scrollUntilFound( "android:id/list", 8, pick_to_check );
            assertTrue( pick_text + " not found.", pick_to_check.exists() );
        }
    }

    public void cancelContest() throws UiObjectNotFoundException {

        //what do you want to do with this contest
        UiObject continue_it = findAndAssertWithResourceID( resourcePrefix + "continue_FontTextView" );
        UiObject save_it = findAndAssertWithResourceID( resourcePrefix + "save_FontTextView" );
        UiObject cancel_it = findAndAssertWithResourceID( resourcePrefix + "cancel_FontTextView" );
    }

    public void validateReadySetGo() throws UiObjectNotFoundException {

        //SBA-295
        UiObject ready = new UiObject( new UiSelector().text( "READY" ) );
        UiObject set = new UiObject( new UiSelector().text( "SET" ) );
        UiObject go = new UiObject( new UiSelector().text( "GO!" ) );
        ready.waitForExists( 1000 );
        ready.waitUntilGone( 5000 );
        set.waitForExists( 3000 );
        set.waitUntilGone( 5000 );
        go.waitForExists( 3000 );
        go.waitUntilGone( 5000 );
        logMessage( "ready set gone!" );
    }

    public void validateBuildTeamMenu() throws UiObjectNotFoundException {

        UiObject pitcher = new UiObject( new UiSelector().text( "PITCHER" ) );
        UiObject catcher = new UiObject( new UiSelector().text( "CATCHER" ) );
        UiObject corner = new UiObject( new UiSelector().text( "CORNER INFIELDER" ) );
        UiObject middle = new UiObject( new UiSelector().text( "MIDDLE INFIELDER" ) );
        UiObject outfielder = new UiObject( new UiSelector().text( "OUTFIELDER" ) );
        UiObject bench = new UiObject( new UiSelector().text( "FLEX PLAYER" ) );
        UiObject menu = new UiObject( new UiSelector().resourceId( resourcePrefix + "dragView" ) );
        UiObject title = new UiObject( new UiSelector().text( "BUILD A TEAM" ) );
        assertTrue( "Pitcher does not exist.", pitcher.exists() );
        assertTrue( "Catcher does not exist.", catcher.exists() );
        assertTrue( "Corner infielder does not exist.", corner.exists() );
        assertTrue( "Middle infielder does not exist.", middle.exists() );
        assertTrue( "Outfielder does not exist.", outfielder.exists() );
        assertTrue( "Bench player does not exist.", bench.exists() );
        assertTrue( "Menu does not exist.", menu.exists() );
        assertTrue( "Title is not 'BUILD A TEAM'", title.exists() );
    }

    public void validateBestsAndBusts() throws UiObjectNotFoundException {

        //SBA-299
        UiObject timer = new UiObject( new UiSelector().resourceId( resourcePrefix + "timer_ArcCountDownView" ) );
        timer.waitForExists( 10000 );
        validateQuestion( "Which team will not make the most errors?", 1 );
        validateQuestion( "Which team will give up the least doubles?", 2 );
        validateQuestion( "Which team will hit the most home runs?", 3 );
        validateQuestion( "Which will not make the most hits?", 4 );
        validateQuestion( "Which team will steal the least?", 5 );
        validateQuestion( "Which team will strike out the most?", 6 );
    }

    public void validateQuestion( String expected, int question_number ) throws UiObjectNotFoundException {

        UiObject timer = findAndAssertWithResourceID( resourcePrefix + "timer_ArcCountDownView" );
        UiObject bestbust_title = findAndAssertWithResourceID( resourcePrefix + "bestbust_FontTextView" );
        UiObject question_count = findAndAssertWithResourceID( resourcePrefix + "questionPosition_FontTextView" );
        UiObject question = findAndAssertWithResourceID( resourcePrefix + "question_FontTextView" );

        String question_count_expected = "Question " + question_number + " of 6";
        String title_text_expected = question_number > 3 ? "THE BUSTS!" : "THE BESTS!";

        assertEquals( question_count_expected, question_count.getText() );
        //assertEquals( expected, question.getText() ); // does the order change? commenting out for now
        assertEquals( title_text_expected, bestbust_title.getText() );

        UiObject picked_team = new UiObject( new UiSelector().resourceId( resourcePrefix + "teamMarket1_FontTextView" ) );
        picked_team.clickAndWaitForNewWindow( 2000 );
    }
}
