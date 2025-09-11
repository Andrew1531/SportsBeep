package com.sportsbeep.app.ui.login;

import com.metova.slim.annotation.Callback;
import com.sportsbeep.app.R;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.user.User;
import com.sportsbeep.app.network.params.SignInParams;
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

public class LoginFragment extends BaseFragment {

    @InjectView(R.id.email_EditText)
    EditText mEmailEditText;

    @InjectView(R.id.password_EditText)
    EditText mPasswordEditText;

    @Callback
    LoginCallback mCallback;

    private SignInTask mSignInTask;

    public LoginFragment() {

    }

    public static LoginFragment newInstance() {
        return new LoginFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_login, container, false);
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mCallback = null;

        if (mSignInTask != null && mSignInTask.getStatus() != AsyncTask.Status.FINISHED) {
            mSignInTask.cancel(true);
        }
    }

    @OnClick(R.id.signIn_Button)
    public void onSignInClicked() {
        String email = mEmailEditText.getText().toString();
        String password = mPasswordEditText.getText().toString();

        mSignInTask = new SignInTask();
        mSignInTask.execute(new SignInParams(email, password));
    }

    @OnClick(R.id.createAccount_Button)
    public void onCreateAccountClicked() {
        mCallback.onCreateAccountClicked();
    }

    public interface LoginCallback {

        public void onCreateAccountClicked();

        public void onSignedIn(User user);
    }

    public class SignInTask extends NetworkAsyncTask<SignInParams, Void, User> {

        private ProgressDialog mDialog;

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            mDialog = ProgressDialog
                    .show(getActivity(), null, getString(R.string.signing_in), true, false);
        }

        @Override
        protected Result<User> doInBackground(SignInParams... params) {
            SignInParams param = params[0];
            return getClient().signIn(param);
        }

        @Override
        protected void onError(String errorMessage) {
            super.onError(errorMessage);
            mDialog.dismiss();
        }

        @Override
        protected void onSuccess(User user) {
            super.onSuccess(user);
            mDialog.dismiss();
            mCallback.onSignedIn(user);
        }
    }
}
