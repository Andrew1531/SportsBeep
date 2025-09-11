package com.sportsbeep.app.adapter;

import com.sportsbeep.app.R;
import com.sportsbeep.app.enumeration.Level;
import com.sportsbeep.app.enumeration.Sport;
import com.sportsbeep.app.model.game.GamePosition;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.model.ticket.TicketPlayer;
import com.sportsbeep.app.model.ticket.TicketSquad;
import com.sportsbeep.app.module.GraphHolder;
import com.sportsbeep.app.storage.PlayerDaoHelper;
import com.sportsbeep.app.storage.TeamDaoHelper;
import com.sportsbeep.app.task.network.PlayerAsyncTask;
import com.sportsbeep.app.task.network.TeamAsyncTask;
import com.sportsbeep.app.ui.view.FontTextView;
import com.sportsbeep.app.util.PositionViewHelper;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

import java.util.List;

import javax.inject.Inject;

import butterknife.ButterKnife;
import butterknife.InjectView;

public class ScoringBreakdownAdapter extends BaseAdapter {

    private static final int TYPE_PLAYER = 0;

    private static final int TYPE_SQUAD = 1;

    @Inject
    PlayerDaoHelper mPlayerDaoHelper;

    @Inject
    TeamDaoHelper mTeamDaoHelper;

    List<TicketPlayer> mPlayers;

    List<TicketSquad> mSquads;

    Sport mSport;

    Level mLevel;

    public ScoringBreakdownAdapter(List<TicketPlayer> players, List<TicketSquad> squads, Sport sport, Level level) {
        GraphHolder.getInstance().inject(this);
        mPlayers = players;
        mSquads = squads;
        mSport = sport;
        mLevel = level;
    }

    @Override
    public int getCount() {
        return mSport.getGamePositions().length;
    }

    @Override
    public GamePosition getItem(int position) {
        return mSport.getGamePositions()[position];
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public int getViewTypeCount() {
        return 2;
    }

    @Override
    public int getItemViewType(int position) {
        GamePosition gamePosition = getItem(position);
        return gamePosition.isSquad() ? TYPE_SQUAD : TYPE_PLAYER;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        int viewType = getItemViewType(position);
        GamePosition gamePosition = getItem(position);

        if(viewType == TYPE_PLAYER) {
            return getPlayerView(getTicketPlayerForPosition(gamePosition), convertView, parent);
        } else if(viewType == TYPE_SQUAD) {
            return getSquadView(gamePosition, getTicketSquadForPosition(gamePosition), convertView, parent);
        }

        throw new IllegalArgumentException("View type " + viewType + " is not supported.");
    }

    private View getSquadView(GamePosition gamePosition, TicketSquad ticketSquad, View convertView, ViewGroup parent) {
        View v = convertView;
        if(v == null) {
            v = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_ticket_team, parent, false);
            v.setTag(R.id.tag_holder, new SquadHolder(v));
        }

        TeamTask task = (TeamTask) v.getTag(R.id.tag_task);
        if(task != null) {
            task.cancel(true);
            v.setTag(R.id.tag_task, null);
        }

        SquadHolder holder = (SquadHolder) v.getTag(R.id.tag_holder);

        Team team = mTeamDaoHelper.getTeam(ticketSquad.getTeamId());
        if(team == null) {
            task = new TeamTask(holder.positionViewHelperHolder, mSport, mLevel);
            task.execute(ticketSquad.getTeamId());
            v.setTag(R.id.tag_task, task);
        } else {
            Context context = parent.getContext();
            PositionViewHelper.populateWithTeam(holder.positionViewHelperHolder, team, team.getName() + " " + gamePosition.getTitle(context));
        }

        holder.teamPointsFontTextView.setText(ticketSquad.getScore());

        return v;
    }

    private View getPlayerView(TicketPlayer ticketPlayer, View convertView, ViewGroup parent) {
        View v = convertView;
        if (v == null) {
            v = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_ticket_player, parent, false);
            v.setTag(R.id.tag_holder, new PlayerHolder(v));
        }

        PlayerTask task = (PlayerTask) v.getTag(R.id.tag_task);
        if (task != null) {
            task.cancel(false);
            v.setTag(R.id.tag_task, null);
        }

        PlayerHolder holder = (PlayerHolder) v.getTag(R.id.tag_holder);

        Player player = mPlayerDaoHelper.getPlayer(ticketPlayer.getPlayerId());
        if (player == null) {
            task = new PlayerTask(holder.positionViewHelperHolder, mSport, mLevel);
            task.execute(ticketPlayer.getPlayerId());
            v.setTag(R.id.tag_task, task);
        } else {
            PositionViewHelper.populateWithPlayer(holder.positionViewHelperHolder, player);
        }

        holder.playerPointsFontTextView.setText(ticketPlayer.getScore());
        holder.positionFontTextView.setText(ticketPlayer.getPosition());

        return v;
    }

    private TicketPlayer getTicketPlayerForPosition(GamePosition position) {
        for (TicketPlayer ticketPlayer : mPlayers) {
            if (position.getPositionGroupTitleResName().equals(ticketPlayer.getGamePosition())) {
                return ticketPlayer;
            }
        }

        return null;
    }

    private TicketSquad getTicketSquadForPosition(GamePosition position) {
        for(TicketSquad ticketSquad : mSquads) {
            if(position.getPositionGroupTitleResName().equals(ticketSquad.getGamePosition())) {
                return ticketSquad;
            }
        }

        return null;
    }

    public class PlayerTask extends PlayerAsyncTask {

        PositionViewHelper.Holder mHolder;

        public PlayerTask(PositionViewHelper.Holder holder, Sport sport, Level level) {
            super(sport, level);
            mHolder = holder;
        }

        @Override
        protected void onSuccess(Player player) {
            super.onSuccess(player);
            PositionViewHelper.populateWithPlayer(mHolder, player);
        }
    }

    public class TeamTask extends TeamAsyncTask {

        PositionViewHelper.Holder mHolder;

        public TeamTask(PositionViewHelper.Holder holder, Sport sport, Level level) {
            super(sport, level);
            mHolder = holder;
        }

        @Override
        protected void onSuccess(Team team) {
            super.onSuccess(team);
            PositionViewHelper.populateWithTeam(mHolder, team);
        }
    }

    class PlayerHolder {

        PositionViewHelper.Holder positionViewHelperHolder;

        @InjectView(R.id.playerPoints_FontTextView)
        FontTextView playerPointsFontTextView;

        @InjectView(R.id.position_FontTextView)
        FontTextView positionFontTextView;

        public PlayerHolder(View v) {
            positionViewHelperHolder = new PositionViewHelper.Holder(v);
            ButterKnife.inject(this, v);
        }
    }

    class SquadHolder {

        PositionViewHelper.Holder positionViewHelperHolder;

        @InjectView(R.id.teamPoints_FontTextView)
        FontTextView teamPointsFontTextView;

        public SquadHolder(View v) {
            positionViewHelperHolder = new PositionViewHelper.Holder(v);
            ButterKnife.inject(this, v);
        }
    }
}
