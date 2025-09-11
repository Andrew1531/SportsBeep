package com.sportsbeep;

import java.util.Calendar;
import java.util.Random;

import com.android.uiautomator.core.Configurator;
import com.android.uiautomator.core.UiDevice;
import com.android.uiautomator.core.UiObject;
import com.android.uiautomator.core.UiObjectNotFoundException;
import com.android.uiautomator.core.UiScrollable;
import com.android.uiautomator.core.UiSelector;
import com.android.uiautomator.testrunner.UiAutomatorTestCase;

public abstract class TestCaseHelper extends UiAutomatorTestCase {

    String[] usernames = { "new" };
    String[] passwords = { "metova123" };//"password";
    String[] emails = { "new@metova.com" };
    String userToLogin = usernames[0];
    String passwordToLogin = passwords[0];
    String emailToLogin = emails[0];
    UiObject actionBarTitle = new UiObject( new UiSelector().resourceId( "android:id/action_bar_title" ) );
    UiObject alertTitle = new UiObject( new UiSelector().resourceId( "android:id/alertTitle" ) );
    Configurator doubleTapConfigurator = Configurator.getInstance();
    static Random rand = new Random();

    boolean onStaging = ( false );
    static String integrationResource = "com.sportsbeep.app.integration:id/";
    static String stagingResource = "com.sportsbeep.app.staging:id/";
    String resourcePrefix = setPrefix( onStaging );

    public static String setPrefix( boolean environ ) {

        if ( environ ) {
            return stagingResource;
        }
        else {
            return integrationResource;
        }

    }

    public static String randomize( String baseString ) {

        return baseString + rand.nextInt( 10000 );
    }

    /**
     * @author skyemccaskey
     * Method for logging messages to the console
     * To use, simply call: logMessage("Your message");
     */

    public static void logMessage( String logMessage ) {

        String strLogMessage = "UIALogger: " + logMessage;
        System.out.println( strLogMessage );
    }

    /**
    * @author skyemccaskey
    * Method to check if the time is AM/PM
    * To use, simply call: timeIsPM();
    * It will return true or false
    */
    public static Boolean timeIsPM() {

        Calendar rightNow = Calendar.getInstance();
        int hour = rightNow.get( Calendar.HOUR_OF_DAY );
        int min = rightNow.get( Calendar.MINUTE );

        logMessage( "Time is " + hour + ":" + min );
        if ( hour > 11 ) {
            return true;
        }
        else {
            return false;
        }
    }

    /**
     * @author skyemccaskey
     * Method to get the current month
     * To use, simply call: getCurrentMonth();
     * It will return an integer for the current month
     */
    public static int getCurrentMonth() {

        Calendar rightNow = Calendar.getInstance();
        int month = rightNow.get( Calendar.MONTH );
        return month;
    }

    /**
    * @author skyemccaskey
    * Method to check if a web related UIObject has loaded from the server yet.
    * To use, simply call: waitIfNotLoaded(theobjectyou'relookingfor);
    * It will log its activity
     *
    */
    public void waitIfNotLoaded( UiObject item ) throws UiObjectNotFoundException {

        if ( item.exists() ) {
            return;
        }
        else {
            logMessage( "Waiting 1 sec for item" );
            sleep( 1000 );
            if ( item.exists() ) {
                logMessage( "Found" );
                return;
            }
            else {
                logMessage( "Waiting 2 sec for item" );
                sleep( 2000 );
                if ( item.exists() ) {
                    logMessage( "Found" );
                    return;
                }
                else {
                    logMessage( "Waiting 4 sec for item" );
                    sleep( 4000 );
                    logMessage( "Exiting, may not have found item" );
                    return;
                }
            }
        }

    }

    /**
     * @author skyemccaskey
     * Method to check whether the keyboard is onscreen when attempting to access an item
     * To use, simply call: kbdCheck(the object you're trying to access);
     * Use this before asserting the object or clicking it
     */

    public void keyboardCheck( UiObject item ) {

        if ( item.exists() == false ) {
            getUiDevice().pressEnter();
            UiDevice.getInstance().waitForWindowUpdate( null, 3000 );
            if ( item.exists() == false ) {
                getUiDevice().pressBack();
                UiDevice.getInstance().waitForWindowUpdate( null, 3000 );
            }
        }
    }

