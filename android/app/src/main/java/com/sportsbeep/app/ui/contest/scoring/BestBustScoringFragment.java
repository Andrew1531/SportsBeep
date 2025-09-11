package com.sportsbeep.app.ui.contest.scoring;

import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.adapter.AnswersAdapter;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.question.Answer;
import com.sportsbeep.app.network.NetworkClient;
import com.sportsbeep.app.task.network.NetworkAsyncTask;
import com.sportsbeep.app.ui.base.BaseListFragment;
import com.sportsbeep.app.util.AnimUtil;
import com.sportsbeep.app.util.GameViewHelper;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;

import java.util.List;

import butterknife.InjectView;

public class BestBustScoringFragment extends BaseListFragment {

    public static final String EXTRA_TICKET_ID = "ticket_id";

    public static final String EXTRA_GAME = "game";

    @Extra(key = EXTRA_TICKET_ID)
    long mTicketId;

    @Extra(key = EXTRA_GAME)
    Game mGame;

    @InjectView(android.R.id.progress)
    ProgressBar mProgressBar;

    @InjectView(R.id.game_LinearLayout)
    View mGameView;

    AnswersTask mAnswersTask;

    public static BestBustScoringFragment newInstance(long ticketId, Game game) {
        BestBustScoringFragment fragment = new BestBustScoringFragment();

        Bundle args = new Bundle();
        args.putLong(EXTRA_TICKET_ID, ticketId);
        args.putParcelable(EXTRA_GAME, game);
        fragment.setArguments(args);

        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_bestbust_breakdown, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        View header = LayoutInflater.from(getActivity()).inflate(R.layout.item_bestbust_breakdown_header, getListView(), false);
        getListView().addHeaderView(header);

        GameViewHelper.populateWithGame(mGame, new GameViewHelper.Holder(mGameView));

        mAnswersTask = new AnswersTask();
        mAnswersTask.execute(mTicketId);
    }

    @Override
    public void onDestroyView() {
        if (mAnswersTask != null) {
            mAnswersTask.cancel(true);
        }
        super.onDestroyView();
    }

    public class AnswersTask extends NetworkAsyncTask<Long, Void, List<Answer>> {

        @Override
        protected List<Answer> queryData(Long... params) {
            return super.queryData(params);
        }

        @Override
        protected Result<List<Answer>> downloadData(NetworkClient client, Long... params) {
            long ticketId = params[0];
            return client.getAnswers(getSport(), getLevel(), ticketId);
        }

        @Override
        protected void onSuccess(List<Answer> answers) {
            super.onSuccess(answers);
            setListAdapter(new AnswersAdapter(getActivity(), answers));
            AnimUtil.crossfade(mProgressBar, getListView());
        }
    }
}
