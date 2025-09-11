package com.sportsbeep.app.adapter;

import com.sportsbeep.app.R;
import com.sportsbeep.app.model.game.GamePosition;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.model.player.stats.Stats;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.module.GraphHolder;
import com.sportsbeep.app.storage.StatsDaoHelper;
import com.sportsbeep.app.ui.view.FontTextView;
import com.sportsbeep.app.util.PositionViewHelper;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.inject.Inject;

public class PositionsAdapter extends ArrayAdapter<GamePosition> {

    private static final int TYPE_GAME_POSITION = 0;

    private static final int TYPE_PLAYER = 1;

    private static final int TYPE_TEAM = 2;

    @Inject
    StatsDaoHelper mStatsDaoHelper;

    private Map<GamePosition, Object> mPositionMap;

    private Team mLeaguePickTeam;

    public PositionsAdapter(Context context, List<GamePosition> gamePositions) {
        super(context, 0, gamePositions);
        mPositionMap = new HashMap<GamePosition, Object>();
        GraphHolder.getInstance().inject(this);
    }

    @Override
    public int getViewTypeCount() {
        return 3;
    }

    @Override
    public int getItemViewType(int position) {
        GamePosition gamePosition = getItem(position);
        Object value;
        if (GamePosition.LEAGUE_PICK.equals(gamePosition)) {
            value = mLeaguePickTeam;
        } else {
            value = mPositionMap.get(gamePosition);
        }

        if (value != null) {
            if (value instanceof Player) {
                return TYPE_PLAYER;
            } else if (value instanceof Team) {
                return TYPE_TEAM;
            }
        }

        return TYPE_GAME_POSITION;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view = convertView;
        if (view == null) {
            view = newView(position, parent);
        }

        populateView(position, view);

        return view;
    }

    private void populateView(int position, View view) {
        GamePosition gamePosition = getItem(position);

        PositionViewHelper.Holder holder;
        int itemViewType = getItemViewType(position);
        switch (itemViewType) {
            case TYPE_GAME_POSITION:
                ((FontTextView) view).setText(gamePosition.getPositionGroupTitle(getContext()));
                break;
            case TYPE_PLAYER:
                Player player = (Player) mPositionMap.get(gamePosition);
                List<? extends Stats.Stat> summaryStats = mStatsDaoHelper.getStatsForSummary(player.getId());
                holder = (PositionViewHelper.Holder) view.getTag();
                PositionViewHelper.populateWithPlayer(holder, player, summaryStats);
                break;
            case TYPE_TEAM:
                holder = (PositionViewHelper.Holder) view.getTag();
                Team team;
                if (GamePosition.LEAGUE_PICK.equals(gamePosition)) {
                    team = mLeaguePickTeam;
                } else {
                    team = (Team) mPositionMap.get(gamePosition);
                }

                if (TextUtils.isEmpty(gamePosition.getTitleResName())) {
                    PositionViewHelper.populateWithTeam(holder, team);
                } else {
                    PositionViewHelper.populateWithTeam(holder, team, team.getName() + " " + gamePosition.getTitle(getContext()));
                }
                break;
        }
    }

    private View newView(int position, ViewGroup parent) {
        View view = null;
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());

        int itemViewType = getItemViewType(position);
        switch (itemViewType) {
            case TYPE_GAME_POSITION:
                view = inflater.inflate(R.layout.item_simple, parent, false);
                break;
            case TYPE_PLAYER:
                view = inflater.inflate(R.layout.item_player, parent, false);
                view.setTag(new PositionViewHelper.Holder(view));
                break;
            case TYPE_TEAM:
                view = inflater.inflate(R.layout.item_team, parent, false);
                view.setTag(new PositionViewHelper.Holder(view));
                break;
        }

        return view;
    }

    public void setPosition(GamePosition gamePosition, Player player) {
        mPositionMap.put(gamePosition, player);
        notifyDataSetChanged();
    }

    public void setPosition(GamePosition gamePosition, Team team) {
        if (GamePosition.LEAGUE_PICK.equals(gamePosition)) {
            mLeaguePickTeam = team;
        } else {
            mPositionMap.put(gamePosition, team);
        }

        notifyDataSetChanged();
    }

    public void setPositionMap(Map<GamePosition, Object> positionMap) {
        mPositionMap = new HashMap<GamePosition, Object>(positionMap);
        notifyDataSetChanged();
    }
}
