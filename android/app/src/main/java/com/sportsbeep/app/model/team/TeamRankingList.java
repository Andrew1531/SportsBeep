package com.sportsbeep.app.model.team;

import java.util.List;

public class TeamRankingList {

    private List<TeamRanking> rankings;

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        TeamRankingList that = (TeamRankingList) o;

        if (rankings != null ? !rankings.equals(that.rankings) : that.rankings != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        return rankings != null ? rankings.hashCode() : 0;
    }

    public List<TeamRanking> getRankings() {
        return rankings;
    }

    public void setRankings(List<TeamRanking> rankings) {
        this.rankings = rankings;
    }
}
