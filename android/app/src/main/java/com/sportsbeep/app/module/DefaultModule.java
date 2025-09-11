package com.sportsbeep.app.module;

import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.storage.PreferenceHelper;
import com.sportsbeep.app.ui.account.CreateAccountActivity;
import com.sportsbeep.app.ui.account.CreateAccountFragment;
import com.sportsbeep.app.ui.account.FavoriteTeamFragment;
import com.sportsbeep.app.ui.account.ProfilePhotoDialogFragment;
import com.sportsbeep.app.ui.base.BaseActivityImpl;
import com.sportsbeep.app.ui.base.BaseFragmentImpl;
import com.sportsbeep.app.ui.contest.ContestActivity;
import com.sportsbeep.app.ui.contest.ContestDetailsActivity;
import com.sportsbeep.app.ui.contest.ContestDetailsFragment;
import com.sportsbeep.app.ui.contest.ContestListFragment;
import com.sportsbeep.app.ui.contest.IncompleteContestListFragment;
import com.sportsbeep.app.ui.contest.scoring.BestBustScoringActivity;
import com.sportsbeep.app.ui.contest.scoring.BestBustScoringFragment;
import com.sportsbeep.app.ui.contest.scoring.LeaguePickScoringActivity;
import com.sportsbeep.app.ui.contest.scoring.LeaguePickScoringFragment;
import com.sportsbeep.app.ui.contest.scoring.PlayerScoringActivity;
import com.sportsbeep.app.ui.contest.scoring.PlayerScoringFragment;
import com.sportsbeep.app.ui.contest.scoring.ScoringBreakdownActivity;
import com.sportsbeep.app.ui.contest.scoring.ScoringBreakdownFragment;
import com.sportsbeep.app.ui.contest.scoring.SquadScoringActivity;
import com.sportsbeep.app.ui.contest.scoring.SquadScoringFragment;
import com.sportsbeep.app.ui.game.buildteam.BuildTeamActivity;
import com.sportsbeep.app.ui.game.buildteam.BuildTeamFragment;
import com.sportsbeep.app.ui.game.buildteam.LeaguePickFragment;
import com.sportsbeep.app.ui.game.buildteam.PickPlayerFragment;
import com.sportsbeep.app.ui.game.buildteam.PickSquadFragment;
import com.sportsbeep.app.ui.game.pickgame.PickGameActivity;
import com.sportsbeep.app.ui.game.pickgame.PickGameFragment;
import com.sportsbeep.app.ui.game.pool.FundsDialogFragment;
import com.sportsbeep.app.ui.game.pool.PickPoolActivity;
import com.sportsbeep.app.ui.game.pool.PickPoolFragment;
import com.sportsbeep.app.ui.game.pool.ReadyContestDialogFragment;
import com.sportsbeep.app.ui.game.pool.SaveContestDialogFragment;
import com.sportsbeep.app.ui.game.questions.BestBustActivity;
import com.sportsbeep.app.ui.game.questions.BestBustFragment;
import com.sportsbeep.app.ui.game.questions.CountDownFragment;
import com.sportsbeep.app.ui.game.stats.PlayerStatsActivity;
import com.sportsbeep.app.ui.game.stats.PlayerStatsFragment;
import com.sportsbeep.app.ui.game.stats.TeamStatsActivity;
import com.sportsbeep.app.ui.game.stats.TeamStatsFragment;
import com.sportsbeep.app.ui.login.LoginActivity;
import com.sportsbeep.app.ui.login.LoginFragment;
import com.sportsbeep.app.ui.sport.PickSportActivity;
import com.sportsbeep.app.ui.sport.PickSportFragment;
import com.sportsbeep.app.ui.tutorial.HowToPlayActivity;
import com.sportsbeep.app.ui.tutorial.HowToPlayFragment;
import com.squareup.otto.Bus;

import javax.inject.Singleton;

import dagger.Module;
import dagger.Provides;

