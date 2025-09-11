package com.sportsbeep.app.model.question;

import java.util.List;

public class TimerStateList {

    private List<TimerState> timerStates;

    public List<TimerState> getTimerStates() {
        return timerStates;
    }

    public void setTimerStates(List<TimerState> timerStates) {
        this.timerStates = timerStates;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof TimerStateList)) {
            return false;
        }

        TimerStateList that = (TimerStateList) o;

        if (timerStates != null ? !timerStates.equals(that.timerStates)
                : that.timerStates != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        return timerStates != null ? timerStates.hashCode() : 0;
    }
}
