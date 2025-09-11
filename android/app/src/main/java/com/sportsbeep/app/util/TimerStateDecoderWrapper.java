package com.sportsbeep.app.util;

import com.sportsbeep.app.model.question.TimerState;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

public class TimerStateDecoderWrapper {

    private static final int CONTRACT_VERSION = 1;

    public static final int SECONDS = 14;

    private static final int PRECISION = 10;

    private final TimerStateDecoder mDecoder;

    public TimerStateDecoderWrapper(long ticketId) {
        mDecoder = new TimerStateDecoder();
        mDecoder.reset(CONTRACT_VERSION, ticketId, SECONDS, PRECISION);
    }

    public void addTimerStates(List<TimerState> timerStates) {
        for (TimerState timerState : timerStates) {
            mDecoder.addTimerStateText(timerState.getEncryptedText());
        }

        // TODO: Should probably be deleted
        // mDecoder.decodeAll();
    }

    public String getTime(long millis) {
        BigDecimal bd = new BigDecimal(millis / 1000f).setScale(1, RoundingMode.HALF_UP);
        return mDecoder.findTimerStateText(bd.floatValue());
    }
}
