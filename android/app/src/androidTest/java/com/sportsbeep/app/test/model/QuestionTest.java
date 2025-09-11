package com.sportsbeep.app.test.model;

import com.sportsbeep.app.model.question.Question;
import com.sportsbeep.app.module.NetworkModule;

import junit.framework.TestCase;

public class QuestionTest extends TestCase {

    private static final String JSON = "{\n"
            + "      \"id\": 3,\n"
            + "      \"text\": \"Which team will not make the most errors?\",\n"
            + "      \"type\": \"best\"\n"
            + "    }";

    private static Question getTestQuestion() {
        Question question = new Question();
        question.setType("best");
        question.setText("Which team will not make the most errors?");
        question.setId(3);

        return question;
    }

    public void testParse() {
        assertEquals(getTestQuestion(),
                NetworkModule.createGsonForConverter().fromJson(JSON, Question.class));
    }
}
