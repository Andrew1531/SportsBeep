package com.sportsbeep.app.model.ticket;

import com.google.gson.annotations.SerializedName;

import android.os.Parcel;
import android.os.Parcelable;

public class TicketSquad implements Parcelable {

    public static final Parcelable.Creator<TicketSquad> CREATOR
            = new Parcelable.Creator<TicketSquad>() {
        public TicketSquad createFromParcel(Parcel in) {
            return new TicketSquad(in);
        }

        public TicketSquad[] newArray(int size) {
            return new TicketSquad[size];
        }
    };

    @SerializedName("id")
    private long teamId;

    private String gamePosition;

    private String score;

    public TicketSquad(Parcel in) {
        setTeamId(in.readLong());
        setGamePosition(in.readString());
        setScore(in.readString());
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeLong(getTeamId());
        dest.writeString(getGamePosition());
        dest.writeString(getScore());
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        TicketSquad that = (TicketSquad) o;

        if (teamId != that.teamId) {
            return false;
        }
        if (gamePosition != null ? !gamePosition.equals(that.gamePosition) : that.gamePosition != null) {
            return false;
        }
        if (score != null ? !score.equals(that.score) : that.score != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        int result = (int) (teamId ^ (teamId >>> 32));
        result = 31 * result + (gamePosition != null ? gamePosition.hashCode() : 0);
        result = 31 * result + (score != null ? score.hashCode() : 0);
        return result;
    }

    public String getGamePosition() {
        return gamePosition;
    }

    public void setGamePosition(String gamePosition) {
        this.gamePosition = gamePosition;
    }

    public long getTeamId() {
        return teamId;
    }

    public void setTeamId(long teamId) {
        this.teamId = teamId;
    }

    public String getScore() {
        return score;
    }

    public void setScore(String score) {
        this.score = score;
    }
}
