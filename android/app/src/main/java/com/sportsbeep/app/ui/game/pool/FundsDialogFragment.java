package com.sportsbeep.app.ui.game.pool;

import com.sportsbeep.app.R;
import com.sportsbeep.app.ui.base.BaseDialogFragment;

import android.app.Dialog;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import butterknife.OnClick;

public class FundsDialogFragment extends BaseDialogFragment {

    public static FundsDialogFragment newInstance() {
        return new FundsDialogFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_funds, container, false);
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Dialog dialog = super.onCreateDialog(savedInstanceState);
        dialog.setCanceledOnTouchOutside(false);
        return dialog;
    }

    @OnClick(R.id.ok_FontTextView)
    public void onOkClicked() {
        dismiss();
    }
}
