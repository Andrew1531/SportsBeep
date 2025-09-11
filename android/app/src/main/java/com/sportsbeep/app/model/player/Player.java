package com.sportsbeep.app.model.player;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;
import com.sportsbeep.app.enumeration.Position;
import com.sportsbeep.app.model.player.stats.Stats;
import com.sportsbeep.app.model.team.Team;

import android.os.Parcel;
import android.os.Parcelable;

import java.io.Serializable;
import java.util.List;

@DatabaseTable
public class Player implements Parcelable, Serializable {

    public static final Parcelable.Creator<Player> CREATOR = new Parcelable.Creator<Player>() {
        public Player createFromParcel(Parcel in) {
            return new Player(in);
        }

        public Player[] newArray(int size) {
            return new Player[size];
        }
    };

    @DatabaseField(id = true, columnName = "_id")
    private long id;

    @DatabaseField
    private String name;

    @DatabaseField
    private int number;

    @DatabaseField
    private String headshotUrl;

    @DatabaseField
    private Position position;

    @DatabaseField(foreign = true, foreignAutoRefresh = true)
    private Team team;

    private List<Stats.RecentStat> stats;

    public Player() {

    }

    private Player(Parcel in) {
        setId(in.readLong());
        setNumber(in.readInt());
        setName(in.readString());
        setHeadshotUrl(in.readString());
        setPosition(Position.values()[in.readInt()]);
        setTeam(in.<Team>readParcelable(Team.class.getClassLoader()));
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeLong(getId());
        dest.writeInt(getNumber());
        dest.writeString(getName());
        dest.writeString(getHeadshotUrl());
        dest.writeInt(getPosition().ordinal());
        dest.writeParcelable(getTeam(), flags);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        Player player = (Player) o;

        if (id != player.id) {
            return false;
        }
        if (number != player.number) {
            return false;
        }
        if (headshotUrl != null ? !headshotUrl.equals(player.headshotUrl) : player.headshotUrl != null) {
            return false;
        }
        if (name != null ? !name.equals(player.name) : player.name != null) {
            return false;
        }
        if (position != player.position) {
            return false;
        }
        if (stats != null ? !stats.equals(player.stats) : player.stats != null) {
            return false;
        }
        if (team != null ? !team.equals(player.team) : player.team != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        int result = (int) (id ^ (id >>> 32));
        result = 31 * result + (name != null ? name.hashCode() : 0);
        result = 31 * result + number;
        result = 31 * result + (headshotUrl != null ? headshotUrl.hashCode() : 0);
        result = 31 * result + (position != null ? position.hashCode() : 0);
        result = 31 * result + (team != null ? team.hashCode() : 0);
        result = 31 * result + (stats != null ? stats.hashCode() : 0);
        return result;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public Team getTeam() {
        return team;
    }

    public void setTeam(Team team) {
        this.team = team;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getNumber() {
        return number;
    }

    public void setNumber(int number) {
        this.number = number;
    }

    public Position getPosition() {
        return position;
    }

    public void setPosition(Position position) {
        this.position = position;
    }

    public List<Stats.RecentStat> getStats() {
        return stats;
    }

    public void setStats(List<Stats.RecentStat> stats) {
        this.stats = stats;
    }

    public String getHeadshotUrl() {
        return headshotUrl;
    }

    public void setHeadshotUrl(String headshotUrl) {
        this.headshotUrl = headshotUrl;
    }
}
