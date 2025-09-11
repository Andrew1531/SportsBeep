package com.sportsbeep.app.test.model;

import com.google.gson.Gson;

import com.sportsbeep.app.model.user.User;
import com.sportsbeep.app.module.NetworkModule;

import junit.framework.TestCase;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Locale;
import java.util.TimeZone;

public class UserTest extends TestCase {

    private static final String FORMAT_ISO_8601 = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

    private static final DateFormat sIso8601Format;

    static {
        sIso8601Format = new SimpleDateFormat(FORMAT_ISO_8601, Locale.US);
        sIso8601Format.setTimeZone(TimeZone.getTimeZone("UTC"));
    }

    private static final String JSON = "{\n" +
            "  \"id\": 1,\n" +
            "  \"first_name\": \"Simeon\",\n" +
            "  \"last_name\": \"Satterfield\",\n" +
            "  \"email\": \"test@test.com\",\n" +
            "  \"avatar\": null,\n" +
            "  \"authentication_token\": \"Qfq57VTLrK4JVk6N1AV9\",\n" +
            "  \"created_at\": \"2014-05-01T16:14:11.114Z\",\n" +
            "  \"updated_at\": \"2014-05-01T16:14:11.119Z\"\n" +
            "}";

    public void testParse() {
        Gson gson = NetworkModule.createGsonForConverter();
        User user = gson.fromJson(JSON, User.class);
        User testUser = getTestModel();

        assertEquals(user.getId(), testUser.getId());
        assertEquals(user.getFirstName(), testUser.getFirstName());
        assertEquals(user.getLastName(), testUser.getLastName());
        assertEquals(user.getEmail(), testUser.getEmail());
        assertEquals(user.getAvatarUrl(), testUser.getAvatarUrl());
        assertEquals(user.getAuthenticationToken(), testUser.getAuthenticationToken());
        assertEquals(user.getCreatedAt(), testUser.getCreatedAt());
        assertEquals(user.getUpdatedAt(), testUser.getUpdatedAt());
    }

    private User getTestModel() {
        User user = new User();
        user.setId(1);
        user.setFirstName("Simeon");
        user.setLastName("Satterfield");
        user.setEmail("test@test.com");
        user.setAvatarUrl(null);
        user.setAuthenticationToken("Qfq57VTLrK4JVk6N1AV9");

        try {
            user.setCreatedAt(sIso8601Format.parse("2014-05-01T16:14:11.114Z"));
            user.setUpdatedAt(sIso8601Format.parse("2014-05-01T16:14:11.119Z"));
        } catch (ParseException e) {
            throw new RuntimeException(e);
        }

        return user;
    }
}
