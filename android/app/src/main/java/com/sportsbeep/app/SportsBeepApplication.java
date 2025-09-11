package com.sportsbeep.app;

import com.crashlytics.android.Crashlytics;
import com.sportsbeep.app.module.ContextModule;
import com.sportsbeep.app.module.DefaultModule;
import com.sportsbeep.app.module.GCMModule;
import com.sportsbeep.app.module.GraphHolder;
import com.sportsbeep.app.module.SharedPreferencesModule;

import android.app.Application;

public class SportsBeepApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        if (FlavorConstants.SERVER_TYPE == ServerType.PRODUCTION && BuildConstants.BUILD_TYPE == BuildType.RELEASE) {
            Crashlytics.start(this);
        }

        GraphHolder.getInstance().addModules(getModules());
    }

    Object[] getModules() {
        return new Object[]{
                new ContextModule(this),
                new SharedPreferencesModule(),
                new DefaultModule(),
                new GCMModule()
        };
    }
}
