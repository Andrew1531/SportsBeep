package com.sportsbeep.app.module;

import com.google.android.gms.analytics.GoogleAnalytics;
import com.google.android.gms.analytics.Logger;
import com.google.android.gms.analytics.Tracker;

import com.sportsbeep.app.BuildConfig;
import com.sportsbeep.app.R;

import android.content.Context;

import javax.inject.Singleton;

import dagger.Module;
import dagger.Provides;

@Module(
        includes = ContextModule.class,
        library = true
)
public class AnalyticsModule {

    @Singleton
    @Provides
    GoogleAnalytics providesGoogleAnalytics(Context context) {
        GoogleAnalytics ga = GoogleAnalytics.getInstance(context);
        if (BuildConfig.DEBUG) {
            ga.getLogger().setLogLevel(Logger.LogLevel.VERBOSE);
            ga.setDryRun(true);
        }

        return ga;
    }
}
