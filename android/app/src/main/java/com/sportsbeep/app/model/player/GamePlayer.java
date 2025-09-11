package com.sportsbeep.app.model.player;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.player.Player;

@DatabaseTable
public class GamePlayer {

    @DatabaseField(generatedId = true)
    private transient long id;

    @DatabaseField(foreign = true, uniqueCombo = true)
    private Game game;

    @DatabaseField(foreign = true, uniqueCombo = true)
    private Player player;

    @DatabaseField
    private String playerName;

    public GamePlayer() {

    }

    public GamePlayer(Game game, Player player) {
        setGame(game);
        setPlayer(player);
        setPlayerName(player.getName());
    }

    public String getPlayerName() {
        return playerName;
    }

    void setPlayerName(String playerName) {
        this.playerName = playerName;
    }

    public Player getPlayer() {
        return player;
    }

    void setPlayer(Player player) {
        this.player = player;
    }

    public Game getGame() {
        return game;
    }

    void setGame(Game game) {
        this.game = game;
    }
}
