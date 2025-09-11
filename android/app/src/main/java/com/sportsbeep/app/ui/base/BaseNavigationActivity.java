package com.sportsbeep.app.ui.base;

import com.sothree.slidinguppanel.SlidingUpPanelLayout;
import com.sportsbeep.app.R;
import com.sportsbeep.app.storage.IncompleteTicketDaoHelper;
import com.sportsbeep.app.ui.account.ProfilePhotoDialogFragment;
import com.sportsbeep.app.ui.contest.ContestActivity;
import com.sportsbeep.app.ui.game.pickgame.PickGameActivity;
import com.sportsbeep.app.ui.login.LoginActivity;
import com.sportsbeep.app.ui.sport.PickSportActivity;
import com.sportsbeep.app.ui.tutorial.HowToPlayActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import javax.inject.Inject;

import butterknife.ButterKnife;
import butterknife.InjectView;
import butterknife.OnClick;

public abstract class BaseNavigationActivity extends BaseActivity {

    @InjectView(R.id.slidingUpPanelLayout)
    SlidingUpPanelLayout mSlidingUpPanelLayout;

    @InjectView(R.id.content)
    FrameLayout mContentFrameLayout;

    @Inject
    IncompleteTicketDaoHelper mIncompleteTicketDaoHelper;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        super.setContentView(R.layout.activity_navigation);
        ButterKnife.inject(this);
    }

    @OnClick(R.id.pickAGame_FontTextView)
    void onClickPickAGame() {
        if (!(this instanceof PickGameActivity)) {
            Intent intent = new Intent(this, PickGameActivity.class);
            startActivity(intent);
        }

        mSlidingUpPanelLayout.collapsePane();
    }

    @OnClick(R.id.myContests_FontTextView)
    void onClickMyContests() {
        if (!(this instanceof ContestActivity)) {
            Intent intent = new Intent(this, ContestActivity.class);
            startActivity(intent);
        }

        mSlidingUpPanelLayout.collapsePane();
    }

    @OnClick(R.id.changeSport_FontTextView)
    void onClickChangeSport() {
        Intent intent = new Intent(this, PickSportActivity.class);
        startActivity(intent);

        mSlidingUpPanelLayout.collapsePane();
    }

    @OnClick(R.id.howToPlay_FontTextView)
    void onClickHowToPlay() {
        Intent intent = new Intent(this, HowToPlayActivity.class);
        startActivity(intent);

        mSlidingUpPanelLayout.collapsePane();
    }

    @OnClick(R.id.profilePhoto_FontTextView)
    void onClickProfilePhoto() {
        ProfilePhotoDialogFragment.newInstance().show(getSupportFragmentManager(), null);

        mSlidingUpPanelLayout.collapsePane();
    }

    @OnClick(R.id.logOut_FontTextView)
    void onClickLogOut() {
        mIncompleteTicketDaoHelper.deleteAllTickets();

        Intent intent = new Intent(this, LoginActivity.class);
        intent.putExtra(LoginActivity.EXTRA_LOGOUT, true);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);
    }

    @Override
    public void setContentView(final int layoutResID) {
        mContentFrameLayout.removeAllViews();
        getLayoutInflater().inflate(layoutResID, mContentFrameLayout);
    }

    @Override
    public void setContentView(View view) {
        mContentFrameLayout.removeAllViews();
        mContentFrameLayout.addView(view);
    }

    @Override
    public void setContentView(View view, ViewGroup.LayoutParams params) {
        mContentFrameLayout.removeAllViews();
        mContentFrameLayout.addView(view, params);
    }
}
