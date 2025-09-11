package com.sportsbeep.app.network.params;

import com.sportsbeep.app.model.question.QuestionAnswer;

import java.util.List;

public class AnswerParams {

    private List<QuestionAnswer> answers;

    public AnswerParams(List<QuestionAnswer> answers) {
        this.answers = answers;
    }

    public List<QuestionAnswer> getAnswers() {

        return answers;
    }

    public void setAnswers(List<QuestionAnswer> answers) {
        this.answers = answers;
    }
}
