package com.sportsbeep.app.network.params;

public class ContestsParams {

    private ContestStatus status;

    public ContestsParams(ContestStatus status) {
        this.status = status;
    }

    public ContestStatus getStatus() {
        return status;
    }

    public void setStatus(ContestStatus status) {
        this.status = status;
    }

    public static enum ContestStatus {
        LIVE("live"),
        UPCOMING("upcoming"),
        PAST("past");

        private final String status;

        ContestStatus(String status) {
            this.status = status;
        }

        @Override
        public String toString() {
            return status;
        }
    }
}
