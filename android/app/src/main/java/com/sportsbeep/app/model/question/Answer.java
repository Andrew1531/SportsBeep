package com.sportsbeep.app.model.question;

import com.sportsbeep.app.model.team.Team;

public class Answer {

    private String time;

    private String score;

    private boolean correct;

    private Question question;

    private Team team;

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        Answer answer = (Answer) o;

        if (correct != answer.correct) {
            return false;
        }
        if (question != null ? !question.equals(answer.question) : answer.question != null) {
            return false;
        }
        if (score != null ? !score.equals(answer.score) : answer.score != null) {
            return false;
        }
        if (team != null ? !team.equals(answer.team) : answer.team != null) {
            return false;
        }
        if (time != null ? !time.equals(answer.time) : answer.time != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        int result = time != null ? time.hashCode() : 0;
        result = 31 * result + (score != null ? score.hashCode() : 0);
        result = 31 * result + (correct ? 1 : 0);
        result = 31 * result + (question != null ? question.hashCode() : 0);
        result = 31 * result + (team != null ? team.hashCode() : 0);
        return result;
    }

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }

    public String getScore() {
        return score;
    }

    public void setScore(String score) {
        this.score = score;
    }

    public boolean isCorrect() {
        return correct;
    }

    public void setCorrect(boolean correct) {
        this.correct = correct;
    }

    public Question getQuestion() {
        return question;
    }

    public void setQuestion(Question question) {
        this.question = question;
    }

    public Team getTeam() {
        return team;
    }

    public void setTeam(Team team) {
        this.team = team;
    }
}
