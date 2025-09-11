package com.sportsbeep.app.model.team;

import com.sportsbeep.app.model.game.Game;

import android.os.Parcel;
import android.os.Parcelable;

public class LeaguePick implements Parcelable {

    public static final Parcelable.Creator<LeaguePick> CREATOR
            = new Parcelable.Creator<LeaguePick>() {
        public LeaguePick createFromParcel(Parcel in) {
            return new LeaguePick(in);
        }

        public LeaguePick[] newArray(int size) {
            return new LeaguePick[size];
        }
    };

    private String score;

    private Game game;

    private Team team;

    public LeaguePick() {

    }

    private LeaguePick(Parcel in) {
        setGame(in.<Game>readParcelable(Game.class.getClassLoader()));
        setTeam(in.<Team>readParcelable(Team.class.getClassLoader()));
        setScore(in.readString());
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeParcelable(getGame(), flags);
        dest.writeParcelable(getTeam(), flags);
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

        LeaguePick that = (LeaguePick) o;

        if (game != null ? !game.equals(that.game) : that.game != null) {
            return false;
        }
        if (score != null ? !score.equals(that.score) : that.score != null) {
            return false;
        }
        if (team != null ? !team.equals(that.team) : that.team != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        int result = score != null ? score.hashCode() : 0;
        result = 31 * result + (game != null ? game.hashCode() : 0);
        result = 31 * result + (team != null ? team.hashCode() : 0);
        return result;
    }

    public Game getGame() {

        return game;
    }

    public void setGame(Game game) {
        this.game = game;
    }

    public Team getTeam() {
        return team;
    }

    public void setTeam(Team team) {
        this.team = team;
    }

    public String getScore() {
        return score;
    }

    public void setScore(String score) {
        this.score = score;
    }
}
