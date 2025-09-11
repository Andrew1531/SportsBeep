package com.sportsbeep.app.model.player.stats;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.field.ForeignCollectionField;
import com.j256.ormlite.table.DatabaseTable;
import com.sportsbeep.app.model.player.Player;

import java.util.List;

@DatabaseTable
public class PlayerStats {

    @DatabaseField(generatedId = true)
    private long id;

    @DatabaseField(foreign = true)
    private Player player;

    @ForeignCollectionField
    private List<Stats.SeasonStat> seasonStats;

    @ForeignCollectionField
    private List<Stats.RecentStat> recentStats;

    public List<Stats.RecentStat> getRecentStats() {
        return recentStats;
    }

    public void setRecentStats(List<Stats.RecentStat> recentStats) {
        this.recentStats = recentStats;
    }

    public List<Stats.SeasonStat> getSeasonStats() {
        return seasonStats;
    }

    public void setSeasonStats(List<Stats.SeasonStat> seasonStats) {
        this.seasonStats = seasonStats;
    }

    public Player getPlayer() {
        return player;
    }

    public void setPlayer(Player player) {
        this.player = player;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }
}
