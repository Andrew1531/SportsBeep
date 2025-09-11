package com.sportsbeep.app.network.params;

public class CreateAccountParams implements NetworkParam {

    private static final String ROOT_NAME = "api_user";

    private String email;

    private String password;

    private String username;

    private String promoCode;

    public CreateAccountParams(String username, String email, String password, String promoCode) {
        setEmail(email);
        setPassword(password);
        setUsername(username);
        setPromoCode(promoCode);
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

    public String getUsername() {
        return username;
    }

    void setUsername(String username) {
        this.username = username;
    }

    public String getPromoCode() {
        return promoCode;
    }

    void setPromoCode(String promoCode) {
        this.promoCode = promoCode;
    }
}
