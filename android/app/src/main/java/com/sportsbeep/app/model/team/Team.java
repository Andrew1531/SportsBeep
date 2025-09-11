package com.sportsbeep.app.model.team;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

import android.graphics.Color;
import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;
import android.util.Log;

import java.io.Serializable;

@DatabaseTable
public class Team implements Parcelable, Serializable {

    public static final Parcelable.Creator<Team> CREATOR
            = new Parcelable.Creator<Team>() {
        public Team createFromParcel(Parcel in) {
            return new Team(in);
        }

        public Team[] newArray(int size) {
            return new Team[size];
        }
    };

    @DatabaseField(id = true, columnName = "_id")
    private long id;

    @DatabaseField
    private String market;

    @DatabaseField
    private String name;

    @DatabaseField
    private String abbr;

    @DatabaseField
    private String wins;

    @DatabaseField
    private String losses;

    @DatabaseField
    private String averageHrPerGame;

    @DatabaseField
    private String primaryColor;

    @DatabaseField
    private String secondaryColor;

    public Team() {

    }

    private Team(Parcel in) {
        setId(in.readLong());
        setMarket(in.readString());
        setName(in.readString());
        setAbbr(in.readString());
        setWins(in.readString());
        setLosses(in.readString());
        setAverageHrPerGame(in.readString());
        setPrimaryColor(in.readInt());
        setSecondaryColor(in.readInt());
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeLong(getId());
        dest.writeString(getMarket());
        dest.writeString(getName());
        dest.writeString(getAbbr());
        dest.writeString(getWins());
        dest.writeString(getLosses());
        dest.writeString(getAverageHrPerGame());
        dest.writeInt(getPrimaryColor());
        dest.writeInt(getSecondaryColor());
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        Team team = (Team) o;

        if (id != team.id) {
            return false;
        }
        if (abbr != null ? !abbr.equals(team.abbr) : team.abbr != null) {
            return false;
        }
        if (averageHrPerGame != null ? !averageHrPerGame.equals(team.averageHrPerGame) : team.averageHrPerGame != null) {
            return false;
        }
        if (losses != null ? !losses.equals(team.losses) : team.losses != null) {
            return false;
        }
        if (market != null ? !market.equals(team.market) : team.market != null) {
            return false;
        }
        if (name != null ? !name.equals(team.name) : team.name != null) {
            return false;
        }
        if (primaryColor != null ? !primaryColor.equals(team.primaryColor) : team.primaryColor != null) {
            return false;
        }
        if (secondaryColor != null ? !secondaryColor.equals(team.secondaryColor) : team.secondaryColor != null) {
            return false;
        }
        if (wins != null ? !wins.equals(team.wins) : team.wins != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        int result = (int) (id ^ (id >>> 32));
        result = 31 * result + (market != null ? market.hashCode() : 0);
        result = 31 * result + (name != null ? name.hashCode() : 0);
        result = 31 * result + (abbr != null ? abbr.hashCode() : 0);
        result = 31 * result + (wins != null ? wins.hashCode() : 0);
        result = 31 * result + (losses != null ? losses.hashCode() : 0);
        result = 31 * result + (averageHrPerGame != null ? averageHrPerGame.hashCode() : 0);
        result = 31 * result + (primaryColor != null ? primaryColor.hashCode() : 0);
        result = 31 * result + (secondaryColor != null ? secondaryColor.hashCode() : 0);
        return result;
    }

    @Override
    public String toString() {
        return getMarket() + " " + getName();
    }

    public String getWins() {
        return wins;
    }

    public void setWins(String wins) {
        this.wins = wins;
    }

    public String getLosses() {
        return losses;
    }

    public void setLosses(String losses) {
        this.losses = losses;
    }

    public String getAbbr() {
        return abbr;
    }

    public void setAbbr(String abbr) {
        this.abbr = abbr;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getMarket() {
        return market;
    }

    public void setMarket(String market) {
        this.market = market;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAverageHrPerGame() {
        return averageHrPerGame;
    }

    public void setAverageHrPerGame(String averageHrPerGame) {
        this.averageHrPerGame = averageHrPerGame;
    }

    public int getSecondaryColor() {
        if (!TextUtils.isEmpty(secondaryColor) && !secondaryColor.startsWith("#")) {
            secondaryColor = "#" + secondaryColor;
        }

        try {
            return Color.parseColor(secondaryColor);
        } catch (Exception e) {
            Log.e(Team.class.getSimpleName(), "Unknown color: " + secondaryColor);
            return Color.WHITE;
        }
    }

    public void setSecondaryColor(int secondaryColor) {
        this.secondaryColor = "#" + Integer.toHexString(secondaryColor);
    }

    public int getPrimaryColor() {
        if (!TextUtils.isEmpty(primaryColor) && !primaryColor.startsWith("#")) {
            primaryColor = "#" + primaryColor;
        }

        try {
            return Color.parseColor(primaryColor);
        } catch (Exception e) {
            Log.e(Team.class.getSimpleName(), "Unknown color: " + primaryColor);
            return Color.BLACK;
        }
    }

    public void setPrimaryColor(int primaryColor) {
        this.primaryColor = "#" + Integer.toHexString(primaryColor);
    }
}
