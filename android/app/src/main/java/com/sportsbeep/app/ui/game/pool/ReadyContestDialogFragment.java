package com.sportsbeep.app.ui.game.pool;

import com.sportsbeep.app.R;
import com.sportsbeep.app.ui.base.BaseDialogFragment;

import android.app.Dialog;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import java.io.Serializable;

import butterknife.OnClick;

public class ReadyContestDialogFragment extends BaseDialogFragment {

    private ReadyContestClickListener mListener;

    public static ReadyContestDialogFragment newInstance() {
        return new ReadyContestDialogFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_ready_contest, container, false);
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Dialog dialog = super.onCreateDialog(savedInstanceState);
        dialog.setCanceledOnTouchOutside(false);
        return dialog;
    }

    @OnClick(R.id.yes_FontTextView)
    public void onYesClicked() {
        mListener.onYesClicked();
        dismiss();
    }

    @OnClick(R.id.cancel_FontTextView)
    public void onCancelClicked() {
        mListener.onCancelClicked();
        dismiss();
    }

    public void setReadyContestClickListener(ReadyContestClickListener listener) {
        mListener = listener;
    }

    public interface ReadyContestClickListener extends Serializable {

        public void onYesClicked();

        public void onCancelClicked();
    }
}
