package com.sportsbeep.app.network.params;

public class PutDeviceTokenParams implements NetworkParam {

    private final String platform = "android";

    private String deviceToken;

    public PutDeviceTokenParams(String deviceToken) {
        this.deviceToken = deviceToken;
    }

    public String getDeviceToken() {
        return deviceToken;
    }

    public void setDeviceToken(String deviceToken) {
        this.deviceToken = deviceToken;
    }

    public String getPlatform() {
        return platform;
    }

    @Override
    public String getRootName() {
        return "api_user";
    }
}
