package com.sportsbeep.app.ui.game.questions;

import com.metova.slim.annotation.Callback;
import com.sportsbeep.app.R;
import com.sportsbeep.app.ui.base.BaseFragment;
import com.sportsbeep.app.ui.view.FontTextView;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import java.util.Timer;
import java.util.TimerTask;

import butterknife.InjectView;

public class CountDownFragment extends BaseFragment {

    private static final int DURATION_READY = 1500;

    private static final int DURATION_SET = 3000;

    private static final int DURATION_GO = 4500;

    @InjectView(R.id.ready_FontTextView)
    FontTextView mReadyFontTextView;

    @Callback
    CountDownCallback mCallback;

    private Timer mTimer;

    public static CountDownFragment newInstance() {
        return new CountDownFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_countdown, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mTimer = new Timer();
        mTimer.schedule(new ReadyTimerTask(R.drawable.btn_orange, R.string.set, 30),
                DURATION_READY);
        mTimer.schedule(new ReadyTimerTask(R.drawable.btn_red, R.string.go, 56), DURATION_SET);
        mTimer.schedule(new TimerTask() {
            @Override
            public void run() {
                new Handler(Looper.getMainLooper()).post(new Runnable() {
                    @Override
                    public void run() {
                        mCallback.onCountDownFinished();
                    }
                });
            }
        }, DURATION_GO);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        mTimer.cancel();
        mTimer = null;
    }

    public interface CountDownCallback {

        public void onCountDownFinished();
    }

    private class ReadyTimerTask extends TimerTask {

        final int mBackgroundResId;

        final int mTextResId;

        final float mSizeDp;

        public ReadyTimerTask(int backgroundResId, int textResId, float sizeDp) {
            mBackgroundResId = backgroundResId;
            mTextResId = textResId;
            mSizeDp = sizeDp;
        }

        @Override
        public void run() {
            mReadyFontTextView.post(new Runnable() {
                @Override
                public void run() {
                    mReadyFontTextView.setBackgroundResource(mBackgroundResId);
                    mReadyFontTextView.setText(mTextResId);
                    mReadyFontTextView.setTextSize(TypedValue.COMPLEX_UNIT_DIP, mSizeDp);
                }
            });
        }
    }
}
