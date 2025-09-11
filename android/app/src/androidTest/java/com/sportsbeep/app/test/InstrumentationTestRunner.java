package com.sportsbeep.app.test;

import android.os.Bundle;

public class InstrumentationTestRunner extends android.test.InstrumentationTestRunner {

    @Override
    public void onCreate(Bundle arguments) {
        super.onCreate(arguments);
        // Fixes an issue with 4.3+
        // https://code.google.com/p/dexmaker/issues/detail?id=2
        System.setProperty("dexmaker.dexcache", getTargetContext().getCacheDir().toString());
    }
}
