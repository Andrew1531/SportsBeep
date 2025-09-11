package com.sportsbeep.app.test.module;

import com.google.android.gms.analytics.GoogleAnalytics;
import com.google.android.gms.analytics.Tracker;

import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.gcm.GCMManager;
import com.sportsbeep.app.network.NetworkClient;
import com.sportsbeep.app.storage.GameDaoHelper;
import com.sportsbeep.app.storage.PreferenceHelper;
import com.sportsbeep.app.storage.TeamDaoHelper;
import com.sportsbeep.app.test.ui.BestBustActivityTest;
import com.sportsbeep.app.test.ui.BuildTeamActivityTest;
import com.sportsbeep.app.test.ui.ContestActivityTest;
import com.sportsbeep.app.test.ui.CreateAccountActivityTest;
import com.sportsbeep.app.test.ui.HowToPlayActivityTest;
import com.sportsbeep.app.test.ui.LoginActivityTest;
import com.sportsbeep.app.test.ui.PickGameActivityTest;
import com.sportsbeep.app.test.ui.PickPoolActivityTest;
import com.sportsbeep.app.test.ui.PickSportActivityTest;
import com.sportsbeep.app.ui.account.CreateAccountActivity;
import com.sportsbeep.app.ui.account.CreateAccountFragment;
import com.sportsbeep.app.ui.account.FavoriteTeamFragment;
import com.sportsbeep.app.ui.contest.ContestActivity;
import com.sportsbeep.app.ui.contest.ContestDetailsActivity;
import com.sportsbeep.app.ui.contest.ContestDetailsFragment;
import com.sportsbeep.app.ui.contest.ContestListFragment;
import com.sportsbeep.app.ui.game.buildteam.BuildTeamActivity;
import com.sportsbeep.app.ui.game.buildteam.BuildTeamFragment;
import com.sportsbeep.app.ui.game.pickgame.PickGameActivity;
import com.sportsbeep.app.ui.game.pickgame.PickGameFragment;
import com.sportsbeep.app.ui.game.pool.PickPoolActivity;
import com.sportsbeep.app.ui.game.pool.PickPoolFragment;
import com.sportsbeep.app.ui.game.questions.BestBustActivity;
import com.sportsbeep.app.ui.game.questions.BestBustFragment;
import com.sportsbeep.app.ui.game.questions.CountDownFragment;
import com.sportsbeep.app.ui.login.LoginActivity;
import com.sportsbeep.app.ui.login.LoginFragment;
import com.sportsbeep.app.ui.sport.PickSportActivity;
import com.sportsbeep.app.ui.sport.PickSportFragment;
import com.sportsbeep.app.ui.tutorial.HowToPlayActivity;
import com.sportsbeep.app.ui.tutorial.HowToPlayFragment;
import com.squareup.otto.Bus;

import org.mockito.Mockito;

import javax.inject.Singleton;

import dagger.Module;
import dagger.Provides;

@Module(
        injects = {
                LoginActivityTest.class,
                LoginActivity.class,
                LoginFragment.class,
                LoginFragment.SignInTask.class,
                CreateAccountActivityTest.class,
                CreateAccountActivity.class,
                CreateAccountFragment.class,
                CreateAccountFragment.CreateAccountTask.class,
                FavoriteTeamFragment.class,
                FavoriteTeamFragment.TeamsTask.class,
                FavoriteTeamFragment.SaveFavoriteTeamsTask.class,
                PickSportActivity.class,
                PickSportFragment.class,
                PickGameActivityTest.class,
                PickGameActivity.class,
                PickGameActivity.RegisterGCMTokenTask.class,
                PickGameFragment.class,
                PickGameFragment.GamesTask.class,
                PickSportActivityTest.class,
                PickSportActivity.class,
                PickSportFragment.class,
                BuildTeamActivityTest.class,
                BuildTeamActivity.class,
                BuildTeamFragment.class,
                BuildTeamActivity.PlayersTask.class,
                BuildTeamActivity.LeaguePickGamesTask.class,
                PickPoolActivity.class,
                PickPoolFragment.class,
                PickPoolActivityTest.class,
                BestBustActivity.class,
                BestBustActivity.SubmitAnswersTask.class,
                CountDownFragment.class,
                BestBustFragment.class,
                BestBustActivityTest.class,
                ContestActivity.class,
                ContestListFragment.class,
                ContestActivityTest.class,
                ContestDetailsActivity.class,
                ContestDetailsFragment.class,
                HowToPlayActivity.class,
                HowToPlayFragment.class,
                HowToPlayActivityTest.class
        },
        complete = false,
        overrides = true,
        library = true
)
public class TestModule {

    @Provides
    Sport providesSport() {
        return Sport.BASEBALL;
    }

    @Provides
    Level providesLevel() {
        return Level.PROFESSIONAL;
    }

    @Provides
    @Singleton
    NetworkClient provideNetworkClient() {
        return Mockito.mock(NetworkClient.class);
    }

    @Provides
    @Singleton
    PreferenceHelper providesPreferenceHelper() {
        return Mockito.mock(PreferenceHelper.class);
    }

    @Provides
    @Singleton
    TeamDaoHelper providesTeamDaoHelper() {
        return Mockito.mock(TeamDaoHelper.class);
    }

    @Provides
    @Singleton
    GameDaoHelper providesGameDaoHelper() {
        return Mockito.mock(GameDaoHelper.class);
    }

    @Provides
    @Singleton
    Bus providesBus() {
        return Mockito.mock(Bus.class);
    }

    @Provides
    @Singleton
    GCMManager providesGCMManager() {
        return Mockito.mock(GCMManager.class);
    }

    @Singleton
    @Provides
    GoogleAnalytics providesGoogleAnalytics() {
        return Mockito.mock(GoogleAnalytics.class);
    }

    @Provides
    @Singleton
    Tracker providesTracker() {
        return Mockito.mock(Tracker.class);
    }
}
