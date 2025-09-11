package com.sportsbeep.app.network.params;

public class RemoveAvatarParams implements NetworkParam {

    private static final String ROOT = "api_user";

    private boolean removeAvatar = true;

    @Override
    public String getRootName() {
        return ROOT;
    }
}
