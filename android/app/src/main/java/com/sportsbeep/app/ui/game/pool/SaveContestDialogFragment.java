package com.sportsbeep.app.ui.game.pool;

import com.sportsbeep.app.R;
import com.sportsbeep.app.ui.base.BaseDialogFragment;

import android.app.Dialog;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import butterknife.OnClick;

public class SaveContestDialogFragment extends BaseDialogFragment {

    private SaveContestClickListener mListener;

    public static SaveContestDialogFragment newInstance() {
        return new SaveContestDialogFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_save_contest, container, false);
    }

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Dialog dialog = super.onCreateDialog(savedInstanceState);
        dialog.setCanceledOnTouchOutside(false);
        return dialog;
    }

    @OnClick(R.id.continue_FontTextView)
    public void onContinueClick() {
        mListener.onContinueClicked();
        dismiss();
    }

    @OnClick(R.id.save_FontTextView)
    public void onSaveClick() {
        mListener.onSaveClicked();
        dismiss();
    }

    @OnClick(R.id.cancel_FontTextView)
    public void onCancelClick() {
        mListener.onCancelClicked();
        dismiss();
    }

    public void setSaveContestClickListener(SaveContestClickListener listener) {
        mListener = listener;
    }

    public interface SaveContestClickListener {

        public void onContinueClicked();

        public void onSaveClicked();

        public void onCancelClicked();
    }
}
