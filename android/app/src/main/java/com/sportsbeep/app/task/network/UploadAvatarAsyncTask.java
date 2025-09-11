package com.sportsbeep.app.task.network;

import com.sportsbeep.app.model.Result;
import com.sportsbeep.app.model.user.PhotoResponse;
import com.sportsbeep.app.util.typed.TypedUri;

public class UploadAvatarAsyncTask extends NetworkAsyncTask<TypedUri, Void, PhotoResponse> {

    @Override
    protected Result<PhotoResponse> doInBackground(TypedUri... params) {
        return getClient().updateAvatar(params[0]);
    }
}
