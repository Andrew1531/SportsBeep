package com.sportsbeep.app.enumeration;

import java.io.Serializable;

public enum Position implements Serializable {
    FirstBaseman("1B"),
    SecondBaseman("2B"),
    ThirdBaseman("3B"),
    Shortstop("SS"),
    StartingPitcher("SP"),
    ReliefPitcher("RP"),
    ClosingPitcher("CP"),
    Catcher("C"),
    LeftFielder("LF"),
    CenterFielder("CF"),
    RightFielder("RF"),
    DesignatedHitter("DH"),
    Cornerback("CB"),
    DefensiveBack("DB"),
    DefensiveEnd("DE"),
    DefensiveTackle("DT"),
    FreeSafety("FS"),
    InteriorLinebacker("ILB"),
    Linebacker("LB"),
    MiddleLinebacker("MLB"),
    NoseTackle("NT"),
    OutsideLinebacker("OLB"),
    Safety("S"),
    StrongSafety("SS"),
    Fullback("FB"),
    Halfback("HB"),
    Quarterback("QB"),
    RunningBack("RB"),
    TightEnd("TE"),
    Wingback("WB"),
    WideReceiver("WR"),
    Kicker("K"),
    PlaceKicker("PK"),
    Holder("H"),
    KickoffSpecialist("KOS"),
    KickReturner("KR"),
    Punter("P"),
    PuntReturner("PR");

    private final String abbr;

    Position(String abbr) {
        this.abbr = abbr;
    }

    public static Position getPositionForAbbr(String abbr) {
        Position[] values = values();
        for (Position value : values) {
            if (value.abbr.equals(abbr)) {
                return value;
            }
        }

        return null;
    }

    public static Position[] baseballValues() {
        return new Position[]{
                FirstBaseman,
                SecondBaseman,
                ThirdBaseman,
                Shortstop,
                StartingPitcher,
                ReliefPitcher,
                ClosingPitcher,
                Catcher,
                LeftFielder,
                CenterFielder,
                RightFielder,
                DesignatedHitter
        };
    }

    public String getAbbreviation() {
        return abbr;
    }
}
