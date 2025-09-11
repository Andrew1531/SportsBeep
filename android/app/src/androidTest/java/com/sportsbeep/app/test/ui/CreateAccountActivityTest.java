package com.sportsbeep.app.test.ui;

import com.robotium.solo.Condition;
import com.sportsbeep.app.R;
import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.user.User;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.model.team.TeamList;
import com.sportsbeep.app.network.NetworkClient;
import com.sportsbeep.app.network.params.CreateAccountParams;
import com.sportsbeep.app.storage.PreferenceHelper;
import com.sportsbeep.app.storage.TeamDaoHelper;
import com.sportsbeep.app.test.BaseActivityInstrumentationTestCase;
import com.sportsbeep.app.ui.account.CreateAccountActivity;
import com.sportsbeep.app.ui.account.CreateAccountFragment;
import com.sportsbeep.app.ui.account.FavoriteTeamFragment;

import org.mockito.Mockito;

import android.widget.AutoCompleteTextView;

import java.util.Collections;
import java.util.List;

import javax.inject.Inject;

import static org.mockito.Matchers.any;

public class CreateAccountActivityTest
        extends BaseActivityInstrumentationTestCase<CreateAccountActivity, CreateAccountFragment> {

    @Inject
    NetworkClient mNetworkClient;

    @Inject
    PreferenceHelper mPrefs;

    @Inject
    TeamDaoHelper mDaoHelper;

    public CreateAccountActivityTest() {
        super(CreateAccountActivity.class);
    }

    public void testSuccess() {
        User user = new User();
        user.setAuthenticationToken("token");
        Result<User> result = new Result<User>(user);

        Result<List<Team>> teamsResult = new Result<List<Team>>(new TeamList().getTeams());

        Mockito.when(mNetworkClient.createAccount(Mockito.any(CreateAccountParams.class)))
                .thenReturn(result);
        Mockito.when(mNetworkClient.getTeams(any(Sport.class), any(Level.class))).thenReturn(teamsResult);
        //Mockito.when(mDaoHelper.addOrUpdateTeams(Mockito.anyList())).thenReturn(1);

        getSolo().clickOnButton("CREATE ACCOUNT");
        assertTrue(getSolo().waitForCondition(new Condition() {
            @Override
            public boolean isSatisfied() {
                return getActivity().getSupportFragmentManager()
                        .findFragmentById(android.R.id.content) instanceof FavoriteTeamFragment;
            }
        }, 5000));

        Mockito.verify(mPrefs, Mockito.atLeastOnce()).setAuthToken("token");
    }

    public void testFailure() {
        Result<User> result = new Result<User>("Error");

        Mockito.when(mNetworkClient.createAccount(Mockito.any(CreateAccountParams.class)))
                .thenReturn(result);

        getSolo().clickOnButton("CREATE ACCOUNT");
        assertTrue(getSolo().waitForText("Error"));
    }

    public void testAutoCompleteFavoriteTeam() {

        TeamList teamList = new TeamList();
        Team team = new Team();
        team.setMarket("Atlanta");
        team.setName("Braves");
        teamList.setTeams(Collections.singletonList(team));
        Result<List<Team>> teamsResult = new Result<List<Team>>(teamList.getTeams());

        Mockito.when(mNetworkClient.getTeams(any(Sport.class), any(Level.class))).thenReturn(teamsResult);
        //Mockito.when(mDaoHelper.addOrUpdateTeams(Mockito.anyList())).thenReturn(1);

        getActivity().getSupportFragmentManager().beginTransaction()
                .replace(android.R.id.content, FavoriteTeamFragment.newInstance()).commit();
        getSolo().waitForCondition(new Condition() {
            @Override
            public boolean isSatisfied() {
                return getActivity().getSupportFragmentManager()
                        .findFragmentById(android.R.id.content) instanceof FavoriteTeamFragment;
            }
        }, 5000);

        AutoCompleteTextView v = (AutoCompleteTextView) getActivity()
                .findViewById(R.id.baseball_AutoCompleteTextView);
        getSolo().clickOnView(v);
        getSolo().typeText(v, "At");
    }
}
