package com.sportsbeep.app.ui.game.questions;

import com.metova.slim.annotation.Callback;
import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.ui.base.BaseFragment;
import com.sportsbeep.app.ui.view.FontTextView;
import com.sportsbeep.app.util.GameViewHelper;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import butterknife.InjectView;

public class BestBustFragment extends BaseFragment {

    private static final String EXTRA_GAME = "game";

    @InjectView(R.id.question_FontTextView)
    FontTextView mQuestionFontTextView;

    @InjectView(R.id.game_LinearLayout)
    View mGameView;

    @Extra(key = EXTRA_GAME)
    Game mGame;

    @Callback
    BestBustCallback mCallback;

    private String mQuestion;

    public static BestBustFragment newInstance(Game game) {
        BestBustFragment fragment = new BestBustFragment();

        Bundle args = new Bundle();
        args.putParcelable(EXTRA_GAME, game);
        fragment.setArguments(args);

        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_bestbust, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        GameViewHelper.populateWithGame(mGame, new GameViewHelper.Holder(mGameView),
                new GameViewHelper.OnTeamClickedListener() {
                    @Override
                    public void onTeamClicked(Team team) {
                        mCallback.onTeamSelected(team);
                    }

                    @Override
                    public void onTeamLongClicked(Team team) {
                        // no-op
                    }
                }
        );

        if (!TextUtils.isEmpty(mQuestion)) {
            displayQuestion(mQuestion);
        }
    }

    public void displayQuestion(String question) {
        mQuestion = question;
        if (mQuestionFontTextView != null) {
            mQuestionFontTextView.setText(question);
        }
    }

    public interface BestBustCallback {

        public void onTeamSelected(Team team);
    }
}
