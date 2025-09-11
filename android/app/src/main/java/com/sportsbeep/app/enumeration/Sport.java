package com.sportsbeep.app.enumeration;

import com.sportsbeep.app.model.game.GamePosition;

import java.io.Serializable;

public enum Sport implements Serializable {
    BASEBALL(
            GamePosition.newPlayerInstance("pitcher", Position.StartingPitcher, Position.ReliefPitcher, Position.ClosingPitcher),
            GamePosition.newPlayerInstance("catcher", Position.Catcher),
            GamePosition.newPlayerInstance("corner_infielder", Position.FirstBaseman, Position.ThirdBaseman),
            GamePosition.newPlayerInstance("middle_infielder", Position.SecondBaseman, Position.Shortstop),
            GamePosition.newPlayerInstance("outfielder", Position.RightFielder, Position.CenterFielder, Position.LeftFielder),
            GamePosition.newPlayerInstance("flex_player", Position.baseballValues())
    ),
    FOOTBALL(
            GamePosition.newSquadInstance("quarterbacks", "qb_squad", Position.Quarterback),
            GamePosition.newPlayerInstance("running_back", Position.RunningBack, Position.Wingback, Position.Halfback, Position.Fullback),
            GamePosition.newPlayerInstance("wide_receiver", Position.WideReceiver),
            GamePosition.newPlayerInstance("tight_end", Position.TightEnd),
            GamePosition.newPlayerInstance("flex_player", Position.RunningBack, Position.WideReceiver, Position.TightEnd),
            GamePosition.newSquadInstance("defense", "defense"),
            GamePosition.newPlayerInstance("kicker", Position.Kicker, Position.PlaceKicker),
            GamePosition.newSquadInstance("special_teams", "special_teams", Position.Holder, Position.KickoffSpecialist, Position.KickReturner, Position.Punter, Position.PuntReturner)
    ),
    BASKETBALL(),
    HOCKEY();

    private final int mMaxTeamPlayers;

    private final GamePosition[] mGamePositions;

    private Boolean mHasLeaguePick;

    Sport(GamePosition... gamePositions) {
        mGamePositions = gamePositions;
        mMaxTeamPlayers = gamePositions != null ? gamePositions.length - 1 : 0;
    }

    public GamePosition findGamePositionByTitleResName(String titleResName) {
        for (GamePosition position : mGamePositions) {
            if (titleResName.equals(position.getPositionGroupTitleResName())) {
                return position;
            }
        }

        return null;
    }

    public int getMaxTeamPositions() {
        return mMaxTeamPlayers;
    }

    public GamePosition[] getGamePositions() {
        return mGamePositions;
    }

    public boolean hasLeaguePick() {
        if (mHasLeaguePick == null) {
            mHasLeaguePick = false;
            GamePosition[] positions = getGamePositions();
            for (GamePosition position : positions) {
                if (GamePosition.LEAGUE_PICK.equals(position)) {
                    mHasLeaguePick = true;
                    break;
                }
            }
        }

        return mHasLeaguePick;
    }
}
