package com.sportsbeep.app.model.game;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;
import com.sportsbeep.app.model.team.Team;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.Date;

@DatabaseTable
public class Game implements Parcelable {

    public static final Parcelable.Creator<Game> CREATOR = new Parcelable.Creator<Game>() {
        public Game createFromParcel(Parcel in) {
            return new Game(in);
        }

        public Game[] newArray(int size) {
            return new Game[size];
        }
    };

    @DatabaseField(id = true, columnName = "_id")
    private long id;

    @DatabaseField
    private Date startTime;

    @DatabaseField(foreign = true, foreignAutoRefresh = true)
    private Team homeTeam;

    @DatabaseField(foreign = true, foreignAutoRefresh = true)
    private Team awayTeam;

    public Game() {

    }

    private Game(Parcel in) {
        setId(in.readLong());
        setStartTime(new Date(in.readLong()));
        setHomeTeam(in.<Team>readParcelable(Team.class.getClassLoader()));
        setAwayTeam(in.<Team>readParcelable(Team.class.getClassLoader()));
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeLong(getId());
        dest.writeLong(startTime != null ? startTime.getTime() : 0L);
        dest.writeParcelable(getHomeTeam(), flags);
        dest.writeParcelable(getAwayTeam(), flags);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        Game game = (Game) o;

        if (id != game.id) {
            return false;
        }
        if (awayTeam != null ? !awayTeam.equals(game.awayTeam) : game.awayTeam != null) {
            return false;
        }
        if (homeTeam != null ? !homeTeam.equals(game.homeTeam) : game.homeTeam != null) {
            return false;
        }
        if (startTime != null ? !startTime.equals(game.startTime) : game.startTime != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        int result = (int) (id ^ (id >>> 32));
        result = 31 * result + (startTime != null ? startTime.hashCode() : 0);
        result = 31 * result + (homeTeam != null ? homeTeam.hashCode() : 0);
        result = 31 * result + (awayTeam != null ? awayTeam.hashCode() : 0);
        return result;
    }

    public Team getHomeTeam() {
        return homeTeam;
    }

    public void setHomeTeam(Team homeTeam) {
        this.homeTeam = homeTeam;
    }

    public Team getAwayTeam() {
        return awayTeam;
    }

    public void setAwayTeam(Team awayTeam) {
        this.awayTeam = awayTeam;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public Date getStartTime() {
        return startTime;
    }

    public void setStartTime(Date startTime) {
        this.startTime = startTime;
    }
}