    /**
     * @author skyemccaskey
     * Method to double tap an item
     * To use, simply call: doubleClick(the object you're trying to doubletap);
     * UIAutomator doesn't natively support double tapping.
     * This is basically a hack that works, but the timing around when the clicks happen has to be perfect for it to work.
     * I found that I had to tap something before double tapping again or it would be seen as a single tap.
     */

    public void doubleClick( UiObject item ) throws UiObjectNotFoundException {

        logMessage( "Double tapping item" );
        long previousSetting = doubleTapConfigurator.getActionAcknowledgmentTimeout();
        doubleTapConfigurator.setActionAcknowledgmentTimeout( 40 );
        item.click();
        item.click();
        sleep( 3000 );
        doubleTapConfigurator.setActionAcknowledgmentTimeout( previousSetting );
    }

    /**
     * @author skyemccaskey
     * Method for backtracking to a previous view using the action bar title
     * To use, simply call: goBack();
     * @throws UiObjectNotFoundException
     */
    public void goBack() throws UiObjectNotFoundException {

        UiObject actionBarButton = new UiObject( new UiSelector().resourceId( "android:id/action_bar_title" ) );
        actionBarButton.clickAndWaitForNewWindow( 4000 );
    }

    protected void login( String email, String password ) throws UiObjectNotFoundException {

        logMessage( "Starting Login method" );
        UiObject usernameField = new UiObject( new UiSelector().resourceId( resourcePrefix + "email_EditText" ) );
        UiObject passwordField = new UiObject( new UiSelector().resourceId( resourcePrefix + "password_EditText" ) );
        UiObject signInButton = new UiObject( new UiSelector().resourceId( resourcePrefix + "signIn_Button" ) );
        usernameField.setText( email );
        passwordField.setText( password );
       // getUiDevice().pressBack();
        signInButton.clickAndWaitForNewWindow( 6000 );
        sleep( 4000 );
    }

    protected void login() throws UiObjectNotFoundException {

        logMessage( "Starting Login method" );
        UiObject usernameField = new UiObject( new UiSelector().resourceId( resourcePrefix + "email_EditText" ) );
        UiObject passwordField = new UiObject( new UiSelector().resourceId( resourcePrefix + "password_EditText" ) );
        UiObject signInButton = new UiObject( new UiSelector().resourceId( resourcePrefix + "signIn_Button" ) );
        usernameField.setText( emailToLogin );
        passwordField.setText( passwordToLogin );
        //getUiDevice().pressBack();
        signInButton.clickAndWaitForNewWindow( 6000 );
        sleep( 4000 );
    }

    /**
     * @author skyemccaskey
     * Method that logs out
     * To use, simply call: logout();
     * @throws UiObjectNotFoundException
     */
    protected void logout() throws UiObjectNotFoundException {

        logMessage( "Starting Logout method" );
        UiObject menu_button = new UiObject( new UiSelector().resourceId( resourcePrefix + "dragView" ) );
        menu_button.click();
        sleep( 1000 );
        UiObject logout_button = new UiObject( new UiSelector().resourceId( resourcePrefix + "logOut_FontTextView" ) );
        logout_button.click();

    }

    /**
     * @author skyemccaskey
     * Method that scrolls up to a set number of times to find an item
     * To use, simply call: scrollUntilFound(Feed it a string for the scrolling object's resource id, an integer for how many times to try, the item for it to find);
     * @throws UiObjectNotFoundException
     */
    protected void scrollUntilFound( String scrollingViewResourceId, int timesToAttemptFind, UiObject item ) throws UiObjectNotFoundException {

        logMessage( "Scrolling to find item" );
        UiScrollable scroller = new UiScrollable( new UiSelector().resourceId( scrollingViewResourceId ) );

        for (int x = timesToAttemptFind; x > -1; x--) {
            if ( item.exists() ) {
                return;
            }
            else {
                scroller.scrollForward();
                if ( x == 0 ) {
                    if ( !item.exists() ) {
                        logMessage( "Unable to find item scrolling forward" );
                    }
                }
            }
        }
        for (int x = timesToAttemptFind; x > -1; x--) {
            if ( item.exists() ) {
                return;
            }
            else {
                scroller.scrollBackward();
                if ( x == 0 ) {
                    if ( !item.exists() ) {
                        logMessage( "Unable to find item scrolling backward" );
                    }
                }
            }
        }
    }

