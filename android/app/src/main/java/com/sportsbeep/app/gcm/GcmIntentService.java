package com.sportsbeep.app.gcm;

import com.google.android.gms.gcm.GoogleCloudMessaging;

import com.sportsbeep.app.R;
import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.module.GraphHolder;
import com.sportsbeep.app.network.params.ContestsParams;
import com.sportsbeep.app.storage.GameDaoHelper;
import com.sportsbeep.app.storage.PreferenceHelper;
import com.sportsbeep.app.ui.contest.ContestDetailsActivity;
import com.sportsbeep.app.ui.game.buildteam.BuildTeamActivity;
import com.sportsbeep.app.util.NumberUtil;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.IntentService;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.NotificationCompat;

public class GcmIntentService extends IntentService {

    private static final String EXTRA_TYPE = "type";

    private static final String EXTRA_CONTEST_ID = "contest";

    private static final String EXTRA_TICKET_ID = "ticket";

    private static final String EXTRA_GAME_ID = "game";

    private static final String EXTRA_PLACING = "placing";

    private static final String EXTRA_PLAYER = "player";

    private static final String EXTRA_PLAYER_ID = "id";

    private static final String EXTRA_PLAYER_NAME = "name";

    private static final String EXTRA_SPORT = "sport";

    private static final String TYPE_PLACEMENT = "placement";

    private static final String TYPE_INJURY = "injury";

    private static final String SPORT_MLB = "mlb";

    private static final String SPORT_NFL = "nfl";

    public GcmIntentService() {
        super("GcmIntentService");
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        Bundle extras = intent.getExtras();
        GoogleCloudMessaging gcm = GoogleCloudMessaging.getInstance(this);
        String messageType = gcm.getMessageType(intent);

        if (!extras.isEmpty()) {
            if (GoogleCloudMessaging.MESSAGE_TYPE_MESSAGE.equals(messageType)) {
                String sport = intent.getStringExtra(EXTRA_SPORT);
                changeSport(sport);

                String type = intent.getStringExtra(EXTRA_TYPE);
                if (TYPE_PLACEMENT.equals(type)) {
                    long gameId = Long.parseLong(extras.getString(EXTRA_GAME_ID));
                    long contestId = Long.parseLong(extras.getString(EXTRA_CONTEST_ID));
                    long ticketId = Long.parseLong(extras.getString(EXTRA_TICKET_ID));
                    int placement = Integer.parseInt(extras.getString(EXTRA_PLACING));

                    sendContestNotification(contestId, ticketId, gameId, placement);
                } else if (TYPE_INJURY.equals(type)) {
                    long gameId = Long.parseLong(extras.getString(EXTRA_GAME_ID));
                    long ticketId = Long.parseLong(extras.getString(EXTRA_TICKET_ID));

                    long playerId;
                    String playerName;
                    try {
                        JSONObject json = new JSONObject(extras.getString(EXTRA_PLAYER));
                        playerId = json.getLong(EXTRA_PLAYER_ID);
                        playerName = json.getString(EXTRA_PLAYER_NAME);
                    } catch (JSONException e) {
                        throw new RuntimeException(e);
                    }

                    sendInjuryNotification(gameId, ticketId, playerId, playerName);
                }
            }
        }

        GcmBroadcastReceiver.completeWakefulIntent(intent);
    }

    private void changeSport(String sportText) {
        Sport sport;
        Level level;
        if (SPORT_MLB.equals(sportText)) {
            sport = Sport.BASEBALL;
            level = Level.PROFESSIONAL;
        } else if (SPORT_NFL.equals(sportText)) {
            sport = Sport.FOOTBALL;
            level = Level.PROFESSIONAL;
        } else {
            throw new IllegalArgumentException("Sport '" + sportText + "' is not supported.");
        }

        PreferenceHelper helper = GraphHolder.getInstance().get(PreferenceHelper.class);
        helper.setSport(sport);
        helper.setLevel(level);
    }

    private void sendContestNotification(long contestId, long ticketId, long gameId, int placing) {
        Intent intent = new Intent(this, ContestDetailsActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra(ContestDetailsActivity.EXTRA_CONTEST_ID, contestId);
        intent.putExtra(ContestDetailsActivity.EXTRA_TICKET_ID, ticketId);
        intent.putExtra(ContestDetailsActivity.EXTRA_GAME_ID, gameId);
        intent.putExtra(ContestDetailsActivity.EXTRA_CONTEST_STATUS, ContestsParams.ContestStatus.PAST);

        PendingIntent contentIntent = PendingIntent.getActivity(this, (int) contestId, intent, PendingIntent.FLAG_UPDATE_CURRENT);
        String message = getString(R.string.contest_push_msg, NumberUtil.decimalToOrdinal(placing));

        long notificationId = 100000 + contestId * 100 + ticketId * 10 + gameId;

        sendNotification(contentIntent, message, (int) notificationId);
    }

    private void sendInjuryNotification(long gameId, long ticketId, long playerId, String playerName) {
        Intent intent = new Intent(this, BuildTeamActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

        GameDaoHelper gameDaoHelper = GraphHolder.getInstance().get(GameDaoHelper.class);
        Game game = gameDaoHelper.getGame(gameId);
        if (game == null) {
            game = new Game();
            game.setId(gameId);
        }

        intent.putExtra(BuildTeamActivity.EXTRA_GAME, game);
        intent.putExtra(BuildTeamActivity.EXTRA_TICKET_ID, ticketId);
        PendingIntent contentIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_ONE_SHOT);
        String message = getString(R.string.disabled_push_message, playerName);

        long notificationId = gameId * 100 + ticketId * 10 + playerId;

        sendNotification(contentIntent, message, (int) notificationId);
    }

    private void sendNotification(PendingIntent contentIntent, String message, int notificationId) {
        NotificationManager notificationManager = (NotificationManager)
                this.getSystemService(Context.NOTIFICATION_SERVICE);

        NotificationCompat.Builder mBuilder =
                new NotificationCompat.Builder(this)
                        .setSmallIcon(R.mipmap.ic_launcher)
                        .setContentTitle(getString(R.string.app_name))
                        .setStyle(new NotificationCompat.BigTextStyle().bigText(message))
                        .setContentText(message)
                        .setAutoCancel(true)
                        .setDefaults(Notification.DEFAULT_ALL);

        mBuilder.setContentIntent(contentIntent);
        notificationManager.notify(notificationId, mBuilder.build());
    }
}
