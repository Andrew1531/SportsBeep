package com.sportsbeep.app.ui.account;

import com.metova.slim.annotation.Callback;
import com.sportsbeep.app.R;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.task.network.NetworkAsyncTask;
import com.sportsbeep.app.ui.base.BaseFragment;

import android.app.ProgressDialog;
import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.AutoCompleteTextView;
import android.widget.Button;
import android.widget.Toast;

import java.util.List;

import butterknife.InjectView;
import butterknife.OnClick;

public class FavoriteTeamFragment extends BaseFragment {

    @InjectView(R.id.baseball_AutoCompleteTextView)
    AutoCompleteTextView mBaseballAutoCompleteTextView;

    @InjectView(R.id.enter_Button)
    Button mEnterButton;

    @Callback
    FavoriteTeamCallback mCallback;

    private List<Team> mMlbTeams;

    private TeamsTask mTeamsTask;

    public FavoriteTeamFragment() {

    }

    public static FavoriteTeamFragment newInstance() {
        return new FavoriteTeamFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_favorite_team, container, false);
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mEnterButton.setEnabled(false);

        mBaseballAutoCompleteTextView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                // hide the keyboard when a team is selected
                InputMethodManager in = (InputMethodManager) getActivity().getSystemService(Context.INPUT_METHOD_SERVICE);
                in.hideSoftInputFromWindow(mBaseballAutoCompleteTextView.getWindowToken(), 0);
            }
        });

        mTeamsTask = new TeamsTask();
        mTeamsTask.execute();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        if (mTeamsTask != null) {
            mTeamsTask.cancel(true);
        }
    }

    @OnClick(R.id.enter_Button)
    public void onEnterClicked() {
        long teamId = 0;
        String baseballTeam = mBaseballAutoCompleteTextView.getText().toString();
        for (Team team : mMlbTeams) {
            if (team.toString().equalsIgnoreCase(baseballTeam)) {
                teamId = team.getId();
            }
        }

        if (teamId != 0) {
            SaveFavoriteTeamsTask saveFavoriteTeamsTask = new SaveFavoriteTeamsTask();
            saveFavoriteTeamsTask.execute(teamId);
        } else {
            Toast.makeText(getActivity(), R.string.valid_team, Toast.LENGTH_LONG).show();
        }
    }

    public interface FavoriteTeamCallback {

        public void onFavoriteTeamsSelected();
    }

    public class TeamsTask extends NetworkAsyncTask<Void, Void, List<Team>> {

        @Override
        protected Result<List<Team>> doInBackground(Void... params) {
            return getClient().getTeams(getSport(), getLevel());
        }

        @Override
        protected void onSuccess(List<Team> teamList) {
            super.onSuccess(teamList);
            mEnterButton.setEnabled(true);
            mMlbTeams = teamList;

            ArrayAdapter<Team> adapter = new ArrayAdapter<Team>(getActivity(),
                    R.layout.item_favorite, mMlbTeams);
            mBaseballAutoCompleteTextView.setAdapter(adapter);
        }
    }

    public class SaveFavoriteTeamsTask extends NetworkAsyncTask<Long, Void, Void> {

        ProgressDialog mDialog;

        @Override
        protected void onPreExecute() {
            super.onPreExecute();
            mDialog = ProgressDialog
                    .show(getActivity(), null, getString(R.string.saving_favorites), true, false);
        }

        @Override
        protected Result<Void> doInBackground(Long... params) {
            long mlbTeamId = params[0];
            return getClient().putFavoriteTeams(mlbTeamId);
        }

        @Override
        protected void onError(String errorMessage) {
            super.onError(errorMessage);
            mDialog.dismiss();
        }

        @Override
        protected void onSuccess(Void aVoid) {
            super.onSuccess(aVoid);
            if (getActivity() != null) {
                mDialog.dismiss();
                mCallback.onFavoriteTeamsSelected();
            }
        }
    }
}
