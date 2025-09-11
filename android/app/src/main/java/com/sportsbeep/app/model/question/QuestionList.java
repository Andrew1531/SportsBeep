package com.sportsbeep.app.model.question;

import java.util.List;

public class QuestionList {

    private List<Question> questions;

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof QuestionList)) {
            return false;
        }

        QuestionList that = (QuestionList) o;

        if (questions != null ? !questions.equals(that.questions) : that.questions != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        return questions != null ? questions.hashCode() : 0;
    }

    public List<Question> getQuestions() {

        return questions;
    }

    public void setQuestions(List<Question> questions) {
        this.questions = questions;
    }
}
