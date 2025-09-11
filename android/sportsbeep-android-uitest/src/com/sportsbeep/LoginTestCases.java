package com.sportsbeep;

import com.android.uiautomator.core.UiObject;
import com.android.uiautomator.core.UiObjectNotFoundException;
import com.android.uiautomator.core.UiSelector;

public class LoginTestCases extends TestCaseHelper {

    @Override
    protected void setUp() throws UiObjectNotFoundException {

        logMessage( "Setting up for test" );
        //dont login so we can test login
    }

    public void testB_VerifyLoginScreen() throws UiObjectNotFoundException {

        logMessage( "Starting to Verify Login Screen" );

        UiObject sign_in = new UiObject( new UiSelector().resourceId( resourcePrefix + "signIn_Button" ) );
        UiObject create_account = new UiObject( new UiSelector().resourceId( resourcePrefix + "createAccount_Button" ) );
        UiObject email_field = new UiObject( new UiSelector().resourceId( resourcePrefix + "email_EditText" ) );
        UiObject password_field = new UiObject( new UiSelector().resourceId( resourcePrefix + "password_EditText" ) );
        UiObject greeting = new UiObject( new UiSelector().text( "SIGN IN TO YOUR ACCOUNT" ) );

        assertTrue( "sign in button does not exist.", sign_in.exists() );
        assertTrue( "create account button does not exist.", create_account.exists() );
        assertTrue( "email field does not exist.", email_field.exists() );
        assertTrue( "password field does not exist.", password_field.exists() );
        assertTrue( "greeting does not exist.", greeting.exists() );

        login( emailToLogin, passwordToLogin );
        sleep( 2000 );
        assertFalse( "Still on login screen.", sign_in.exists() );
        selectProBaseball();
    }

}
