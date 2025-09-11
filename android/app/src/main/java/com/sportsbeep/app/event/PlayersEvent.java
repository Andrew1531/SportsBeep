package com.sportsbeep.app.event;

import com.sportsbeep.app.model.player.Player;

import java.util.List;

public class PlayersEvent {

    private final List<Player> mPlayers;

    public PlayersEvent(List<Player> players) {
        mPlayers = players;
    }

    public List<Player> getPlayers() {

        return mPlayers;
    }
}
