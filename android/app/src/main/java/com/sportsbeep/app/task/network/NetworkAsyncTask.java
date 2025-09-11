package com.sportsbeep.app.task.network;

import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.module.GraphHolder;
import com.sportsbeep.app.network.NetworkClient;

import android.content.Context;
import android.os.AsyncTask;
import android.text.TextUtils;
import android.widget.Toast;

import javax.inject.Inject;

public abstract class NetworkAsyncTask<Params, Progress, Data> extends AsyncTask<Params, Progress, Result<Data>> {

    @Inject
    NetworkClient mClient;

    @Inject
    Context mContext;

    Sport mSport;

    Level mLevel;

    public NetworkAsyncTask() {
        GraphHolder.getInstance().inject(this);
    }

    public NetworkAsyncTask(Sport sport, Level level) {
        this();
        mSport = sport;
        mLevel = level;
    }

    @Override
    protected Result<Data> doInBackground(Params... params) {
        Data data = queryData(params);
        if (data != null) {
            return new Result<Data>(data);
        }

        return downloadData(mClient, params);
    }

    protected Data queryData(Params... params) {
        return null;
    }

    protected Result<Data> downloadData(NetworkClient client, Params... params) {
        return null;
    }

    @Override
    protected final void onPostExecute(Result<Data> dataResult) {
        super.onPostExecute(dataResult);
        onFinished();

        if (!TextUtils.isEmpty(dataResult.getError())) {
            onError(dataResult.getError());
        } else {
            onSuccess(dataResult.getData());
        }
    }

    /**
     * Called every time a task finishes, regardless of success or failure. This is
     * called before <code>onSuccess()</code> or <code>onError()</code>.
     */
    protected void onFinished() {

    }

    /**
     * Called when data has been successfully retrieved from the server. This is not a guarantee
     * that the data is non-null.
     * Persistence in a database has already been taken care of.
     *
     * @param data The data retrieved from the server.
     */
    protected void onSuccess(Data data) {

    }

    /**
     * Called when there was an error retrieving data from the server. The super implementation
     * displays a toast with the error message.
     *
     * @param errorMessage Describes the error in human-readable form.
     */
    protected void onError(String errorMessage) {
        Toast.makeText(mContext, errorMessage, Toast.LENGTH_LONG).show();
    }

    public NetworkClient getClient() {
        return mClient;
    }

    public Sport getSportTemp() {
        return mSport;
    }

    public Level getLevelTemp() {
        return mLevel;
    }
}
