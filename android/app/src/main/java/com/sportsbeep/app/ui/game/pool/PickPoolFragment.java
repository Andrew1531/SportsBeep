package com.sportsbeep.app.ui.game.pool;

import com.metova.slim.annotation.Callback;
import com.metova.slim.annotation.Extra;
import com.sportsbeep.app.R;
import com.sportsbeep.app.adapter.PoolAdapter;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.pool.Pool;
import com.sportsbeep.app.model.pool.PoolResponse;
import com.sportsbeep.app.task.network.NetworkAsyncTask;
import com.sportsbeep.app.ui.base.BaseListFragment;
import com.sportsbeep.app.ui.view.FontTextView;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.ProgressBar;

import butterknife.InjectView;
import butterknife.OnClick;
import butterknife.OnItemClick;

public class PickPoolFragment extends BaseListFragment {

    private static final String EXTRA_GAME = "game";

    private static final String TAG_FUNDS = "funds";

    @InjectView(android.R.id.progress)
    ProgressBar mProgressBar;

    @InjectView(R.id.balance_LinearLayout)
    LinearLayout mBalanceLinearLayout;

    @InjectView(R.id.balance_FontTextView)
    FontTextView mBalanceFontTextView;

    @Extra(key = EXTRA_GAME)
    Game mGame;

    @Callback
    PickPoolCallback mCallback;

    private PoolTask mPoolTask;

    public static PickPoolFragment newInstance(Game game) {
        PickPoolFragment fragment = new PickPoolFragment();

        Bundle args = new Bundle();
        args.putParcelable(EXTRA_GAME, game);
        fragment.setArguments(args);

        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_pick_pool, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mPoolTask = new PoolTask();
        mPoolTask.execute();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (mPoolTask != null) {
            mPoolTask.cancel(true);
        }
    }

    @OnClick(R.id.balance_LinearLayout)
    public void onBalanceClicked() {
        FundsDialogFragment fragment = FundsDialogFragment.newInstance();
        fragment.setCancelable(false);
        fragment.show(getFragmentManager(), TAG_FUNDS);
    }

    @OnItemClick(android.R.id.list)
    public void onPoolClicked(int position) {
        Pool pool = (Pool) getListView().getItemAtPosition(position);
        mCallback.onPoolClicked(pool);
    }

    public interface PickPoolCallback {

        public void onPoolClicked(Pool pool);
    }

    public class PoolTask extends NetworkAsyncTask<Void, Void, PoolResponse> {

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            mProgressBar.setVisibility(View.VISIBLE);
        }

        @Override
        protected Result<PoolResponse> doInBackground(Void... params) {
            return getClient().getPools(getSport(), getLevel(), mGame.getId());
        }

        @Override
        protected void onFinished() {
            super.onFinished();
            mProgressBar.setVisibility(View.GONE);
        }

        @Override
        protected void onSuccess(PoolResponse pools) {
            super.onSuccess(pools);
            mBalanceLinearLayout.setVisibility(View.VISIBLE);
            mBalanceFontTextView.setText(pools.getBalance());
            setListAdapter(new PoolAdapter(getActivity(), pools.getPools()));
        }
    }
}
