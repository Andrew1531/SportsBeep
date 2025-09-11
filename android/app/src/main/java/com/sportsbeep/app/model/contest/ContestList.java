package com.sportsbeep.app.model.contest;

import java.util.List;

public class ContestList {

    private List<Contest> contests;

    public ContestList(List<Contest> contests) {
        this.contests = contests;
    }

    public List<Contest> getContests() {
        return contests;
    }

    public void setContests(List<Contest> contests) {
        this.contests = contests;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof ContestList)) {
            return false;
        }

        ContestList that = (ContestList) o;

        if (contests != null ? !contests.equals(that.contests) : that.contests != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        return contests != null ? contests.hashCode() : 0;
    }
}
