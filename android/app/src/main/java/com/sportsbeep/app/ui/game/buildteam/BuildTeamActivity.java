package com.sportsbeep.app.ui.game.buildteam;

import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.event.LeaguePickEvent;
import com.sportsbeep.app.event.PlayersEvent;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.game.GamePosition;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.model.ticket.IncompleteTicket;
import com.sportsbeep.app.model.ticket.TicketPlayer;
import com.sportsbeep.app.model.ticket.TicketPositions;
import com.sportsbeep.app.model.ticket.TicketSquad;
import com.sportsbeep.app.network.params.ticket.LeaguePickTicketParams;
import com.sportsbeep.app.network.params.ticket.TicketParams;
import com.sportsbeep.app.network.params.ticket.UpdateTicketParams;
import com.sportsbeep.app.storage.PlayerDaoHelper;
import com.sportsbeep.app.storage.TeamDaoHelper;
import com.sportsbeep.app.task.DeleteIncompleteTicketTask;
import com.sportsbeep.app.task.SaveIncompleteTicketTask;
import com.sportsbeep.app.task.network.NetworkAsyncTask;
import com.sportsbeep.app.ui.base.BaseNavigationActivity;
import com.sportsbeep.app.ui.contest.ContestActivity;
import com.sportsbeep.app.ui.game.pickgame.PickGameActivity;
import com.sportsbeep.app.ui.game.pool.PickPoolActivity;
import com.sportsbeep.app.ui.game.pool.SaveContestDialogFragment;
import com.sportsbeep.app.ui.game.stats.PlayerStatsActivity;
import com.sportsbeep.app.ui.game.stats.TeamStatsActivity;
import com.squareup.otto.Produce;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Parcelable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.concurrent.Executor;

import javax.inject.Inject;

