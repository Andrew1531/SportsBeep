package com.sportsbeep.app.util;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.TimeZone;

public class DateFormatUtils {

    private static final DateFormat DATE_FORMAT = new SimpleDateFormat("EEE, MMMM d, yyyy");

    private static final DateFormat TIME_FORMAT = new SimpleDateFormat("h:mm a z");

    static {
        TimeZone timeZone = TimeZone.getTimeZone("America/New_York");
        DATE_FORMAT.setTimeZone(timeZone);
        TIME_FORMAT.setTimeZone(timeZone);
    }

    private DateFormatUtils() {
    }

    public static DateFormat getDateFormat() {
        return DATE_FORMAT;
    }

    public static DateFormat getTimeFormat() {
        return TIME_FORMAT;
    }
}
