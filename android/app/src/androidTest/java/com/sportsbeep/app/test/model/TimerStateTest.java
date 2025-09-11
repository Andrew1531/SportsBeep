package com.sportsbeep.app.test.model;

import com.sportsbeep.app.model.question.TimerState;
import com.sportsbeep.app.module.NetworkModule;

import junit.framework.TestCase;

public class TimerStateTest extends TestCase {

    private static final String JSON = "{\n"
            + "      \"id\": 1,\n"
            + "      \"encrypted_text\": \"knnv4y75FxsjHokmptzCFwYi8LxQ\"\n"
            + "    }";

    private static TimerState getTestTimerState() {
        TimerState timerState = new TimerState();
        timerState.setId(1);
        timerState.setEncryptedText("knnv4y75FxsjHokmptzCFwYi8LxQ");

        return timerState;
    }

    public void testParse() {
        assertEquals(getTestTimerState(),
                NetworkModule.createGsonForConverter().fromJson(JSON, TimerState.class));
    }
}
