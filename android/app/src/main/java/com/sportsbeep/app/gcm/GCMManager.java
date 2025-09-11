package com.sportsbeep.app.gcm;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.gcm.GoogleCloudMessaging;

import com.sportsbeep.app.module.GraphHolder;
import com.sportsbeep.app.storage.PreferenceHelper;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.AsyncTask;
import android.text.TextUtils;
import android.util.Log;

import java.io.IOException;

import javax.inject.Inject;
import javax.inject.Singleton;

@Singleton
public class GCMManager {

    private static final String TAG = GCMManager.class.getSimpleName();

    private static final int PLAY_SERVICES_RESOLUTION_REQUEST = 9000;

    private static final String SENDER_ID = "909379204679";

    @Inject
    PreferenceHelper mPreferenceHelper;

    private GoogleCloudMessaging mGcm;

    private Context mContext;

    @Inject
    public GCMManager(Context context) {
        mContext = context;
        GraphHolder.getInstance().inject(this);
    }

    public String getRegistrationId() {
        String registrationId = mPreferenceHelper.getGcmRegId();
        if (TextUtils.isEmpty(registrationId)) {
            return null;
        }

        int registeredVersion = mPreferenceHelper.getAppVersion();
        if (registeredVersion != getAppVersion()) {
            return null;
        }

        return registrationId;
    }

    private int getAppVersion() {
        try {
            PackageInfo pInfo = mContext.getPackageManager().getPackageInfo(mContext.getPackageName(), 0);
            return pInfo.versionCode;
        } catch (PackageManager.NameNotFoundException e) {
            throw new RuntimeException("Could not get package name: " + e);
        }
    }

    public void registerGcm(final RegisterGcmCallback callback) {
        new AsyncTask<Void, Void, String>() {
            @Override
            protected String doInBackground(Void... params) {
                String regId;
                try {
                    if (mGcm == null) {
                        mGcm = GoogleCloudMessaging.getInstance(mContext);
                    }
                    regId = mGcm.register(SENDER_ID);
                    mPreferenceHelper.setGcmRegId(regId);
                    mPreferenceHelper.setAppVersion(getAppVersion());
                } catch (IOException ex) {
                    Log.e(TAG, "GCM Registration Error: " + ex.getMessage());
                    return null;
                }

                return regId;
            }

            @Override
            protected void onPostExecute(String regId) {
                super.onPostExecute(regId);
                if (TextUtils.isEmpty(regId)) {
                    callback.onError();
                } else {
                    callback.onGcmRegistered(regId);
                }
            }
        }.execute();
    }

    public boolean checkPlayServices(Activity activity) {
        int resultCode = GooglePlayServicesUtil.isGooglePlayServicesAvailable(activity);
        if (resultCode != ConnectionResult.SUCCESS) {
            if (GooglePlayServicesUtil.isUserRecoverableError(resultCode)) {
                GooglePlayServicesUtil.getErrorDialog(resultCode, activity, PLAY_SERVICES_RESOLUTION_REQUEST).show();
            } else {
                Log.i(TAG, "This device does not support Google Play Services.");
            }

            return false;
        }

        return true;
    }

    public interface RegisterGcmCallback {

        public void onGcmRegistered(String regId);

        public void onError();
    }
}
