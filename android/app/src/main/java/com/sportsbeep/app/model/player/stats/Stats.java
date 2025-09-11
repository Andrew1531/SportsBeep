package com.sportsbeep.app.model.player.stats;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;
import com.sportsbeep.app.model.player.Player;

import android.os.Parcel;
import android.os.Parcelable;

import java.io.Serializable;
import java.util.List;

public class Stats {

    private List<SeasonStat> seasonStats;

    private List<RecentStat> recentStats;

    public List<SeasonStat> getSeasonStats() {
        return seasonStats;
    }

    public void setSeasonStats(List<SeasonStat> seasonStats) {
        this.seasonStats = seasonStats;
    }

    public List<RecentStat> getRecentStats() {
        return recentStats;
    }

    public void setRecentStats(List<RecentStat> recentStats) {
        this.recentStats = recentStats;
    }

    public static class Stat implements Parcelable, Serializable {

        public static final Parcelable.Creator<Stat> CREATOR
                = new Parcelable.Creator<Stat>() {
            public Stat createFromParcel(Parcel in) {
                return new Stat(in);
            }

            public Stat[] newArray(int size) {
                return new Stat[size];
            }
        };

        @DatabaseField(generatedId = true)
        private transient long id;

        @DatabaseField(uniqueCombo = true)
        private String name;

        @DatabaseField
        private String abbr;

        @DatabaseField
        private String amount;

        @DatabaseField
        private boolean shownOnSummary;

        @DatabaseField(foreign = true, uniqueCombo = true)
        private Player player;

        public Stat() {

        }

        private Stat(Parcel in) {
            id = in.readLong();
            setName(in.readString());
            setAbbr(in.readString());
            setAmount(in.readString());
            setShownOnSummary(in.readInt() == 1);
            setPlayer(in.<Player>readParcelable(Player.class.getClassLoader()));
        }

        @Override
        public int describeContents() {
            return 0;
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            dest.writeLong(getId());
            dest.writeString(getName());
            dest.writeString(getAbbr());
            dest.writeString(getAmount());
            dest.writeInt(isShownOnSummary() ? 1 : 0);
            dest.writeParcelable(getPlayer(), flags);
        }

        @Override
        public boolean equals(Object o) {
            if (this == o) {
                return true;
            }
            if (o == null || getClass() != o.getClass()) {
                return false;
            }

            Stat stat = (Stat) o;

            if (id != stat.id) {
                return false;
            }
            if (abbr != null ? !abbr.equals(stat.abbr) : stat.abbr != null) {
                return false;
            }
            if (amount != null ? !amount.equals(stat.amount) : stat.amount != null) {
                return false;
            }
            if (name != null ? !name.equals(stat.name) : stat.name != null) {
                return false;
            }
            if (player != null ? !player.equals(stat.player) : stat.player != null) {
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
            result = 31 * result + (player != null ? player.hashCode() : 0);
            return result;
        }

        public long getId() {
            return id;
        }

        public void setId(long id) {
            this.id = id;
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

        public String getAmount() {
            return amount;
        }

        public void setAmount(String amount) {
            this.amount = amount;
        }

        public Player getPlayer() {
            return player;
        }

        public void setPlayer(Player player) {
            this.player = player;
        }

        public boolean isShownOnSummary() {
            return shownOnSummary;
        }

        public void setShownOnSummary(boolean shownOnSummary) {
            this.shownOnSummary = shownOnSummary;
        }
    }

    @DatabaseTable
    public static class RecentStat extends Stat implements Parcelable, Serializable {

        public static final Parcelable.Creator<RecentStat> CREATOR = new Parcelable.Creator<RecentStat>() {
            public RecentStat createFromParcel(Parcel in) {
                return new RecentStat(in);
            }

            public RecentStat[] newArray(int size) {
                return new RecentStat[size];
            }
        };

        public RecentStat() {
            super();
        }

        private RecentStat(Parcel in) {
            super(in);
        }
    }

    @DatabaseTable
    public static class SeasonStat extends Stat implements Parcelable, Serializable {

        public static final Parcelable.Creator<SeasonStat> CREATOR = new Parcelable.Creator<SeasonStat>() {
            public SeasonStat createFromParcel(Parcel in) {
                return new SeasonStat(in);
            }

            public SeasonStat[] newArray(int size) {
                return new SeasonStat[size];
            }
        };

        public SeasonStat() {
            super();
        }

        private SeasonStat(Parcel in) {
            super(in);
        }
    }
}
