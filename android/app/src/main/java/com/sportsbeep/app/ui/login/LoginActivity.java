package com.sportsbeep.app.ui.login;

import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.user.User;
import com.sportsbeep.app.task.network.NetworkAsyncTask;
import com.sportsbeep.app.ui.account.CreateAccountActivity;
import com.sportsbeep.app.ui.base.BaseActivity;
import com.sportsbeep.app.ui.game.pickgame.PickGameActivity;
import com.sportsbeep.app.ui.sport.PickSportActivity;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;
import android.text.TextUtils;

public class LoginActivity extends BaseActivity implements LoginFragment.LoginCallback {

    public static final String EXTRA_USER = "user";

    public static final String EXTRA_LOGOUT = "logout";

    private static final int CREATE_ACCOUNT_REQUEST_CODE = 1;

    @Extra(key = EXTRA_LOGOUT, optional = true)
    boolean mLogout;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (mLogout || TextUtils.isEmpty(getPreferences().getAuthToken())) {
            if (mLogout) {
                new RemoveDeviceTokenTask().execute();
            }

            if (savedInstanceState == null) {
                FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
                ft.add(android.R.id.content, LoginFragment.newInstance());
                ft.commit();
            }
        } else {
            launchPickGameActivity();
        }
    }

    @Override
    public void onCreateAccountClicked() {
        startActivityForResult(new Intent(this, CreateAccountActivity.class), CREATE_ACCOUNT_REQUEST_CODE);
    }

    @Override
    public void onSignedIn(User user) {
        getPreferences().setAuthToken(user.getAuthenticationToken());
        getPreferences().setUser(user);

        launchPickSportActivity();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == CREATE_ACCOUNT_REQUEST_CODE) {
            if (resultCode == RESULT_OK) {
                User user = data.getParcelableExtra(EXTRA_USER);
                onSignedIn(user);
            }
        }
    }

    private void launchPickGameActivity() {
        Intent intent = new Intent(this, PickGameActivity.class);
        startActivity(intent);

        finish();
    }

    private void launchPickSportActivity() {
        Intent intent = new Intent(this, PickSportActivity.class);
        intent.putExtra(PickSportActivity.EXTRA_ONBOARDING, true);
        startActivity(intent);

        finish();
    }

    public class RemoveDeviceTokenTask extends NetworkAsyncTask<Void, Void, Void> {

        @Override
        protected Result<Void> doInBackground(Void... params) {
            return getClient().putDeviceToken("");
        }

        @Override
        protected void onFinished() {
            super.onFinished();
            getPreferences().removeAll();
        }
    }
}
