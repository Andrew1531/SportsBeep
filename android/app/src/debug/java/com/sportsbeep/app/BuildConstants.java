package com.sportsbeep.app;

import retrofit.RestAdapter;

public class BuildConstants {

    public static final BuildType BUILD_TYPE = BuildType.DEBUG;

    public static final RestAdapter.LogLevel LOG_LEVEL = RestAdapter.LogLevel.FULL;

    private BuildConstants() {

    }
}
