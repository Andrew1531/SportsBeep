package com.sportsbeep.app.model.question;

import java.util.List;

public class AnswerList {

    private List<Answer> answers;

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }

        AnswerList that = (AnswerList) o;

        if (answers != null ? !answers.equals(that.answers) : that.answers != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        return answers != null ? answers.hashCode() : 0;
    }

    public List<Answer> getAnswers() {
        return answers;
    }

    public void setAnswers(List<Answer> answers) {
        this.answers = answers;
    }
}
