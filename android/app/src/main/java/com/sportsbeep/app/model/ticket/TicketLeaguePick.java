package com.sportsbeep.app.model.ticket;

import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.team.Team;

import java.util.List;

public class TicketLeaguePick {

    private String amount;

    private String score;

    private List<Scorer> scorers;

    private Team team;

    private Game game;

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        TicketLeaguePick that = (TicketLeaguePick) o;

        if (amount != null ? !amount.equals(that.amount) : that.amount != null) {
            return false;
        }
        if (game != null ? !game.equals(that.game) : that.game != null) {
            return false;
        }
        if (score != null ? !score.equals(that.score) : that.score != null) {
            return false;
        }
        if (scorers != null ? !scorers.equals(that.scorers) : that.scorers != null) {
            return false;
        }
        if (team != null ? !team.equals(that.team) : that.team != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        int result = amount != null ? amount.hashCode() : 0;
        result = 31 * result + (score != null ? score.hashCode() : 0);
        result = 31 * result + (scorers != null ? scorers.hashCode() : 0);
        result = 31 * result + (team != null ? team.hashCode() : 0);
        result = 31 * result + (game != null ? game.hashCode() : 0);
        return result;
    }

    public String getAmount() {
        return amount;
    }

    public void setAmount(String amount) {
        this.amount = amount;
    }

    public String getScore() {
        return score;
    }

    public void setScore(String score) {
        this.score = score;
    }

    public List<Scorer> getScorers() {
        return scorers;
    }

    public void setScorers(List<Scorer> scorers) {
        this.scorers = scorers;
    }

    public Team getTeam() {
        return team;
    }

    public void setTeam(Team team) {
        this.team = team;
    }

    public Game getGame() {
        return game;
    }

    public void setGame(Game game) {
        this.game = game;
    }

    public static class Scorer {

        private String name;

        private String seasonTotal;

        @Override
        public boolean equals(Object o) {
            if (this == o) {
                return true;
            }
            if (o == null || getClass() != o.getClass()) {
                return false;
            }

            Scorer scorer = (Scorer) o;

            if (name != null ? !name.equals(scorer.name) : scorer.name != null) {
                return false;
            }
            if (seasonTotal != null ? !seasonTotal.equals(scorer.seasonTotal) : scorer.seasonTotal != null) {
                return false;
            }

            return true;
        }

        @Override
        public int hashCode() {
            int result = name != null ? name.hashCode() : 0;
            result = 31 * result + (seasonTotal != null ? seasonTotal.hashCode() : 0);
            return result;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getSeasonTotal() {
            return seasonTotal;
        }

        public void setSeasonTotal(String seasonTotal) {
            this.seasonTotal = seasonTotal;
        }
    }
}
