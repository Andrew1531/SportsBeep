package com.sportsbeep.app.model.contest;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.ticket.Ticket;

import android.os.Parcel;
import android.os.Parcelable;

@DatabaseTable
public class Contest implements Parcelable {

    public static final Parcelable.Creator<Contest> CREATOR
            = new Parcelable.Creator<Contest>() {
        public Contest createFromParcel(Parcel in) {
            return new Contest(in);
        }

        public Contest[] newArray(int size) {
            return new Contest[size];
        }
    };

    @DatabaseField(id = true, columnName = "_id")
    private long id;

    @DatabaseField(foreign = true)
    private Ticket ticket;

    @DatabaseField(foreign = true)
    private Game game;

    public Contest() {

    }

    private Contest(Parcel in) {
        setId(in.readLong());
        setTicket(in.<Ticket>readParcelable(Ticket.class.getClassLoader()));
        setGame(in.<Game>readParcelable(Game.class.getClassLoader()));
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeLong(getId());
        dest.writeParcelable(getTicket(), flags);
        dest.writeParcelable(getGame(), flags);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        Contest contest = (Contest) o;

        if (id != contest.id) {
            return false;
        }
        if (game != null ? !game.equals(contest.game) : contest.game != null) {
            return false;
        }
        if (ticket != null ? !ticket.equals(contest.ticket) : contest.ticket != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        int result = (int) (id ^ (id >>> 32));
        result = 31 * result + (ticket != null ? ticket.hashCode() : 0);
        result = 31 * result + (game != null ? game.hashCode() : 0);
        return result;
    }

    public Game getGame() {
        return game;
    }

    public void setGame(Game game) {
        this.game = game;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public Ticket getTicket() {
        return ticket;
    }

    public void setTicket(Ticket ticket) {
        this.ticket = ticket;
    }
}
