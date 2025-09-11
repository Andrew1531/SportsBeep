package com.sportsbeep.app.network.params;

public class SignInParams implements NetworkParam {

    private static final String ROOT_NAME = "api_user";

    private String email;

    private String password;

    public SignInParams(String email, String password) {
        setEmail(email);
        setPassword(password);
    }

    @Override
    public String getRootName() {
        return ROOT_NAME;
    }

    public String getEmail() {
        return email;
    }

    void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    void setPassword(String password) {
        this.password = password;
    }
}
