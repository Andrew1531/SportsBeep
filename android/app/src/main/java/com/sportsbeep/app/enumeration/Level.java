package com.sportsbeep.app.enumeration;

public enum Level {
    PROFESSIONAL("professional"),
    COLLEGE("college"),
    INTERNATIONAL("international");

    private final String level;

    Level(String level) {
        this.level = level;
    }

    @Override
    public String toString() {
        return level;
    }
}
