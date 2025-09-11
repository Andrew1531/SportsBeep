package com.sportsbeep.app.ui.game.pool;

import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.game.GamePosition;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.model.pool.Pool;
import com.sportsbeep.app.model.question.Question;
import com.sportsbeep.app.model.question.TimerState;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.model.ticket.IncompleteTicket;
import com.sportsbeep.app.model.ticket.Ticket;
import com.sportsbeep.app.network.params.ticket.CreateTicketParams;
import com.sportsbeep.app.network.params.ticket.LeaguePickTicketParams;
import com.sportsbeep.app.network.params.ticket.TicketParams;
import com.sportsbeep.app.storage.IncompleteTicketDaoHelper;
import com.sportsbeep.app.task.DeleteIncompleteTicketTask;
import com.sportsbeep.app.task.SaveIncompleteTicketTask;
import com.sportsbeep.app.task.network.NetworkAsyncTask;
import com.sportsbeep.app.ui.base.BaseNavigationActivity;
import com.sportsbeep.app.ui.game.buildteam.BuildTeamActivity;
import com.sportsbeep.app.ui.game.pickgame.PickGameActivity;
import com.sportsbeep.app.ui.game.questions.BestBustActivity;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.os.Parcelable;
import android.support.v4.app.FragmentTransaction;

import java.util.ArrayList;
import java.util.List;

import javax.inject.Inject;

