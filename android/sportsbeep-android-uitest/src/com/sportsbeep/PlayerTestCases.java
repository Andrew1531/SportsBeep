package com.sportsbeep;

import android.graphics.Rect;

import com.android.uiautomator.core.UiObject;
import com.android.uiautomator.core.UiObjectNotFoundException;
import com.android.uiautomator.core.UiSelector;

public class PlayerTestCases extends TestCaseHelper {

    public void testA_ViewPlayerStats() throws UiObjectNotFoundException {

        //SBA-274
        logMessage( "Starting testA_ViewPlayerStats" );
        int gameIndex = 0;
        UiObject games_layout = new UiObject( new UiSelector().resourceId( resourcePrefix + "games_GridView" ) );
        UiObject first_game = games_layout.getChild( new UiSelector().index( gameIndex ) );
        first_game.clickAndWaitForNewWindow( 3000 );
        sleep( 3000 );
        UiObject pitcher = new UiObject( new UiSelector().text( "PITCHER" ) );
        pitcher.clickAndWaitForNewWindow( 2000 );
        sleep( 3000 );

        UiObject player_list = new UiObject( new UiSelector().resourceId( "android:id/list" ) );
        UiObject picked = player_list.getChild( new UiSelector().index( 0 ) );
        UiObject picked_name = picked.getChild( new UiSelector().resourceId( resourcePrefix + "name_FontTextView" ) );
        String player_name = picked_name.getText();
        logMessage( "Picking pitcher: " + player_name );
        Rect picked_name_rect = picked_name.getBounds();
        getUiDevice().swipe( picked_name_rect.centerX(), picked_name_rect.centerY(), picked_name_rect.centerX(), picked_name_rect.centerY(), 200 );
        findAndAssertWithResourceID( resourcePrefix + "playerPortrait_ImageView" );
        findAndAssertWithResourceID( resourcePrefix + "stats_TableLayout" );
        findAndAssertWithText( player_name );
        logMessage( "End of sport and level selection test." );

    }

}
