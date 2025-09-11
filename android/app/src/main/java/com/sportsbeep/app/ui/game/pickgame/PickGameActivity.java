package com.sportsbeep.app.ui.game.pickgame;

import com.sportsbeep.app.R;
import com.sportsbeep.app.gcm.GCMManager;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.ticket.IncompleteTicket;
import com.sportsbeep.app.storage.IncompleteTicketDaoHelper;
import com.sportsbeep.app.task.network.NetworkAsyncTask;
import com.sportsbeep.app.ui.base.BaseNavigationActivity;
import com.sportsbeep.app.ui.game.buildteam.BuildTeamActivity;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;
import android.text.TextUtils;
import android.widget.Toast;

import javax.inject.Inject;

public class PickGameActivity extends BaseNavigationActivity implements PickGameFragment.PickGameCallback {

    @Inject
    GCMManager mGCMManager;

    @Inject
    IncompleteTicketDaoHelper mIncompleteTicketDaoHelper;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState == null) {
            FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
            ft.add(R.id.content, PickGameFragment.newInstance());
            ft.commit();
        }

        if (mGCMManager.checkPlayServices(this)) {
            if (TextUtils.isEmpty(mGCMManager.getRegistrationId())) {
                mGCMManager.registerGcm(new GCMManager.RegisterGcmCallback() {
                    @Override
                    public void onGcmRegistered(String regId) {
                        new RegisterGCMTokenTask().execute(regId);
                    }

                    @Override
                    public void onError() {
                        Toast.makeText(PickGameActivity.this, getString(R.string.register_push_error), Toast.LENGTH_LONG).show();
                    }
                });
            }
        }
    }

    @Override
    public void onGameClicked(Game game) {
        Intent intent = new Intent(this, BuildTeamActivity.class);
        intent.putExtra(BuildTeamActivity.EXTRA_GAME, game);

        IncompleteTicket ticket = mIncompleteTicketDaoHelper.getTicketForGame(game);
        if (ticket != null) {
            intent.putExtra(BuildTeamActivity.EXTRA_INCOMPLETE_TICKET, ticket);
        }

        startActivity(intent);
    }

    public class RegisterGCMTokenTask extends NetworkAsyncTask<String, Void, Void> {

        @Override
        protected Result<Void> doInBackground(String... params) {
            String deviceToken = params[0];
            return getClient().putDeviceToken(deviceToken);
        }

        @Override
        protected void onError(String errorMessage) {
            if (!isFinishing()) {
                Toast.makeText(PickGameActivity.this, getString(R.string.register_push_error), Toast.LENGTH_LONG).show();
            }
        }
    }
}