public class PickPoolActivity extends BaseNavigationActivity
        implements PickPoolFragment.PickPoolCallback {

    public static final String EXTRA_TICKET = "ticket";

    public static final String TAG_READY_CONTEST = "ready_contest";

    public static final String TAG_SAVE_CONTEST = "save_contest";

    @Inject
    IncompleteTicketDaoHelper mIncompleteTicketDaoHelper;

    @Extra(key = EXTRA_TICKET)
    IncompleteTicket mIncompleteTicket;

    ProgressDialog mProgressDialog;

    CreateTicketTask mCreateTicketTask;

    Ticket mTicket;

    List<Question> mQuestions;

    List<TimerState> mTimerStates;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState == null) {
            FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
            ft.add(R.id.content, PickPoolFragment.newInstance(mIncompleteTicket.getGame()));
            ft.commit();
        }

        mProgressDialog = new ProgressDialog(this);
        mProgressDialog.setMessage(getString(R.string.entering_pool));
        mProgressDialog.setCancelable(false);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (mCreateTicketTask != null) {
            mCreateTicketTask.cancel(true);
        }
    }

    @Override
    public void onPoolClicked(Pool pool) {
        showReadyContestDialog(pool);
    }

    public void showReadyContestDialog(final Pool pool) {
        final ReadyContestDialogFragment fragment = ReadyContestDialogFragment.newInstance();
        fragment.setCancelable(false);
        fragment.setReadyContestClickListener(
                new ReadyContestDialogFragment.ReadyContestClickListener() {
                    @Override
                    public void onYesClicked() {
                        List<TicketParams.TicketPositionParam> players = new ArrayList<TicketParams.TicketPositionParam>();
                        List<TicketParams.TicketPositionParam> squads = new ArrayList<TicketParams.TicketPositionParam>();
                        for (GamePosition gamePosition : mIncompleteTicket.getPositionMap().keySet()) {
                            Object obj = mIncompleteTicket.getPositionMap().get(gamePosition);
                            if (obj instanceof Player) {
                                TicketParams.TicketPositionParam playerParam = new TicketParams.TicketPositionParam(((Player) obj).getId(), gamePosition.getPositionGroupTitleResName());
                                players.add(playerParam);
                            } else if (obj instanceof Team) {
                                TicketParams.TicketPositionParam squadParam = new TicketParams.TicketPositionParam(((Team) obj).getId(), gamePosition.getPositionGroupTitleResName());
                                squads.add(squadParam);
                            }
                        }

                        long gameId = mIncompleteTicket.getGame().getId();
                        long poolId = pool.getId();

                        TicketParams ticketParams;
                        if (mIncompleteTicket.getLeaguePickTeam() != null && mIncompleteTicket.getLeaguePickGame() != null) {
                            long leaguePickGameId = mIncompleteTicket.getLeaguePickGame().getId();
                            long leaguePickTeamId = mIncompleteTicket.getLeaguePickTeam().getId();
                            ticketParams = new LeaguePickTicketParams(players, squads, leaguePickGameId, leaguePickTeamId);
                        } else {
                            ticketParams = new TicketParams(players, squads);
                        }

                        mCreateTicketTask = new CreateTicketTask();
                        mCreateTicketTask.execute(new CreateTicketParams(ticketParams, gameId, poolId));
                    }

                    @Override
                    public void onCancelClicked() {
                        showSaveContestDialog();
                    }
                }
        );
        fragment.show(getSupportFragmentManager(), TAG_READY_CONTEST);
    }

    public void showSaveContestDialog() {
        final SaveContestDialogFragment fragment = SaveContestDialogFragment.newInstance();
        fragment.setCancelable(false);
        fragment.setSaveContestClickListener(
                new SaveContestDialogFragment.SaveContestClickListener() {
                    @Override
                    public void onContinueClicked() {
                        showBuildTeamScreen();
                    }

                    @Override
                    public void onSaveClicked() {
                        new SaveIncompleteTicketTask().execute(mIncompleteTicket);
                        showPickGameScreen();
                    }

                    @Override
                    public void onCancelClicked() {
                        if (mIncompleteTicket.getId() != 0) {
                            new DeleteIncompleteTicketTask().execute(mIncompleteTicket);
                        }
                        showPickGameScreen();
                    }
                }
        );
        fragment.show(getSupportFragmentManager(), TAG_SAVE_CONTEST);
    }

    private void showPickGameScreen() {
        Intent intent = new Intent(PickPoolActivity.this, PickGameActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);
    }

    private void showBuildTeamScreen() {
        Intent intent = new Intent(PickPoolActivity.this, BuildTeamActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        startActivity(intent);
    }

    private void onTicketCreated(Ticket ticket) {
        if (mIncompleteTicket.getId() != 0) {
            mIncompleteTicketDaoHelper.deleteTicket(mIncompleteTicket);
        }

        mTicket = ticket;

        DownloadQuestionsTask task = new DownloadQuestionsTask();
        task.execute(mTicket.getId());
    }

    private void onQuestionsDownloaded(List<Question> questions) {
        mQuestions = questions;

        DownloadTimerStatesTask task = new DownloadTimerStatesTask();
        task.execute(mTicket.getId());
    }

    private void onTimerStatesDownloaded(List<TimerState> timerStates) {
        mTimerStates = timerStates;

        Intent intent = new Intent(this, BestBustActivity.class);
        intent.putExtra(BestBustActivity.EXTRA_GAME, mIncompleteTicket.getGame());
        intent.putParcelableArrayListExtra(BestBustActivity.EXTRA_QUESTIONS,
                new ArrayList<Parcelable>(mQuestions));
        intent.putParcelableArrayListExtra(BestBustActivity.EXTRA_TIMER_STATES,
                new ArrayList<Parcelable>(mTimerStates));
        intent.putExtra(BestBustActivity.EXTRA_TICKET_ID, mTicket.getId());
        startActivity(intent);
    }

    public class CreateTicketTask extends NetworkAsyncTask<CreateTicketParams, Void, Ticket> {

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            mProgressDialog.show();
        }

        @Override
        protected Result<Ticket> doInBackground(CreateTicketParams... params) {
            CreateTicketParams param = params[0];
            return getClient().createTicket(getSport(), getLevel(), param);
        }

        @Override
        protected void onError(String errorMessage) {
            super.onError(errorMessage);
            mProgressDialog.dismiss();
        }

        @Override
        protected void onSuccess(Ticket ticket) {
            super.onSuccess(ticket);
            onTicketCreated(ticket);
        }
    }

    public class DownloadQuestionsTask extends NetworkAsyncTask<Long, Void, List<Question>> {

        @Override
        protected Result<List<Question>> doInBackground(Long... params) {
            long ticketId = params[0];
            return getClient().getQuestions(getSport(), getLevel(), ticketId);
        }

        @Override
        protected void onError(String errorMessage) {
            super.onError(errorMessage);
            mProgressDialog.dismiss();
        }

        @Override
        protected void onSuccess(List<Question> questions) {
            super.onSuccess(questions);
            onQuestionsDownloaded(questions);
        }
    }

    public class DownloadTimerStatesTask extends NetworkAsyncTask<Long, Void, List<TimerState>> {

        @Override
        protected Result<List<TimerState>> doInBackground(Long... params) {
            long ticketId = params[0];
            return getClient().getTimerStates(getSport(), getLevel(), ticketId);
        }

        @Override
        protected void onFinished() {
            super.onFinished();
            mProgressDialog.dismiss();
        }

        @Override
        protected void onSuccess(List<TimerState> timerStates) {
            super.onSuccess(timerStates);
            onTimerStatesDownloaded(timerStates);
        }
    }
}
