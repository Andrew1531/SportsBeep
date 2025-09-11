package com.sportsbeep.app.test.ui;

import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.user.User;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.network.NetworkClient;
import com.sportsbeep.app.network.params.SignInParams;
import com.sportsbeep.app.storage.PreferenceHelper;
import com.sportsbeep.app.test.BaseActivityInstrumentationTestCase;
import com.sportsbeep.app.ui.account.CreateAccountActivity;
import com.sportsbeep.app.ui.login.LoginActivity;
import com.sportsbeep.app.ui.login.LoginFragment;
import com.sportsbeep.app.ui.sport.PickSportActivity;

import android.content.Intent;

import java.util.ArrayList;
import java.util.List;

import javax.inject.Inject;

import static org.mockito.Mockito.any;
import static org.mockito.Mockito.anyString;
import static org.mockito.Mockito.atLeastOnce;
import static org.mockito.Mockito.timeout;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

public class LoginActivityTest
        extends BaseActivityInstrumentationTestCase<LoginActivity, LoginFragment> {

    @Inject
    NetworkClient mNetworkClient;

    @Inject
    PreferenceHelper mPrefs;

    public LoginActivityTest() {
        super(LoginActivity.class);
    }

    public void testLoginError() {
        Result<User> result = new Result<User>("Error");
        when(mNetworkClient.signIn(any(SignInParams.class))).thenReturn(result);

        getSolo().clickOnButton("SIGN IN");
        assertTrue(getSolo().waitForText("Error"));
    }

    public void testLoginSuccess() {
        User user = new User();
        user.setAuthenticationToken("token");
        Result<User> result = new Result<User>(user);
        when(mNetworkClient.signIn(any(SignInParams.class))).thenReturn(result);

        Result<List<Game>> gameResult = new Result<List<Game>>(new ArrayList<Game>());
        when(mNetworkClient.getGames(any(Sport.class), any(Level.class))).thenReturn(gameResult);

        getSolo().clickOnButton("SIGN IN");
        assertTrue(getSolo().waitForActivity(PickSportActivity.class));

        verify(mPrefs, atLeastOnce()).setAuthToken(anyString());
    }

    public void testCreateAccountButton() {
        getSolo().clickOnButton("CREATE ACCOUNT");
        assertTrue(getSolo().waitForActivity(CreateAccountActivity.class));
    }

    public void testLogout() {
        Intent intent = new Intent();
        intent.putExtra(LoginActivity.EXTRA_LOGOUT, true);
        setActivityIntent(intent);

        when(mNetworkClient.putDeviceToken(anyString())).thenReturn(new Result<Void>((Void) null));

        getSolo();

        verify(mNetworkClient, timeout(5000)).putDeviceToken("");
        verify(mPrefs, timeout(5000)).removeAll();
    }
}