public class BuildTeamActivity extends BaseNavigationActivity implements BuildTeamFragment.BuildTeamCallback, PickPlayerFragment.PickPlayerCallback, LeaguePickFragment.LeaguePickCallback,
        PickSquadFragment.PickSquadCallback {

    public static final String EXTRA_GAME = "game";

    public static final String EXTRA_INCOMPLETE_TICKET = "incomplete_ticket";

    public static final String EXTRA_TICKET_ID = "ticket_id";

    private static final String TAG_BUILD_TEAM_FRAGMENT = "build_team_fragment";

    private static final String TAG_SAVE_CONTEST = "save_contest";

    @Extra(key = EXTRA_GAME)
    Game mGame;

    @Extra(key = EXTRA_INCOMPLETE_TICKET, optional = true)
    IncompleteTicket mTicket;

    @Extra(key = EXTRA_TICKET_ID, optional = true)
    long mTicketId = -1;

    @Inject
    PlayerDaoHelper mPlayerDaoHelper;

    @Inject
    TeamDaoHelper mTeamDaoHelper;

    List<Game> mLeaguePickGames;

    BuildTeamFragment mBuildTeamFragment;

    GamePosition mActiveGamePosition;

    GamePosition mCarouselPositionStart;

    boolean mShowPositionCarousel = true;

    PlayersTask mPlayersTask;

    LeaguePickGamesTask mLeaguePickGamesTask;

    DownloadTicketPlayersTask mDownloadTicketTask;

    private UpdateTicketTask mUpdateTicketTask;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mShowPositionCarousel = mTicket == null && !isInEditTicketMode();

        if (mTicket == null) {
            mTicket = new IncompleteTicket();
            mTicket.setGame(mGame);
        }

        if (savedInstanceState == null) {
            mBuildTeamFragment = BuildTeamFragment.newInstance(mGame, isInEditTicketMode());
            mBuildTeamFragment.setRetainInstance(true);

            FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
            ft.add(R.id.content, mBuildTeamFragment, TAG_BUILD_TEAM_FRAGMENT);
            ft.commit();
        } else {
            mBuildTeamFragment = (BuildTeamFragment) getSupportFragmentManager().findFragmentByTag(TAG_BUILD_TEAM_FRAGMENT);

            mTicket = savedInstanceState.getParcelable(EXTRA_INCOMPLETE_TICKET);
            for (GamePosition gamePosition : mTicket.getPositionMap().keySet()) {
                Object object = mTicket.getPositionMap().get(gamePosition);
                if (object instanceof Player) {
                    mBuildTeamFragment.setPosition(gamePosition, (Player) object);
                } else if (object instanceof Team) {
                    mBuildTeamFragment.setPosition(gamePosition, (Team) object);
                }
            }
        }

        Executor executor = isInEditTicketMode() ? AsyncTask.SERIAL_EXECUTOR : AsyncTask.THREAD_POOL_EXECUTOR;

        mPlayersTask = new PlayersTask();
        mPlayersTask.executeOnExecutor(executor);

        if (getSport().hasLeaguePick()) {
            mLeaguePickGamesTask = new LeaguePickGamesTask();
            mLeaguePickGamesTask.executeOnExecutor(executor);
        }

        if (isInEditTicketMode()) {
            if (getSport().hasLeaguePick() && mTicket.getLeaguePickTeam() != null) {
                Team leaguePickTeam = mTeamDaoHelper.getTeam(mTicket.getLeaguePickTeam());
                mTicket.setLeaguePickTeam(leaguePickTeam);
            }

            mDownloadTicketTask = new DownloadTicketPlayersTask();
            mDownloadTicketTask.executeOnExecutor(executor, mTicketId);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        getBus().register(this);
    }

    @Override
    protected void onPause() {
        super.onPause();
        getBus().unregister(this);
    }

    @Override
    protected void onDestroy() {
        if (mPlayersTask != null) {
            mPlayersTask.cancel(true);
        }

        if (mLeaguePickGamesTask != null) {
            mLeaguePickGamesTask.cancel(true);
        }

        if (mDownloadTicketTask != null) {
            mDownloadTicketTask.cancel(true);
        }

        if (mUpdateTicketTask != null) {
            mUpdateTicketTask.cancel(true);
        }
        super.onDestroy();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putParcelable(EXTRA_INCOMPLETE_TICKET, mTicket);
    }

    @Override
    public void onBackPressed() {
        Fragment fragment = getSupportFragmentManager().findFragmentById(R.id.content);
        if (fragment != mBuildTeamFragment) {
            showBuildTeamFragment();
        } else {
            if (!mTicket.getPositionMap().isEmpty() || mTicket.getLeaguePickTeam() != null) {
                showSaveContestDialog();
            } else {
                super.onBackPressed();
            }
        }
    }

    public void showSaveContestDialog() {
        final SaveContestDialogFragment fragment = SaveContestDialogFragment.newInstance();
        fragment.setCancelable(false);
        fragment.setSaveContestClickListener(
                new SaveContestDialogFragment.SaveContestClickListener() {
                    @Override
                    public void onContinueClicked() {
                        // no-op
                    }

                    @Override
                    public void onSaveClicked() {
                        if (isInEditTicketMode()) {
                            updateTicket();
                        } else {
                            new SaveIncompleteTicketTask().execute(mTicket);
                            showPickGameScreen();
                        }
                    }

                    @Override
                    public void onCancelClicked() {
                        if (isInEditTicketMode()) {
                            showMyContestsScreen();
                        } else {
                            if (mTicket.getId() != 0) {
                                new DeleteIncompleteTicketTask().execute(mTicket);
                            }
                            showPickGameScreen();
                        }
                    }
                }
        );
        fragment.show(getSupportFragmentManager(), TAG_SAVE_CONTEST);
    }

    private void updateTicket() {
        List<TicketParams.TicketPositionParam> players = new ArrayList<TicketParams.TicketPositionParam>();
        List<TicketParams.TicketPositionParam> squads = new ArrayList<TicketParams.TicketPositionParam>();
        for (GamePosition gamePosition : mTicket.getPositionMap().keySet()) {
            Object obj = mTicket.getPositionMap().get(gamePosition);
            if (obj instanceof Player) {
                TicketParams.TicketPositionParam playerParam = new TicketParams.TicketPositionParam(((Player) obj).getId(), gamePosition.getPositionGroupTitleResName());
                players.add(playerParam);
            } else if (obj instanceof Team) {
                TicketParams.TicketPositionParam squadParams = new TicketParams.TicketPositionParam(((Team) obj).getId(), gamePosition.getPositionGroupTitleResName());
                squads.add(squadParams);
            }
        }

        TicketParams ticketParams;
        if (mTicket.getLeaguePickTeam() != null && mTicket.getLeaguePickGame() != null) {
            long leaguePickGameId = mTicket.getLeaguePickGame().getId();
            long leaguePickTeamId = mTicket.getLeaguePickTeam().getId();
            ticketParams = new LeaguePickTicketParams(players, squads, leaguePickGameId, leaguePickTeamId);
        } else {
            ticketParams = new TicketParams(players, squads);
        }

        mUpdateTicketTask = new UpdateTicketTask();
        mUpdateTicketTask.execute(new UpdateTicketParams(ticketParams));
    }

    private void showPickGameScreen() {
        Intent intent = new Intent(this, PickGameActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);
    }

    private void showMyContestsScreen() {
        Intent intent = new Intent(this, ContestActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);
    }

    @Override
    public void onBuildTeamFragmentViewCreated() {
        mBuildTeamFragment.setPositionMap(mTicket.getPositionMap());
        mBuildTeamFragment.setPosition(GamePosition.LEAGUE_PICK, mTicket.getLeaguePickTeam());

        checkRosterFull();
    }

    @Override
    public void onPositionClicked(GamePosition gamePosition) {
        showGamePositionFragment(gamePosition);
    }

    @Override
    public void onSubmitTeam() {
        if (isInEditTicketMode()) {
            updateTicket();
        } else {
            Intent intent = new Intent(this, PickPoolActivity.class);
            intent.putExtra(PickPoolActivity.EXTRA_TICKET, mTicket);
            startActivity(intent);
        }
    }

    @Override
    public void onPlayerClicked(GamePosition gamePosition, Player player) {
        if (isValidPositionSelection(gamePosition, player)) {
            mTicket.putPlayer(gamePosition, player);
            mBuildTeamFragment.setPosition(gamePosition, player);
            checkRosterFull();

            transition();
        } else {
            onPositionsLimitReached();
        }
    }

    @Override
    public void onPlayerLongClicked(Player player) {
        Intent intent = new Intent(this, PlayerStatsActivity.class);
        intent.putExtra(PlayerStatsActivity.EXTRA_PLAYER, (android.os.Parcelable) player);
        startActivity(intent);
    }

    @Override
    public void onTeamClicked(GamePosition gamePosition, Team team) {
        if (isValidPositionSelection(gamePosition, team)) {
            mTicket.putSquad(gamePosition, team);
            mBuildTeamFragment.setPosition(gamePosition, team);
            checkRosterFull();

            transition();
        } else {
            onPositionsLimitReached();
        }
    }

    @Override
    public void onTeamLongClicked(GamePosition gamePosition, Team team) {
        Intent intent = new Intent(this, TeamStatsActivity.class);
        intent.putExtra(TeamStatsActivity.EXTRA_TEAM, (Parcelable) team);
        intent.putExtra(TeamStatsActivity.EXTRA_GAME, mGame);
        startActivity(intent);
    }

    @Override
    public void onLeaguePickSelected(Game leaguePickGame, Team leaguePickTeam) {
        mTicket.setLeaguePickGame(leaguePickGame);
        mTicket.setLeaguePickTeam(leaguePickTeam);
        mBuildTeamFragment.setPosition(GamePosition.LEAGUE_PICK, leaguePickTeam);
        checkRosterFull();

        transition();
    }

    @Override
    public void onLeaguePickLongClicked(Game leaguePickGame, Team leaguePickTeam) {
        Intent intent = new Intent(this, TeamStatsActivity.class);
        intent.putExtra(TeamStatsActivity.EXTRA_GAME, leaguePickGame);
        intent.putExtra(TeamStatsActivity.EXTRA_TEAM, (Parcelable) leaguePickTeam);
        startActivity(intent);
    }

    private void onPositionsLimitReached() {
        Toast.makeText(this, R.string.max_team_players, Toast.LENGTH_LONG).show();
    }

    private void checkRosterFull() {
        int gamePositions = getSport().getGamePositions().length;
        int positionsFilled = mTicket.getPositionMap().size();

        if (mTicket.getLeaguePickTeam() != null) {
            positionsFilled++;
        }

        boolean rosterFull = gamePositions == positionsFilled;
        mBuildTeamFragment.setSubmitButtonEnabled(rosterFull);
        if (rosterFull && mShowPositionCarousel) {
            mBuildTeamFragment.scrollToBottom();
        }
    }

    private void transition() {
        if (mShowPositionCarousel) {
            transitionToNextPosition();
        } else {
            showBuildTeamFragment();
        }
    }

    private void transitionToNextPosition() {
        GamePosition nextGamePosition = getNextGamePosition(mActiveGamePosition);
        if (nextGamePosition != null && !nextGamePosition.equals(mCarouselPositionStart)) {
            showGamePositionFragment(nextGamePosition);
        } else {
            showBuildTeamFragment();
        }
    }

    private boolean isValidPositionSelection(GamePosition position, Player player) {
        Player currentPlayer = (Player) mTicket.getPositionMap().get(position);
        return currentPlayer != null && currentPlayer.getTeam().equals(player.getTeam()) || getTeamPlayerCount(player.getTeam()) < getSport().getMaxTeamPositions();
    }

    private boolean isValidPositionSelection(GamePosition position, Team team) {
        Team currentTeam = (Team) mTicket.getPositionMap().get(position);
        return currentTeam != null && currentTeam.equals(team) || getTeamPlayerCount(team) < getSport().getMaxTeamPositions();
    }

    private int getTeamPlayerCount(Team team) {
        int count = 0;

        Collection<Object> values = mTicket.getPositionMap().values();
        for (Object value : values) {
            if (value instanceof Player) {
                if (((Player) value).getTeam().getId() == team.getId()) {
                    count++;
                }
            } else if (value instanceof Team) {
                if (((Team) value).getId() == team.getId()) {
                    count++;
                }
            }
        }

        return count;
    }

    private long[] getPlayerIds(GamePosition excludedPosition) {
        List<GamePosition> keys = new ArrayList<GamePosition>();
        for (GamePosition gamePosition : mTicket.getPositionMap().keySet()) {
            if (!gamePosition.isSquad() && !GamePosition.LEAGUE_PICK.equals(gamePosition)) {
                keys.add(gamePosition);
            }
        }

        if (excludedPosition != null) {
            keys.remove(excludedPosition);
        }

        long[] playerIds = new long[keys.size()];
        for (int i = 0; i < keys.size(); i++) {
            GamePosition gamePosition = keys.get(i);

            Player player = (Player) mTicket.getPositionMap().get(gamePosition);
            playerIds[i] = player.getId();
        }

        return playerIds;
    }

    private void showGamePositionFragment(GamePosition gamePosition) {
        Fragment fragment;
        if (gamePosition == GamePosition.LEAGUE_PICK) {
            fragment = LeaguePickFragment.newInstance();
        } else if (gamePosition.isSquad()) {
            fragment = PickSquadFragment.newInstance(mGame, gamePosition);
        } else {
            long homeTeamId = 0;
            if (mGame.getHomeTeam() != null) {
                homeTeamId = mGame.getHomeTeam().getId();
            }

            fragment = PickPlayerFragment.newInstance(mGame.getId(), homeTeamId, gamePosition, getPlayerIds(gamePosition));
        }

        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        ft.setCustomAnimations(R.anim.slide_in_right, R.anim.slide_out_left);
        if (!mBuildTeamFragment.isDetached()) {
            ft.detach(mBuildTeamFragment);
            ft.add(R.id.content, fragment);
        } else {
            ft.replace(R.id.content, fragment);
        }
        ft.commit();

        if (mShowPositionCarousel && mCarouselPositionStart == null) {
            mCarouselPositionStart = gamePosition;
        }

        mActiveGamePosition = gamePosition;
    }

    private void showBuildTeamFragment() {
        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        for (Fragment fragment : getSupportFragmentManager().getFragments()) {
            if (fragment != null && mBuildTeamFragment != fragment) {
                ft.remove(fragment);
            }
        }
        ft.attach(mBuildTeamFragment);
        ft.commit();

        mShowPositionCarousel = false;
    }

    private GamePosition getNextGamePosition(GamePosition gamePosition) {
        List<GamePosition> gamePositions = Arrays.asList(getSport().getGamePositions());
        int index = gamePositions.indexOf(gamePosition);
        int nextIndex = index + 1;
        if (nextIndex < gamePositions.size()) {
            return gamePositions.get(nextIndex);
        } else {
            return gamePositions.get(0);
        }
    }

    private Game findLeaguePickGameById(long id) {
        if (mLeaguePickGames == null) {
            throw new IllegalStateException("League pick games have not been downloaded yet.");
        }

        for (Game game : mLeaguePickGames) {
            if (id == game.getId()) {
                return game;
            }
        }

        return null;
    }

    private boolean isInEditTicketMode() {
        return mTicketId != -1;
    }

    @Produce
    public LeaguePickEvent produceLeaguePickGames() {
        if (mLeaguePickGames != null) {
            return new LeaguePickEvent(mLeaguePickGames);
        }

        return null;
    }

    public class PlayersTask extends NetworkAsyncTask<Void, Void, List<Player>> {

        @Override
        protected Result<List<Player>> doInBackground(Void... params) {
            return getClient().getPlayersForGame(getSport(), getLevel(), mGame.getId());
        }

        @Override
        protected void onSuccess(List<Player> players) {
            super.onSuccess(players);
            getBus().post(new PlayersEvent(players));
        }
    }

    public class LeaguePickGamesTask extends NetworkAsyncTask<Void, Void, List<Game>> {

        @Override
        protected Result<List<Game>> doInBackground(Void... params) {
            return getClient().getLeaguePicks(getSport(), getLevel(), mGame.getId());
        }

        @Override
        protected void onSuccess(List<Game> games) {
            super.onSuccess(games);
            mLeaguePickGames = games;
            getBus().post(new LeaguePickEvent(games));
        }
    }

    public class DownloadTicketPlayersTask extends NetworkAsyncTask<Long, Void, TicketPositions> {

        @Override
        protected Result<TicketPositions> doInBackground(Long... params) {
            long ticketId = params[0];
            return getClient().getPositionsForTicket(getSport(), getLevel(), ticketId);
        }

        @Override
        protected void onSuccess(TicketPositions positions) {
            super.onSuccess(positions);
            for (TicketPlayer ticketPlayer : positions.getPlayers()) {
                GamePosition gamePosition = getSport().findGamePositionByTitleResName(ticketPlayer.getGamePosition());
                long playerId = ticketPlayer.getPlayerId();
                Player player = mPlayerDaoHelper.getPlayer(playerId);

                onPlayerClicked(gamePosition, player);
            }

            for (TicketSquad ticketSquad : positions.getSquads()) {
                GamePosition gamePosition = getSport().findGamePositionByTitleResName(ticketSquad.getGamePosition());
                long teamId = ticketSquad.getTeamId();
                Team team = mTeamDaoHelper.getTeam(teamId);

                onTeamClicked(gamePosition, team);
            }

            mBuildTeamFragment.displayList();
        }
    }

    public class UpdateTicketTask extends NetworkAsyncTask<UpdateTicketParams, Void, Void> {

        ProgressDialog mDialog;

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            mDialog = ProgressDialog.show(BuildTeamActivity.this, null, getString(R.string.saving_ticket), true, false);
        }

        @Override
        protected Result<Void> doInBackground(UpdateTicketParams... params) {
            UpdateTicketParams param = params[0];
            return getClient().updateTicket(getSport(), getLevel(), mTicketId, param);
        }

        @Override
        protected void onFinished() {
            super.onFinished();
            if (mDialog != null) {
                mDialog.dismiss();
            }

            finish();
        }

        @Override
        protected void onSuccess(Void aVoid) {
            super.onSuccess(aVoid);
            Toast.makeText(BuildTeamActivity.this, getString(R.string.ticket_updated), Toast.LENGTH_SHORT).show();
        }
    }
}
