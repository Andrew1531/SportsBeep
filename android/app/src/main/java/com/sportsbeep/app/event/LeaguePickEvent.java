package com.sportsbeep.app.event;

import com.sportsbeep.app.model.game.Game;

import java.util.List;

public class LeaguePickEvent {

    private final List<Game> mGames;

    public LeaguePickEvent(List<Game> games) {
        mGames = games;
    }

    public List<Game> getGames() {

        return mGames;
    }
}
