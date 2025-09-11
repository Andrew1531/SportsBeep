package com.sportsbeep.app.adapter;

import com.sportsbeep.app.R;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.util.GameViewHelper;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import java.util.List;

public class GamesAdapter extends ArrayAdapter<Game> {

    private final int mLayoutResId;

    private final OnTeamClickListener mOnTeamClickListener;

    public GamesAdapter(Context context, boolean useBigView, List<Game> games) {
        this(context, useBigView, games, null);
    }

    public GamesAdapter(Context context, boolean useBigView, List<Game> games,
            OnTeamClickListener onTeamClickListener) {
        super(context, 0, games);
        mOnTeamClickListener = onTeamClickListener;
        mLayoutResId = useBigView ? R.layout.item_game_big : R.layout.item_game;
    }

    @Override
    public long getItemId(int position) {
        return getItem(position).getId();
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View v = convertView;
        if (v == null) {
            v = LayoutInflater.from(parent.getContext()).inflate(mLayoutResId, parent, false);
            v.setTag(new GameViewHelper.Holder(v));
        }

        final Game game = getItem(position);
        GameViewHelper.Holder holder = (GameViewHelper.Holder) v.getTag();

        GameViewHelper.populateWithGame(game, holder);

        if (mOnTeamClickListener != null) {
            holder.splitColorRelativeLayout.setOnTopLeftClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mOnTeamClickListener.onTeamClicked(game, game.getAwayTeam());
                }
            });
            holder.splitColorRelativeLayout.setOnTopLeftLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    mOnTeamClickListener.onTeamLongClicked(game, game.getAwayTeam());
                    return true;
                }
            });
            holder.splitColorRelativeLayout.setOnBottomRightClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mOnTeamClickListener.onTeamClicked(game, game.getHomeTeam());
                }
            });
            holder.splitColorRelativeLayout.setOnBottomRightLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    mOnTeamClickListener.onTeamLongClicked(game, game.getHomeTeam());
                    return true;
                }
            });
        }

        return v;
    }

    public interface OnTeamClickListener {

        public void onTeamClicked(Game game, Team team);

        public void onTeamLongClicked(Game game, Team team);
    }
}
