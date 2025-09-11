package com.sportsbeep.app.model.game;

import com.sportsbeep.app.enumeration.Position;

import android.content.Context;
import android.os.Parcel;
import android.os.Parcelable;

import java.io.Serializable;
import java.util.Arrays;

public class GamePosition implements Parcelable, Serializable {

    public static final GamePosition LEAGUE_PICK = GamePosition.newLeaguePickInstance("league_pick");

    public static final Parcelable.Creator<GamePosition> CREATOR = new Parcelable.Creator<GamePosition>() {
        public GamePosition createFromParcel(Parcel in) {
            return new GamePosition(in);
        }

        public GamePosition[] newArray(int size) {
            return new GamePosition[size];
        }
    };

    private final String positionGroupTitleResName;

    private final String titleResName;

    private final Position[] positions;

    private final boolean squad;

    private GamePosition(String positionGroupTitleResName, boolean squad, Position... positions) {
        this(positionGroupTitleResName, null, squad, positions);
    }

    private GamePosition(String positionGroupTitleResName, String titleResName, boolean squad, Position... positions) {
        this.positionGroupTitleResName = positionGroupTitleResName;
        this.positions = positions;
        this.squad = squad;
        this.titleResName = titleResName;
    }

    private GamePosition(Parcel in) {
        this.positionGroupTitleResName = in.readString();
        this.positions = (Position[]) in.readSerializable();
        this.squad = in.readInt() == 1;
        this.titleResName = in.readString();
    }

    public static GamePosition newPlayerInstance(String positionGroupTitle, Position... positions) {
        return new GamePosition(positionGroupTitle, false, positions);
    }

    public static GamePosition newSquadInstance(String positionGroupTitle, String abbreviation, Position... positions) {
        return new GamePosition(positionGroupTitle, abbreviation, true, positions);
    }

    public static GamePosition newLeaguePickInstance(String positionGroupTitle) {
        return new GamePosition(positionGroupTitle, false);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        GamePosition that = (GamePosition) o;

        if (squad != that.squad) {
            return false;
        }
        if (titleResName != null ? !titleResName.equals(that.titleResName) : that.titleResName != null) {
            return false;
        }
        if (positionGroupTitleResName != null ? !positionGroupTitleResName.equals(that.positionGroupTitleResName) : that.positionGroupTitleResName != null) {
            return false;
        }
        if (!Arrays.equals(positions, that.positions)) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        int result = positionGroupTitleResName != null ? positionGroupTitleResName.hashCode() : 0;
        result = 31 * result + (titleResName != null ? titleResName.hashCode() : 0);
        result = 31 * result + (positions != null ? Arrays.hashCode(positions) : 0);
        result = 31 * result + (squad ? 1 : 0);
        return result;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(getPositionGroupTitleResName());
        dest.writeSerializable(getPositions());
        dest.writeInt(isSquad() ? 1 : 0);
        dest.writeString(getTitleResName());
    }

    public String getPositionGroupTitle(Context context) {
        int resId = context.getResources().getIdentifier(getPositionGroupTitleResName(), "string", context.getPackageName());
        return context.getString(resId);
    }

    public String getTitle(Context context) {
        int resId = context.getResources().getIdentifier(getTitleResName(), "string", context.getPackageName());
        return context.getString(resId);
    }

    public Position[] getPositions() {
        return positions;
    }

    public String getPositionGroupTitleResName() {
        return positionGroupTitleResName;
    }

    public boolean isSquad() {
        return squad;
    }

    public String getTitleResName() {
        return titleResName;
    }
}