    /**
     * @author skyemccaskey
     * Setup Method that logs in taking you to the feed where you can begin your test
     * This is automatically called before each test unless your suite/class overrides it
     * @throws UiObjectNotFoundException
     */
    @Override
    protected void setUp() throws UiObjectNotFoundException {

        logMessage( "Setting up for test" );
        login( emailToLogin, passwordToLogin );
        selectProBaseball();
    }

    /**
     * @author skyemccaskey
     * Teardown Method that logs you out after the test
     * This is automatically called after each test unless your suite/class overrides it.
     * It needs to be able to see the top right corner menu to get to settings
     * @throws UiObjectNotFoundException
     */
    @Override
    protected void tearDown() throws UiObjectNotFoundException {

        logMessage( "Tearing down from test" );
        logout();
    }

    protected void buildTeam( int gameIndex ) throws UiObjectNotFoundException {

        UiObject games_layout = new UiObject( new UiSelector().resourceId( resourcePrefix + "games_GridView" ) );
        UiObject first_game = games_layout.getChild( new UiSelector().index( gameIndex ) );
        first_game.clickAndWaitForNewWindow( 3000 );
        sleep( 3000 );
        UiObject pitcher = new UiObject( new UiSelector().text( "PITCHER" ) );
        pitcher.clickAndWaitForNewWindow( 2000 );
        UiObject player_list = new UiObject( new UiSelector().resourceId( "android:id/list" ) );
        UiObject picked_pitcher = player_list.getChild( new UiSelector().index( 0 ) );
        UiObject picked_pitcher_name = picked_pitcher.getChild( new UiSelector().resourceId( resourcePrefix + "name_FontTextView" ) );
        logMessage( "Picking pitcher: " + picked_pitcher_name.getText() );
        picked_pitcher_name.clickAndWaitForNewWindow( 1000 );

        UiObject picked_catcher = player_list.getChild( new UiSelector().index( 0 ) );
        UiObject picked_catcher_name = picked_catcher.getChild( new UiSelector().resourceId( resourcePrefix + "name_FontTextView" ) );
        logMessage( "Picking catcher: " + picked_catcher_name.getText() );
        picked_catcher_name.clickAndWaitForNewWindow( 1000 );

        UiObject picked_corner = player_list.getChild( new UiSelector().index( 0 ) );
        UiObject picked_corner_name = picked_corner.getChild( new UiSelector().resourceId( resourcePrefix + "name_FontTextView" ) );
        logMessage( "Picking corner: " + picked_corner_name.getText() );
        picked_corner_name.clickAndWaitForNewWindow( 1000 );

        UiObject picked_middle = player_list.getChild( new UiSelector().index( 0 ) );
        UiObject picked_middle_name = picked_middle.getChild( new UiSelector().resourceId( resourcePrefix + "name_FontTextView" ) );
        logMessage( "Picking middle: " + picked_middle_name.getText() );
        picked_middle_name.clickAndWaitForNewWindow( 1000 );

        UiObject picked_outfielder = player_list.getChild( new UiSelector().index( 1 ) );
        UiObject picked_outfielder_name = picked_outfielder.getChild( new UiSelector().resourceId( resourcePrefix + "name_FontTextView" ) );
        logMessage( "Picking outfielder: " + picked_outfielder_name.getText() );
        picked_outfielder_name.clickAndWaitForNewWindow( 1000 );

        UiObject picked_bench = player_list.getChild( new UiSelector().index( 1 ) );
        UiObject picked_bench_name = picked_bench.getChild( new UiSelector().resourceId( resourcePrefix + "name_FontTextView" ) );
        logMessage( "Picking Flex: " + picked_bench_name.getText() );
        picked_bench_name.clickAndWaitForNewWindow( 1000 );

        UiObject home_run_games_list = new UiObject( new UiSelector().resourceId( "android:id/list" ) );
        UiObject home_run_game = home_run_games_list.getChild( new UiSelector().index( 0 ) );
        UiObject home_run_game_rel = home_run_game.getChild( new UiSelector().resourceId( resourcePrefix + "parent_SplitColorRelativeLayout" ) );
        UiObject home_run_team = home_run_game_rel.getChild( new UiSelector().index( 0 ) );
        UiObject home_run_team_city = home_run_team.getChild( new UiSelector().resourceId( resourcePrefix + "teamMarket1_FontTextView" ) );

        logMessage( "Selecting home run leader: " + home_run_team_city.getText() );
        home_run_team.clickAndWaitForNewWindow( 2000 );

        UiObject set_your_team = new UiObject( new UiSelector().resourceId( resourcePrefix + "setYourTeam_FontTextView" ) );
        scrollUntilFound( "android:id/list", 8, set_your_team );
        assertTrue( "set_your_team not found.", set_your_team.exists() );
        set_your_team.clickAndWaitForNewWindow( 3000 );
        UiObject play_for_free = new UiObject( new UiSelector().text( "PLAY FOR FREE" ) );
        assertTrue("play_for_free button not found", play_for_free.exists());
        play_for_free.clickAndWaitForNewWindow( 2000 );

        UiObject yes_button = new UiObject( new UiSelector().resourceId( resourcePrefix + "yes_FontTextView" ) );
        assertTrue( "yes_button not found", yes_button.exists());
        yes_button.clickAndWaitForNewWindow( 7000 );

        UiObject picked_team = new UiObject( new UiSelector().resourceId( resourcePrefix + "teamMarket1_FontTextView" ) );
        picked_team.clickAndWaitForNewWindow( 2000 );
        for( int i = 0; i < 6; i++) {
            picked_team.clickAndWaitForNewWindow( 1000 );
        }
    }

