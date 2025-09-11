package com.sportsbeep.app.task.network;

import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.user.PhotoResponse;

public class RemoveAvatarAsyncTask extends NetworkAsyncTask<Void, Void, PhotoResponse> {

    @Override
    protected Result<PhotoResponse> doInBackground(Void... params) {
        return getClient().removeAvatar();
    }
}
