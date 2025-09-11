package com.sportsbeep.app.model.ticket;

import com.sportsbeep.app.model.user.User;
import com.sportsbeep.app.model.contest.Contest;
import com.sportsbeep.app.model.team.LeaguePick;

import android.os.Parcel;
import android.os.Parcelable;

public class Ticket implements Parcelable {

    public static final Parcelable.Creator<Ticket> CREATOR
            = new Parcelable.Creator<Ticket>() {
        public Ticket createFromParcel(Parcel in) {
            return new Ticket(in);
        }

        public Ticket[] newArray(int size) {
            return new Ticket[size];
        }
    };

    private long id;

    private String score;

    private double prizePool;

    private int placing;

    private User user;

    private Contest contest;

    private LeaguePick leaguePick;

    private String bestOrBustScore;

    public Ticket() {

    }

    private Ticket(Parcel in) {
        setId(in.readLong());
        setScore(in.readString());
        setPrizePool(in.readDouble());
        setPlacing(in.readInt());
        setUser(in.<User>readParcelable(User.class.getClassLoader()));
        setContest(in.<Contest>readParcelable(Contest.class.getClassLoader()));
        setLeaguePick(in.<LeaguePick>readParcelable(LeaguePick.class.getClassLoader()));
        setBestOrBustScore(in.readString());
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeLong(getId());
        dest.writeString(getScore());
        dest.writeDouble(getPrizePool());
        dest.writeInt(getPlacing());
        dest.writeParcelable(getUser(), flags);
        dest.writeParcelable(getContest(), flags);
        dest.writeParcelable(getLeaguePick(), flags);
        dest.writeString(getBestOrBustScore());
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        Ticket ticket = (Ticket) o;

        if (id != ticket.id) {
            return false;
        }
        if (placing != ticket.placing) {
            return false;
        }
        if (Double.compare(ticket.prizePool, prizePool) != 0) {
            return false;
        }
        if (bestOrBustScore != null ? !bestOrBustScore.equals(ticket.bestOrBustScore) : ticket.bestOrBustScore != null) {
            return false;
        }
        if (contest != null ? !contest.equals(ticket.contest) : ticket.contest != null) {
            return false;
        }
        if (leaguePick != null ? !leaguePick.equals(ticket.leaguePick) : ticket.leaguePick != null) {
            return false;
        }
        if (score != null ? !score.equals(ticket.score) : ticket.score != null) {
            return false;
        }
        if (user != null ? !user.equals(ticket.user) : ticket.user != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        int result;
        long temp;
        result = (int) (id ^ (id >>> 32));
        result = 31 * result + (score != null ? score.hashCode() : 0);
        temp = Double.doubleToLongBits(prizePool);
        result = 31 * result + (int) (temp ^ (temp >>> 32));
        result = 31 * result + placing;
        result = 31 * result + (user != null ? user.hashCode() : 0);
        result = 31 * result + (contest != null ? contest.hashCode() : 0);
        result = 31 * result + (leaguePick != null ? leaguePick.hashCode() : 0);
        result = 31 * result + (bestOrBustScore != null ? bestOrBustScore.hashCode() : 0);
        return result;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public double getPrizePool() {
        return prizePool;
    }

    public void setPrizePool(double prizePool) {
        this.prizePool = prizePool;
    }

    public int getPlacing() {
        return placing;
    }

    public void setPlacing(int placing) {
        this.placing = placing;
    }

    public String getBestOrBustScore() {
        return bestOrBustScore;
    }

    public void setBestOrBustScore(String bestOrBustScore) {
        this.bestOrBustScore = bestOrBustScore;
    }

    public Contest getContest() {
        return contest;
    }

    public void setContest(Contest contest) {
        this.contest = contest;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getScore() {
        return score;
    }

    public void setScore(String score) {
        this.score = score;
    }

    public LeaguePick getLeaguePick() {
        return leaguePick;
    }

    public void setLeaguePick(LeaguePick leaguePick) {
        this.leaguePick = leaguePick;
    }
}