    protected void selectLevel( String level ) throws UiObjectNotFoundException {

        level = level.toUpperCase();
        UiObject new_game_title = new UiObject( new UiSelector().text( "NEW GAME" ) );
        UiObject level_selection = new UiObject( new UiSelector().text( level ) );
        if ( new_game_title.exists() ) {
            logMessage( "Clicking element with text: " + level );
            level_selection.click();
        }
    }

    protected void selectSport( String sport ) throws UiObjectNotFoundException {

        sport = sport.toUpperCase();
        UiObject new_game_title = new UiObject( new UiSelector().text( "NEW GAME" ) );
        UiObject sport_selection = new UiObject( new UiSelector().text( sport ) );
        if ( new_game_title.exists() ) {
            logMessage( "Clicking element with text: " + sport );
            sport_selection.click();
        }
    }

    protected void selectProBaseball() throws UiObjectNotFoundException {

        //right now this happens after every log in
        UiObject enter = new UiObject( new UiSelector().resourceId( resourcePrefix + "enter_Button" ) );
        if ( enter.exists() ) {
            logMessage( "starting selections" );
            selectLevel( "professional" );
            selectSport( "Baseball" );
            enter = new UiObject( new UiSelector().resourceId( resourcePrefix + "enter_Button" ) );
            enter.clickAndWaitForNewWindow( 3000 );
        }

    }

    protected UiObject findAndAssertWithResourceID( String resid ) throws UiObjectNotFoundException {

        UiObject thing = new UiObject( new UiSelector().resourceId( resid ) );
        assertTrue( "Object with resource id " + resid + " not found", thing.exists() );
        return thing;
    }

    protected UiObject findAndAssertWithText( String text ) throws UiObjectNotFoundException {

        UiObject thing = new UiObject( new UiSelector().text( text ) );
        assertTrue( "Object with text " + text + " not found", thing.exists() );
        return thing;
    }

    protected String pickPlayer( UiObject player_list, String position, int index ) throws UiObjectNotFoundException {

        UiObject picked = player_list.getChild( new UiSelector().index( index ) );
        UiObject picked_name = picked.getChild( new UiSelector().resourceId( resourcePrefix + "name_FontTextView" ) );
        String player_name = picked_name.getText();
        logMessage( "Picking " + position + ": " + player_name );
        picked_name.clickAndWaitForNewWindow( 1000 );
        return player_name;
    }

}
