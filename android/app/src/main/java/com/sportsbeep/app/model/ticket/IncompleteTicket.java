package com.sportsbeep.app.model.ticket;

import com.j256.ormlite.field.DataType;
import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.game.GamePosition;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.model.team.Team;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.HashMap;

@DatabaseTable
public class IncompleteTicket implements Parcelable {

    public static final Parcelable.Creator<IncompleteTicket> CREATOR
            = new Parcelable.Creator<IncompleteTicket>() {
        public IncompleteTicket createFromParcel(Parcel in) {
            return new IncompleteTicket(in);
        }

        public IncompleteTicket[] newArray(int size) {
            return new IncompleteTicket[size];
        }
    };

    @DatabaseField(generatedId = true, columnName = "_id")
    private long id;

    @DatabaseField(foreign = true, foreignAutoRefresh = true)
    private Game game;

    @DatabaseField(dataType = DataType.SERIALIZABLE)
    private HashMap<GamePosition, Object> positionMap;

    @DatabaseField(foreign = true, foreignAutoRefresh = true)
    private Game leaguePickGame;

    @DatabaseField(foreign = true, foreignAutoRefresh = true)
    private Team leaguePickTeam;

    public IncompleteTicket() {
        setPositionMap(new HashMap<GamePosition, Object>());
    }

    private IncompleteTicket(Parcel in) {
        setId(in.readLong());
        setGame(in.<Game>readParcelable(Game.class.getClassLoader()));
        setPositionMap((HashMap<GamePosition, Object>) in.readSerializable());
        setLeaguePickGame(in.<Game>readParcelable(Game.class.getClassLoader()));
        setLeaguePickTeam(in.<Team>readParcelable(Team.class.getClassLoader()));
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeLong(getId());
        dest.writeParcelable(getGame(), flags);
        dest.writeSerializable(getPositionMap());
        dest.writeParcelable(getLeaguePickGame(), flags);
        dest.writeParcelable(getLeaguePickTeam(), flags);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        IncompleteTicket that = (IncompleteTicket) o;

        if (id != that.id) {
            return false;
        }
        if (game != null ? !game.equals(that.game) : that.game != null) {
            return false;
        }
        if (leaguePickGame != null ? !leaguePickGame.equals(that.leaguePickGame) : that.leaguePickGame != null) {
            return false;
        }
        if (leaguePickTeam != null ? !leaguePickTeam.equals(that.leaguePickTeam) : that.leaguePickTeam != null) {
            return false;
        }
        if (positionMap != null ? !positionMap.equals(that.positionMap) : that.positionMap != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        int result = (int) (id ^ (id >>> 32));
        result = 31 * result + (game != null ? game.hashCode() : 0);
        result = 31 * result + (positionMap != null ? positionMap.hashCode() : 0);
        result = 31 * result + (leaguePickGame != null ? leaguePickGame.hashCode() : 0);
        result = 31 * result + (leaguePickTeam != null ? leaguePickTeam.hashCode() : 0);
        return result;
    }

    public void putPlayer(GamePosition position, Player player) {
        positionMap.put(position, player);
    }

    public void putSquad(GamePosition position, Team team) {
        positionMap.put(position, team);
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public Game getGame() {
        return game;
    }

    public void setGame(Game game) {
        this.game = game;
    }

    public HashMap<GamePosition, Object> getPositionMap() {
        return positionMap;
    }

    public void setPositionMap(HashMap<GamePosition, Object> positionMap) {
        this.positionMap = positionMap;
    }

    public Game getLeaguePickGame() {
        return leaguePickGame;
    }

    public void setLeaguePickGame(Game leaguePickGame) {
        this.leaguePickGame = leaguePickGame;
    }

    public Team getLeaguePickTeam() {
        return leaguePickTeam;
    }

    public void setLeaguePickTeam(Team leaguePickTeam) {
        this.leaguePickTeam = leaguePickTeam;
    }
}
