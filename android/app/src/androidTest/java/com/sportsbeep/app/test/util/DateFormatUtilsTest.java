package com.sportsbeep.app.test.util;

import com.sportsbeep.app.util.DateFormatUtils;

import junit.framework.TestCase;

import java.util.Date;

public class DateFormatUtilsTest extends TestCase {

    public void testDateFormat() {
        Date date = new Date(0);
        String dateString = DateFormatUtils.getDateFormat().format(date);

        assertEquals("Wed, December 31, 1969", dateString);
    }

    public void testTimeFormat() {
        Date date = new Date(0);
        String timeString = DateFormatUtils.getTimeFormat().format(date);

        assertEquals("7:00 PM EST", timeString);
    }
}
