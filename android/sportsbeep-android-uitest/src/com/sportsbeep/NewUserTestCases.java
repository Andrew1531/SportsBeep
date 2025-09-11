package com.sportsbeep;

import com.android.uiautomator.core.UiObject;
import com.android.uiautomator.core.UiObjectNotFoundException;
import com.android.uiautomator.core.UiSelector;

public class NewUserTestCases extends TestCaseHelper {

    @Override
    protected void setUp() throws UiObjectNotFoundException {

        logMessage( "Setting up for test" );
        //dont login so we can create user
    }

    public void testA_NewUserSetup() throws UiObjectNotFoundException {

        String uname = randomize( userToLogin );
        String email = uname + "@gmail.com";
        //create account
        logMessage( "Starting to Verify Account Creation" );
        UiObject createAccountButton = new UiObject( new UiSelector().resourceId( resourcePrefix + "createAccount_Button" ) );
        assertTrue( "FAIL: Create Account button not found.", createAccountButton.exists() );
        createAccountButton.clickAndWaitForNewWindow( 2000 );

        UiObject username_create = new UiObject( new UiSelector().resourceId( resourcePrefix + "username_EditText" ) );
        assertTrue( "FAIL: Username field not found.", username_create.exists() );

        UiObject email_create = new UiObject( new UiSelector().resourceId( resourcePrefix + "email_EditText" ) );
        assertTrue( "FAIL: Email field not found.", email_create.exists() );

        UiObject password_create = new UiObject( new UiSelector().resourceId( resourcePrefix + "password_EditText" ) );
        assertTrue( "FAIL: Password field not found.", password_create.exists() );
        keyboardCheck( username_create );
        username_create.setText( uname );
        getUiDevice().pressBack();

        keyboardCheck( email_create );
        email_create.setText( email );
        getUiDevice().pressBack();

        keyboardCheck( password_create );
        password_create.setText( passwordToLogin );
        getUiDevice().pressBack();

        keyboardCheck( createAccountButton );
        createAccountButton.clickAndWaitForNewWindow( 2000 );
        sleep( 1000 );
        UiObject personalFavoritesText = new UiObject( new UiSelector().text( "PERSONAL FAVORITES" ) );
        assertTrue( personalFavoritesText.exists() );
        UiObject baseballText = new UiObject( new UiSelector().resourceId( resourcePrefix + "baseball_AutoCompleteTextView" ) );
        UiObject enterButton = new UiObject( new UiSelector().resourceId( resourcePrefix + "enter_Button" ) );
        assertTrue( baseballText.exists() );
        assertTrue( enterButton.exists() );
        baseballText.setText( "Bra" );
        sleep( 1000 );
        getUiDevice().click( baseballText.getBounds().left + 50, baseballText.getBounds().bottom + 50 );
        sleep( 1000 );
        assertEquals( "FAIL: Brewers were not selected.", "Favorite Baseball Team. Atlanta Braves. Editing.", baseballText.getText() );
        //getUiDevice().pressBack();
        enterButton.clickAndWaitForNewWindow( 2000 );

        selectProBaseball();//right now this needs to happen after every login

    }

}
