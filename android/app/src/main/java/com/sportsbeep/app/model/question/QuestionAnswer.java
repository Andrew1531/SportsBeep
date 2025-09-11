package com.sportsbeep.app.model.question;

public class QuestionAnswer {

    private long questionId;

    private long answerId;

    private String time;

    public QuestionAnswer(long questionId, long answerId, String time) {
        this.questionId = questionId;
        this.answerId = answerId;
        this.time = time;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof QuestionAnswer)) {
            return false;
        }

        QuestionAnswer answer = (QuestionAnswer) o;

        if (answerId != answer.answerId) {
            return false;
        }
        if (questionId != answer.questionId) {
            return false;
        }
        if (time != null ? !time.equals(answer.time) : answer.time != null) {
            return false;
        }

        return true;
    }

    @Override
    public int hashCode() {
        int result = (int) (questionId ^ (questionId >>> 32));
        result = 31 * result + (int) (answerId ^ (answerId >>> 32));
        result = 31 * result + (time != null ? time.hashCode() : 0);
        return result;
    }

    public long getQuestionId() {

        return questionId;
    }

    public void setQuestionId(long questionId) {
        this.questionId = questionId;
    }

    public long getAnswerId() {
        return answerId;
    }

    public void setAnswerId(long answerId) {
        this.answerId = answerId;
    }

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }
}