@Module(
        injects = {
                BaseActivityImpl.class,
                BaseFragmentImpl.class,
                LoginActivity.RemoveDeviceTokenTask.class,
                LoginActivity.class,
                LoginFragment.class,
                LoginFragment.SignInTask.class,
                CreateAccountActivity.class,
                CreateAccountFragment.class,
                CreateAccountFragment.CreateAccountTask.class,
                FavoriteTeamFragment.class,
                FavoriteTeamFragment.TeamsTask.class,
                FavoriteTeamFragment.SaveFavoriteTeamsTask.class,
                PickGameActivity.class,
                PickGameFragment.class,
                PickGameFragment.GamesTask.class,
                PickSportActivity.class,
                PickSportFragment.class,
                HowToPlayActivity.class,
                HowToPlayFragment.class,
                BuildTeamActivity.class,
                BuildTeamActivity.PlayersTask.class,
                BuildTeamActivity.LeaguePickGamesTask.class,
                BuildTeamActivity.DownloadTicketPlayersTask.class,
                BuildTeamActivity.UpdateTicketTask.class,
                BuildTeamFragment.class,
                PickPlayerFragment.class,
                LeaguePickFragment.class,
                PickPoolActivity.class,
                PickPoolActivity.CreateTicketTask.class,
                PickPoolActivity.DownloadQuestionsTask.class,
                PickPoolActivity.DownloadTimerStatesTask.class,
                PickPoolFragment.class,
                PickPoolFragment.PoolTask.class,
                ContestActivity.class,
                ContestListFragment.class,
                ContestListFragment.ContestTask.class,
                SaveContestDialogFragment.class,
                ReadyContestDialogFragment.class,
                BestBustActivity.class,
                BestBustFragment.class,
                BestBustActivity.SubmitAnswersTask.class,
                CountDownFragment.class,
                PlayerStatsActivity.class,
                PlayerStatsFragment.class,
                PlayerStatsFragment.StatsTask.class,
                ContestDetailsActivity.class,
                ContestDetailsFragment.class,
                ContestDetailsFragment.TicketsTask.class,
                IncompleteContestListFragment.class,
                ScoringBreakdownActivity.class,
                ScoringBreakdownFragment.class,
                ScoringBreakdownFragment.DownloadTicketPlayersTask.class,
                PickGameActivity.RegisterGCMTokenTask.class,
                PlayerScoringActivity.class,
                PlayerScoringFragment.class,
                PlayerScoringFragment.ScoresheetTask.class,
                SquadScoringActivity.class,
                SquadScoringFragment.class,
                SquadScoringFragment.ScoresheetTask.class,
                BestBustScoringActivity.class,
                BestBustScoringFragment.class,
                BestBustScoringFragment.AnswersTask.class,
                LeaguePickScoringActivity.class,
                LeaguePickScoringFragment.class,
                LeaguePickScoringFragment.TicketLeaguePickTask.class,
                LeaguePickScoringFragment.GameTask.class,
                LeaguePickScoringFragment.TeamTask.class,
                TeamStatsActivity.class,
                TeamStatsFragment.class,
                TeamStatsFragment.TeamRankingsTask.class,
                PickSquadFragment.class,
                ProfilePhotoDialogFragment.class,
                ProfilePhotoDialogFragment.UploadAvatarTask.class,
                ProfilePhotoDialogFragment.RemoveAvatarTask.class,
                FundsDialogFragment.class
        },
        includes = {
                ContextModule.class,
                NetworkModule.class,
                DatabaseModule.class,
                SharedPreferencesModule.class,
                AnalyticsModule.class
        }
)
public class DefaultModule {

    @Provides
    @Singleton
    Bus providesBus() {
        return new Bus();
    }

    @Provides
    Sport providesSport(PreferenceHelper prefs) {
        return prefs.getSport();
    }

    @Provides
    Level providesLevel(PreferenceHelper prefs) {
        return prefs.getLevel();
    }
}
