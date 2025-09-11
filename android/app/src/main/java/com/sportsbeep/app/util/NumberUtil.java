package com.sportsbeep.app.util;

public class NumberUtil {

    private NumberUtil() {

    }

    // http://stackoverflow.com/a/6810409
    public static String decimalToOrdinal(int number) {
        String[] suffixes = new String[]{"th", "st", "nd", "rd", "th", "th", "th", "th", "th",
                "th"};
        switch (number % 100) {
            case 11:
            case 12:
            case 13:
                return number + "th";
            default:
                return number + suffixes[number % 10];
        }
    }
}
