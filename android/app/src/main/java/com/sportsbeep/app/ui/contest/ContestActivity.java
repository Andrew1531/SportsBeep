package com.sportsbeep.app.ui.contest;

import com.sportsbeep.app.R;
import com.sportsbeep.app.model.contest.Contest;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.ticket.IncompleteTicket;
import com.sportsbeep.app.model.ticket.Ticket;
import com.sportsbeep.app.network.params.ContestsParams;
import com.sportsbeep.app.storage.GameDaoHelper;
import com.sportsbeep.app.storage.PlayerDaoHelper;
import com.sportsbeep.app.storage.TeamDaoHelper;
import com.sportsbeep.app.ui.base.BaseNavigationActivity;
import com.sportsbeep.app.ui.game.buildteam.BuildTeamActivity;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.view.ViewPager;
import android.widget.RadioGroup;

import java.util.Arrays;
import java.util.List;

import javax.inject.Inject;

import butterknife.ButterKnife;
import butterknife.InjectView;
import butterknife.Optional;

public class ContestActivity extends BaseNavigationActivity implements ContestListFragment.ContestCallback, IncompleteContestListFragment.IncompleteContestCallback {

    private final List<Integer> mCheckIdList = Arrays.asList(
            R.id.live_contest_button,
            R.id.upcoming_contest_button,
            R.id.contest_history_button,
            R.id.incomplete_contest_button
    );

    @Optional
    @InjectView(R.id.viewPager)
    ViewPager mViewPager;

    @Inject
    PlayerDaoHelper mPlayerDaoHelper;

    @Inject
    TeamDaoHelper mTeamDaoHelper;

    @Inject
    GameDaoHelper mGameDaoHelper;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_contest);
        ButterKnife.inject(this);

        mViewPager.setAdapter(new ContestPagerAdapter(getSupportFragmentManager()));

        setTabListener();
    }

    @Override
    public void onContestClicked(Contest contest, ContestsParams.ContestStatus contestStatus) {
        showContestDetails(contest, contestStatus);
    }

    @Override
    public void onIncompleteContestClicked(IncompleteTicket ticket) {
        Intent intent = new Intent(this, BuildTeamActivity.class);
        intent.putExtra(BuildTeamActivity.EXTRA_GAME, ticket.getGame());
        intent.putExtra(BuildTeamActivity.EXTRA_INCOMPLETE_TICKET, ticket);
        startActivity(intent);
    }

    private void showContestDetails(Contest contest, ContestsParams.ContestStatus contestStatus) {
        Intent intent = new Intent(this, ContestDetailsActivity.class);
        intent.putExtra(ContestDetailsActivity.EXTRA_CONTEST_ID, contest.getId());
        intent.putExtra(ContestDetailsActivity.EXTRA_TICKET_ID, contest.getTicket().getId());
        intent.putExtra(ContestDetailsActivity.EXTRA_GAME_ID, contest.getGame().getId());
        intent.putExtra(ContestDetailsActivity.EXTRA_CONTEST_STATUS, contestStatus);
        startActivity(intent);
    }

    private void setTabListener() {
        final RadioGroup radioGroup = (RadioGroup) findViewById(R.id.contest_tabs);
        radioGroup.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                mViewPager.setCurrentItem(mCheckIdList.indexOf(checkedId));
            }
        });

        mViewPager.setOnPageChangeListener(
                new ViewPager.SimpleOnPageChangeListener() {
                    @Override
                    public void onPageSelected(int position) {
                        radioGroup.check(mCheckIdList.get(position));
                    }
                }
        );

        radioGroup.check(R.id.live_contest_button);
    }

    private class ContestPagerAdapter extends FragmentStatePagerAdapter {

        public ContestPagerAdapter(FragmentManager fm) {
            super(fm);
        }

        @Override
        public Fragment getItem(int position) {
            switch (position) {
                case 0:
                    return ContestListFragment.newInstance(ContestsParams.ContestStatus.LIVE);
                case 1:
                    return ContestListFragment.newInstance(ContestsParams.ContestStatus.UPCOMING);
                case 2:
                    return ContestListFragment.newInstance(ContestsParams.ContestStatus.PAST);
                case 3:
                    return IncompleteContestListFragment.newInstance();
                default:
                    throw new IllegalArgumentException("Contest type is invalid.");
            }
        }

        @Override
        public int getCount() {
            return 4;
        }
    }
}
