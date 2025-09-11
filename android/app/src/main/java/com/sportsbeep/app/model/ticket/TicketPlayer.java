package com.sportsbeep.app.model.ticket;

import com.google.gson.annotations.SerializedName;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;
import com.sportsbeep.app.model.team.Team;

import android.os.Parcel;
import android.os.Parcelable;

@DatabaseTable
public class TicketPlayer implements Parcelable {

    public static final Parcelable.Creator<TicketPlayer> CREATOR
            = new Parcelable.Creator<TicketPlayer>() {
        public TicketPlayer createFromParcel(Parcel in) {
            return new TicketPlayer(in);
        }

        public TicketPlayer[] newArray(int size) {
            return new TicketPlayer[size];
        }
    };

    @DatabaseField(generatedId = true, columnName = "_id")
    private transient long id;

    @SerializedName("id")
    @DatabaseField
    private long playerId;

    @DatabaseField
    private String name;

    @DatabaseField
    private String position;

    @DatabaseField
    private String gamePosition;

    @DatabaseField
    private String score;

    @DatabaseField
    private String headshotUrl;

    @DatabaseField(foreign = true)
    private Team team;

    public TicketPlayer(Parcel in) {
        id = in.readLong();
        setPlayerId(in.readLong());
        setName(in.readString());
        setPosition(in.readString());
        setGamePosition(in.readString());
        setScore(in.readString());
        setTeam(in.<Team>readParcelable(Team.class.getClassLoader()));
        setHeadshotUrl(in.readString());
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeLong(id);
        dest.writeLong(getPlayerId());
        dest.writeString(getName());
        dest.writeString(getPosition());
        dest.writeString(getGamePosition());
        dest.writeString(getScore());
        dest.writeParcelable(getTeam(), flags);
        dest.writeString(getHeadshotUrl());
    }

    public String getGamePosition() {
        return gamePosition;
    }

    public void setGamePosition(String gamePosition) {
        this.gamePosition = gamePosition;
    }

    public String getPosition() {
        return position;
    }

    public void setPosition(String position) {
        this.position = position;
    }

    public long getPlayerId() {
        return playerId;
    }

    public void setPlayerId(long playerId) {
        this.playerId = playerId;
    }

    public String getScore() {
        return score;
    }

    public void setScore(String score) {
        this.score = score;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Team getTeam() {
        return team;
    }

    public void setTeam(Team team) {
        this.team = team;
    }

    public String getHeadshotUrl() {
        return headshotUrl;
    }

    public void setHeadshotUrl(String headshotUrl) {
        this.headshotUrl = headshotUrl;
    }
}
