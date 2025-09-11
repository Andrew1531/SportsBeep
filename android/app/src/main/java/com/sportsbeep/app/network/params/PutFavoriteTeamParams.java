package com.sportsbeep.app.network.params;

public class PutFavoriteTeamParams implements NetworkParam {

    private static final String ROOT_NAME = "favorite_team";

    private long baseball;

    public PutFavoriteTeamParams(long baseball) {
        this.baseball = baseball;
    }

    @Override
    public String getRootName() {
        return ROOT_NAME;
    }

    public long getBaseball() {
        return baseball;
    }

    public void setBaseball(long baseball) {
        this.baseball = baseball;
    }
}
