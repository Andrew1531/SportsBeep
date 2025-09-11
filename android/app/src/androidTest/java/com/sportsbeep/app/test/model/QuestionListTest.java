package com.sportsbeep.app.test.model;

import com.sportsbeep.app.model.question.Question;
import com.sportsbeep.app.model.question.QuestionList;
import com.sportsbeep.app.module.NetworkModule;

import junit.framework.TestCase;

import java.util.ArrayList;
import java.util.List;

public class QuestionListTest extends TestCase {

    private static final String JSON = "{\n"
            + "  \"questions\": [\n"
            + "    {\n"
            + "      \"id\": 3,\n"
            + "      \"text\": \"Which team will not make the most errors?\",\n"
            + "      \"type\": \"best\"\n"
            + "    },\n"
            + "    {\n"
            + "      \"id\": 1,\n"
            + "      \"text\": \"Which team will hit the most home runs?\",\n"
            + "      \"type\": \"best\"\n"
            + "    },\n"
            + "    {\n"
            + "      \"id\": 2,\n"
            + "      \"text\": \"Which team will give up the least doubles?\",\n"
            + "      \"type\": \"best\"\n"
            + "    },\n"
            + "    {\n"
            + "      \"id\": 6,\n"
            + "      \"text\": \"Which team will strike out the most?\",\n"
            + "      \"type\": \"bust\"\n"
            + "    },\n"
            + "    {\n"
            + "      \"id\": 5,\n"
            + "      \"text\": \"Which will not make the most hits?\",\n"
            + "      \"type\": \"bust\"\n"
            + "    },\n"
            + "    {\n"
            + "      \"id\": 4,\n"
            + "      \"text\": \"Which team will steal the least?\",\n"
            + "      \"type\": \"bust\"\n"
            + "    }\n"
            + "  ]\n"
            + "}";

    public static List<Question> getTestQuestionList() {
        List<Question> questionList = new ArrayList<Question>();

        Question question = new Question();
        question.setId(3);
        question.setText("Which team will not make the most errors?");
        question.setType("best");
        questionList.add(question);

        question = new Question();
        question.setId(1);
        question.setText("Which team will hit the most home runs?");
        question.setType("best");
        questionList.add(question);

        question = new Question();
        question.setId(2);
        question.setText("Which team will give up the least doubles?");
        question.setType("best");
        questionList.add(question);

        question = new Question();
        question.setId(6);
        question.setText("Which team will strike out the most?");
        question.setType("bust");
        questionList.add(question);

        question = new Question();
        question.setId(5);
        question.setText("Which will not make the most hits?");
        question.setType("bust");
        questionList.add(question);

        question = new Question();
        question.setId(4);
        question.setText("Which team will steal the least?");
        question.setType("bust");
        questionList.add(question);

        return questionList;
    }

    public void testParse() {
        List<Question> testQuestionList = getTestQuestionList();
        List<Question> questionList = NetworkModule.createGsonForConverter()
                .fromJson(JSON, QuestionList.class).getQuestions();

        assertEquals(testQuestionList.size(), questionList.size());

        for (int i = 0; i < testQuestionList.size(); i++) {
            Question testQuestion = testQuestionList.get(i);
            Question question = questionList.get(i);

            assertEquals(testQuestion, question);
        }
    }
}
