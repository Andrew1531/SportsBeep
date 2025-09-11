package com.sportsbeep.app.ui.game.questions;

import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.question.Question;
import com.sportsbeep.app.model.question.QuestionAnswer;
import com.sportsbeep.app.model.question.TimerState;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.network.params.AnswerParams;
import com.sportsbeep.app.task.network.NetworkAsyncTask;
import com.sportsbeep.app.ui.base.BaseActivity;
import com.sportsbeep.app.ui.game.pickgame.PickGameActivity;
import com.sportsbeep.app.ui.view.ArcCountDownView;
import com.sportsbeep.app.ui.view.FontTextView;
import com.sportsbeep.app.util.TimerStateDecoderWrapper;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentTransaction;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.List;

import butterknife.ButterKnife;
import butterknife.InjectView;

public class BestBustActivity extends BaseActivity
        implements CountDownFragment.CountDownCallback, BestBustFragment.BestBustCallback {

    public static final String EXTRA_QUESTIONS = "questions";

    public static final String EXTRA_TIMER_STATES = "timer_states";

    public static final String EXTRA_GAME = "game";

    public static final String EXTRA_TICKET_ID = "ticket_id";

    private final List<QuestionAnswer> mAnswers = new ArrayList<QuestionAnswer>();

    @InjectView(R.id.header_RelativeLayout)
    RelativeLayout mHeaderRelativeLayout;

    @InjectView(R.id.bestbust_FontTextView)
    FontTextView mBestBustFontTextView;

    @InjectView(R.id.questionPosition_FontTextView)
    FontTextView mQuestionPositionFontTextView;

    @InjectView(R.id.timer_ArcCountDownView)
    ArcCountDownView mTimerArcCountDownView;

    @Extra(key = EXTRA_QUESTIONS)
    ArrayList<Question> mQuestions;

    @Extra(key = EXTRA_TIMER_STATES)
    List<TimerState> mTimerStates;

    @Extra(key = EXTRA_GAME)
    Game mGame;

    @Extra(key = EXTRA_TICKET_ID)
    long mTicketId;

    private BestBustFragment mBestBustFragment;

    private int mQuestionIndex = -1;

    private TimerStateDecoderWrapper mDecoderWrapper;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState != null) {
            onAnswersSubmitted();
        } else {
            setContentView(R.layout.activity_bestbust);
            ButterKnife.inject(this);

            mDecoderWrapper = new TimerStateDecoderWrapper(mTicketId);
            mDecoderWrapper.addTimerStates(mTimerStates);

            if (savedInstanceState == null) {
                FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
                ft.add(R.id.fragment_container, CountDownFragment.newInstance());
                ft.commit();
            } else {
                Fragment fragment = getSupportFragmentManager().findFragmentById(R.id.fragment_container);
                if (fragment instanceof BestBustFragment) {
                    mBestBustFragment = (BestBustFragment) fragment;
                }
            }
        }
    }

    @Override
    protected void onDestroy() {
        if (mTimerArcCountDownView != null) {
            mTimerArcCountDownView.pause();
        }
        super.onDestroy();
    }

    @Override
    public void onBackPressed() {
        // Prevent the user from leaving this screen
    }

    @Override
    public void onCountDownFinished() {
        mBestBustFragment = BestBustFragment.newInstance(mGame);

        FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
        ft.replace(R.id.fragment_container, mBestBustFragment);
        ft.commit();

        getSupportFragmentManager().executePendingTransactions();

        mTimerArcCountDownView.setTimeStart(TimerStateDecoderWrapper.SECONDS * 1000);
        mTimerArcCountDownView
                .setOnCountDownFinishedListener(new ArcCountDownView.OnCountDownFinishedListener() {
                    @Override
                    public void onFinished() {
                        addAnswer(mQuestions.get(mQuestionIndex), 0, 0);
                        displayNextQuestion();
                    }
                });
        mTimerArcCountDownView.start();

        displayNextQuestion();

        mHeaderRelativeLayout.setVisibility(View.VISIBLE);
    }

    @Override
    public void onTeamSelected(Team team) {
        if (mQuestionIndex < mQuestions.size()) {
            mTimerArcCountDownView.pause();
            addAnswer(mQuestions.get(mQuestionIndex), team.getId(),
                    mTimerArcCountDownView.getTimeRemaining());
            displayNextQuestion();
        }
    }

    private void addAnswer(Question question, long teamId, long millis) {
        String time = mDecoderWrapper.getTime(millis);
        mAnswers.add(new QuestionAnswer(question.getId(), teamId, time));
    }

    void displayNextQuestion() {
        if (++mQuestionIndex < mQuestions.size()) {
            displayQuestion(mQuestionIndex);
        } else {
            onQuestionsCompleted();
        }
    }

    private void onQuestionsCompleted() {
        mTimerArcCountDownView.setOnCountDownFinishedListener(null);
        SubmitAnswersTask task = new SubmitAnswersTask();
        task.execute();
    }

    private void onAnswersSubmitted() {
        Intent intent = new Intent(this, PickGameActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(intent);
    }

    private void displayQuestion(int index) {
        Question question = mQuestions.get(index);
        mBestBustFragment.displayQuestion(question.getText());

        int resId;
        if (Question.TYPE_BEST.equals(question.getType())) {
            resId = R.string.bests;
        } else {
            resId = R.string.busts;
        }
        mBestBustFontTextView.setText(resId);

        mQuestionPositionFontTextView
                .setText(getString(R.string.question, index + 1, mQuestions.size()));
        restartCountDown();
    }

    private void restartCountDown() {
        mTimerArcCountDownView.reset();
        mTimerArcCountDownView.start();
    }

    public class SubmitAnswersTask extends NetworkAsyncTask<Void, Void, Void> {

        ProgressDialog mDialog;

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            if (!isFinishing()) {
                mDialog = ProgressDialog.show(BestBustActivity.this, null, getString(R.string.submitting_answers), true, false);
            }
        }

        @Override
        protected Result<Void> doInBackground(Void... params) {
            return getClient().submitTicketAnswers(getSport(), getLevel(), mTicketId, new AnswerParams(mAnswers));
        }

        @Override
        protected void onFinished() {
            super.onFinished();
            if (mDialog != null) {
                mDialog.dismiss();
            }
            onAnswersSubmitted();
        }

        @Override
        protected void onSuccess(Void aVoid) {
            super.onSuccess(aVoid);
            Toast.makeText(BestBustActivity.this, R.string.entered_contest, Toast.LENGTH_SHORT).show();
        }
    }
}
