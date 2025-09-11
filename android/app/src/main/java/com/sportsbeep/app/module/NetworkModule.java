package com.sportsbeep.app.module;

import com.google.gson.FieldNamingPolicy;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParseException;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;

import com.sportsbeep.app.BuildConstants;
import com.sportsbeep.app.FlavorConstants;
import com.sportsbeep.app.enumeration.Position;
import com.sportsbeep.app.network.NetworkClient;
import com.sportsbeep.app.network.NetworkService;
import com.sportsbeep.app.network.params.ContestsParams;
import com.sportsbeep.app.network.params.NetworkParam;
import com.sportsbeep.app.storage.PreferenceHelper;
import com.sportsbeep.app.util.ISODateAdapter;

import java.lang.reflect.Type;
import java.util.Date;

import javax.inject.Singleton;

import dagger.Module;
import dagger.Provides;
import retrofit.RequestInterceptor;
import retrofit.RestAdapter;
import retrofit.converter.GsonConverter;

@Module(
        injects = NetworkClient.class,
        complete = false
)
public class NetworkModule {

    private static final int API_VERSION = 2;

    public static Gson createGsonForConverter() {
        return new GsonBuilder()
                .setFieldNamingPolicy(FieldNamingPolicy.LOWER_CASE_WITH_UNDERSCORES)
                .registerTypeAdapter(Date.class, new ISODateAdapter())
                .registerTypeHierarchyAdapter(NetworkParam.class,
                        new JsonSerializer<NetworkParam>() {
                            @Override
                            public JsonElement serialize(NetworkParam networkParam, Type type,
                                    JsonSerializationContext jsonSerializationContext) {
                                Gson gson = createGsonForSerialization();
                                JsonElement element = gson.toJsonTree(networkParam, type);
                                JsonObject json = new JsonObject();
                                json.add(networkParam.getRootName(), element);

                                return json;
                            }
                        }
                )
                .registerTypeAdapter(Position.class, new JsonDeserializer<Position>() {
                    @Override
                    public Position deserialize(JsonElement json, Type typeOfT, JsonDeserializationContext context) throws JsonParseException {
                        String abbr = json.getAsString();
                        return Position.getPositionForAbbr(abbr);
                    }
                })
                .registerTypeAdapter(ContestsParams.ContestStatus.class, new JsonSerializer<ContestsParams.ContestStatus>() {
                    @Override
                    public JsonElement serialize(ContestsParams.ContestStatus src, Type typeOfSrc, JsonSerializationContext context) {
                        return new JsonPrimitive(src.toString());
                    }
                })
                .create();
    }

    private static Gson createGsonForSerialization() {
        return new GsonBuilder()
                .setFieldNamingPolicy(FieldNamingPolicy.LOWER_CASE_WITH_UNDERSCORES)
                .registerTypeAdapter(Date.class, new ISODateAdapter())
                .create();
    }

    @Provides
    @Singleton
    NetworkService providesNetworkService(final PreferenceHelper prefs) {
        RestAdapter adapter = new RestAdapter.Builder()
                .setEndpoint(FlavorConstants.ENDPOINT)
                .setLogLevel(BuildConstants.LOG_LEVEL)
                .setConverter(new GsonConverter(createGsonForConverter()))
                .setRequestInterceptor(new RequestInterceptor() {
                    @Override
                    public void intercept(RequestFacade requestFacade) {
                        requestFacade.addHeader("X-API-Version", Integer.toString(API_VERSION));

                        String authToken = prefs.getAuthToken();
                        if (authToken != null) {
                            requestFacade.addHeader("Authorization", "Token token=" + authToken);
                        }
                    }
                })
                .build();

        return adapter.create(NetworkService.class);
    }
}
