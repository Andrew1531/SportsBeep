package com.sportsbeep.app.ui.account;

import com.sportsbeep.app.model.user.User;
import com.sportsbeep.app.ui.base.BaseActivity;
import com.sportsbeep.app.ui.login.LoginActivity;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;

public class CreateAccountActivity extends BaseActivity
        implements CreateAccountFragment.CreateAccountCallback,
        FavoriteTeamFragment.FavoriteTeamCallback {

    private User mUser;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState == null) {
            FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
            ft.add(android.R.id.content, CreateAccountFragment.newInstance());
            ft.commit();
        }
    }

    @Override
    public void onBackPressed() {
        Fragment fragment = getSupportFragmentManager().findFragmentById(android.R.id.content);
        if (fragment instanceof FavoriteTeamFragment) {
            // Log the user in and continue
            onFavoriteTeamsSelected();
        }

        super.onBackPressed();
    }

    @Override
    public void onAccountCreated(User user) {
        mUser = user;
        getPreferences().setAuthToken(mUser.getAuthenticationToken());
        getPreferences().setUser(user);

        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        ft.replace(android.R.id.content, FavoriteTeamFragment.newInstance());
        ft.addToBackStack(null);
        ft.commit();
    }

    @Override
    public void onFavoriteTeamsSelected() {
        Intent data = new Intent();
        data.putExtra(LoginActivity.EXTRA_USER, mUser);
        setResult(RESULT_OK, data);
        finish();
    }
}
