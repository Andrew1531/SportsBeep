package com.sportsbeep.app.ui.account;


import com.metova.slim.annotation.Callback;
import com.sportsbeep.app.R;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.user.User;
import com.sportsbeep.app.network.params.CreateAccountParams;
import com.sportsbeep.app.task.network.NetworkAsyncTask;
import com.sportsbeep.app.ui.base.BaseFragment;

import android.app.ProgressDialog;
import android.os.AsyncTask;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;

import butterknife.InjectView;
import butterknife.OnClick;

public class CreateAccountFragment extends BaseFragment {

    @InjectView(R.id.username_EditText)
    EditText mUsernameEditText;

    @InjectView(R.id.email_EditText)
    EditText mEmailEditText;

    @InjectView(R.id.password_EditText)
    EditText mPasswordEditText;

    @InjectView(R.id.promoCode_EditText)
    EditText mPromoCodeEditText;

    @Callback
    CreateAccountCallback mCallback;

    private CreateAccountTask mCreateAccountTask;

    public CreateAccountFragment() {

    }

    public static CreateAccountFragment newInstance() {
        return new CreateAccountFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_create_account, container, false);
    }

    @Override
    public void onDetach() {
        super.onDetach();
        if (mCreateAccountTask != null && mCreateAccountTask.getStatus() != AsyncTask.Status.FINISHED) {
            mCreateAccountTask.cancel(true);
        }
    }

    @OnClick(R.id.createAccount_Button)
    public void onCreateAccountClicked() {
        String username = mUsernameEditText.getText().toString();
        String email = mEmailEditText.getText().toString();
        String password = mPasswordEditText.getText().toString();
        String promoCode = mPromoCodeEditText.getText().toString();

        mCreateAccountTask = new CreateAccountTask();
        mCreateAccountTask.execute(new CreateAccountParams(username, email, password, promoCode));
    }

    public interface CreateAccountCallback {

        public void onAccountCreated(User user);
    }

    public class CreateAccountTask extends NetworkAsyncTask<CreateAccountParams, Void, User> {

        private ProgressDialog mDialog;

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            mDialog = ProgressDialog.show(getActivity(), null, getString(R.string.creating_account), true, false);
        }

        @Override
        protected Result<User> doInBackground(CreateAccountParams... params) {
            CreateAccountParams param = params[0];
            return getClient().createAccount(param);
        }

        @Override
        protected void onFinished() {
            super.onFinished();
            mDialog.dismiss();
        }

        @Override
        protected void onSuccess(User user) {
            super.onSuccess(user);
            mCallback.onAccountCreated(user);
        }
    }
}
