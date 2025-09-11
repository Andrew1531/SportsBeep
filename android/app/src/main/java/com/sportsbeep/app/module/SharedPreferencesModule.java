package com.sportsbeep.app.module;

import com.sportsbeep.app.gcm.GCMManager;
import com.sportsbeep.app.gcm.GcmIntentService;
import com.sportsbeep.app.storage.PreferenceHelper;

import android.content.Context;
import android.content.SharedPreferences;

import javax.inject.Singleton;

import dagger.Module;
import dagger.Provides;

@Module(
        injects = {
                GCMManager.class,
                PreferenceHelper.class
        },
        includes = ContextModule.class
)
public class SharedPreferencesModule {

    private static final String PREFS_NAME = "prefs";

    @Provides
    @Singleton
    SharedPreferences providesSharedPreferences(Context context) {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
    }
}
