package com.sportsbeep.app.model.ticket;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.field.ForeignCollectionField;
import com.j256.ormlite.table.DatabaseTable;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.ArrayList;
import java.util.List;

@DatabaseTable
public class Scoresheet implements Parcelable {

    public static final Parcelable.Creator<Scoresheet> CREATOR
            = new Parcelable.Creator<Scoresheet>() {
        public Scoresheet createFromParcel(Parcel in) {
            return new Scoresheet(in);
        }

        public Scoresheet[] newArray(int size) {
            return new Scoresheet[size];
        }
    };

    @DatabaseField(generatedId = true, columnName = "_id")
    private long id;

    @DatabaseField
    private String score;

    @ForeignCollectionField
    List<TicketStat> stats;

    public Scoresheet() {

    }

    private Scoresheet(Parcel in) {
        setId(in.readLong());
        setScore(in.readString());

        setStats(new ArrayList<TicketStat>());
        in.readTypedList(getStats(), TicketStat.CREATOR);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeLong(getId());
        dest.writeString(getScore());
        dest.writeTypedList(getStats());
    }

    public String getScore() {
        return score;
    }

    public void setScore(String score) {
        this.score = score;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public List<TicketStat> getStats() {
        return stats;
    }

    public void setStats(List<TicketStat> stats) {
        this.stats = stats;
    }

    @DatabaseTable
    public static class TicketStat implements Parcelable {

        public static final Parcelable.Creator<TicketStat> CREATOR
                = new Parcelable.Creator<TicketStat>() {
            public TicketStat createFromParcel(Parcel in) {
                return new TicketStat(in);
            }

            public TicketStat[] newArray(int size) {
                return new TicketStat[size];
            }
        };

        @DatabaseField(generatedId = true, columnName = "_id")
        private transient long id;

        @DatabaseField
        private String name;

        @DatabaseField
        private String abbr;

        @DatabaseField
        private String amount;

        @DatabaseField
        private String points;

        @DatabaseField
        private String pointsPer;

        public TicketStat(Parcel in) {
            id = in.readLong();
            setName(in.readString());
            setAmount(in.readString());
            setPoints(in.readString());
            setPointsPer(in.readString());
        }

        @Override
        public int describeContents() {
            return 0;
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            dest.writeLong(id);
            dest.writeString(getName());
            dest.writeString(getAmount());
            dest.writeString(getPoints());
            dest.writeString(getPointsPer());
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) {
                return true;
            }
            if (o == null || getClass() != o.getClass()) {
                return false;
            }

            TicketStat that = (TicketStat) o;

            if (id != that.id) {
                return false;
            }
            if (abbr != null ? !abbr.equals(that.abbr) : that.abbr != null) {
                return false;
            }
            if (amount != null ? !amount.equals(that.amount) : that.amount != null) {
                return false;
            }
            if (name != null ? !name.equals(that.name) : that.name != null) {
                return false;
            }
            if (points != null ? !points.equals(that.points) : that.points != null) {
                return false;
            }
            if (pointsPer != null ? !pointsPer.equals(that.pointsPer) : that.pointsPer != null) {
                return false;
            }

            return true;
        }

        @Override
        public int hashCode() {
            int result = (int) (id ^ (id >>> 32));
            result = 31 * result + (name != null ? name.hashCode() : 0);
            result = 31 * result + (abbr != null ? abbr.hashCode() : 0);
            result = 31 * result + (amount != null ? amount.hashCode() : 0);
            result = 31 * result + (points != null ? points.hashCode() : 0);
            result = 31 * result + (pointsPer != null ? pointsPer.hashCode() : 0);
            return result;
        }

        public String getPointsPer() {
            return pointsPer;
        }

        public void setPointsPer(String pointsPer) {
            this.pointsPer = pointsPer;
        }

        public String getPoints() {
            return points;
        }

        public void setPoints(String points) {
            this.points = points;
        }

        public String getAmount() {
            return amount;
        }

        public void setAmount(String amount) {
            this.amount = amount;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getAbbr() {
            return abbr;
        }

        public void setAbbr(String abbr) {
            this.abbr = abbr;
        }
    }
}
