package com.sportsbeep.app.storage;

import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.user.User;

import android.content.SharedPreferences;

import javax.inject.Inject;
import javax.inject.Singleton;

@Singleton
public class PreferenceHelper {

    private static final String KEY_AUTH_TOKEN = "auth_token";

    private static final String KEY_SPORT = "sport";

    private static final String KEY_LEVEL = "level";

    private static final String KEY_GCM_REG_ID = "gcm_reg_id";

    private static final String KEY_APP_VERSION = "app_version";

    private static final String KEY_TUTORIAL_VIEWED = "tutorial_viewed";

    private static final String KEY_FIRST_NAME = "first_name";

    private static final String KEY_LAST_NAME = "last_name";

    private static final String KEY_AVATAR_URL = "avatar_url";

    private static final String KEY_USERNAME = "username";

    @Inject
    SharedPreferences mPrefs;

    public void removeAll() {
        mPrefs.edit().clear().apply();
    }

    public String getAuthToken() {
        return mPrefs.getString(KEY_AUTH_TOKEN, null);
    }

    public void setAuthToken(String token) {
        mPrefs.edit().putString(KEY_AUTH_TOKEN, token).apply();
    }

    public Sport getSport() {
        String sport = mPrefs.getString(KEY_SPORT, Sport.BASEBALL.name());
        try {
            return Sport.valueOf(sport);
        } catch (IllegalArgumentException e) {
            setSport(Sport.BASEBALL);
            return Sport.BASEBALL;
        }
    }

    public void setSport(Sport sport) {
        mPrefs.edit().putString(KEY_SPORT, sport.name()).apply();
    }

    public Level getLevel() {
        String level = mPrefs.getString(KEY_LEVEL, Level.PROFESSIONAL.name());
        try {
            return Level.valueOf(level);
        } catch (IllegalArgumentException e) {
            setLevel(Level.PROFESSIONAL);
            return Level.PROFESSIONAL;
        }
    }

    public void setLevel(Level level) {
        mPrefs.edit().putString(KEY_LEVEL, level.name()).apply();
    }

    public String getGcmRegId() {
        return mPrefs.getString(KEY_GCM_REG_ID, null);
    }

    public void setGcmRegId(String regId) {
        mPrefs.edit().putString(KEY_GCM_REG_ID, regId).apply();
    }

    public int getAppVersion() {
        return mPrefs.getInt(KEY_APP_VERSION, 0);
    }

    public void setAppVersion(int appVersion) {
        mPrefs.edit().putInt(KEY_APP_VERSION, appVersion).apply();
    }

    public boolean isTutorialViewed() {
        return mPrefs.getBoolean(KEY_TUTORIAL_VIEWED, false);
    }

    public void setTutorialViewed(boolean viewed) {
        mPrefs.edit().putBoolean(KEY_TUTORIAL_VIEWED, viewed).apply();
    }

    public String getFirstName() {
        return mPrefs.getString(KEY_FIRST_NAME, null);
    }

    public void setFirstName(String firstName) {
        mPrefs.edit().putString(KEY_FIRST_NAME, firstName).apply();
    }

    public String getLastName() {
        return mPrefs.getString(KEY_LAST_NAME, null);
    }

    public void setLastName(String lastName) {
        mPrefs.edit().putString(KEY_LAST_NAME, lastName).apply();
    }

    public String getAvatarUrl() {
        return mPrefs.getString(KEY_AVATAR_URL, null);
    }

    public void setAvatarUrl(String lastName) {
        mPrefs.edit().putString(KEY_AVATAR_URL, lastName).apply();
    }

    public String getUsername() {
        return mPrefs.getString(KEY_USERNAME, null);
    }

    public void setUsername(String lastName) {
        mPrefs.edit().putString(KEY_USERNAME, lastName).apply();
    }

    public void setUser(User user) {
        setFirstName(user.getFirstName());
        setLastName(user.getLastName());
        setAvatarUrl(user.getAvatarUrl());
        setUsername(user.getUsername());
    }
}
