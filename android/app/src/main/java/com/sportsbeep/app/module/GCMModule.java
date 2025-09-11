package com.sportsbeep.app.module;

import com.sportsbeep.app.gcm.GCMManager;
import com.sportsbeep.app.ui.game.pickgame.PickGameActivity;

import android.content.Context;

import javax.inject.Singleton;

import dagger.Module;
import dagger.Provides;

@Module(
        injects = PickGameActivity.class,
        includes = {
                ContextModule.class,
                SharedPreferencesModule.class
        },
        complete = false
)
public class GCMModule {

    @Provides
    @Singleton
    GCMManager providesGCMManager(Context context) {
        return new GCMManager(context);
    }
}
