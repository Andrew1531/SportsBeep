package com.sportsbeep.app.adapter;

import com.sportsbeep.app.R;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.model.player.stats.Stats;
import com.sportsbeep.app.module.GraphHolder;
import com.sportsbeep.app.storage.StatsDaoHelper;
import com.sportsbeep.app.util.PositionViewHelper;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import java.util.List;

import javax.inject.Inject;

public class PlayersAdapter extends ArrayAdapter<Player> {

    @Inject
    StatsDaoHelper mStatsDaoHelper;

    public PlayersAdapter(Context context, List<Player> players) {
        super(context, 0, players);
        GraphHolder.getInstance().inject(this);
    }

    @Override
    public long getItemId(int position) {
        return getItem(position).getId();
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        Context context = getContext();
        View view = convertView;
        if (view == null) {
            view = LayoutInflater.from(context).inflate(R.layout.item_player, parent, false);
            view.setTag(new PositionViewHelper.Holder(view));
        }

        Player player = getItem(position);
        List<? extends Stats.Stat> summaryStats = mStatsDaoHelper.getStatsForSummary(player.getId());

        PositionViewHelper.Holder holder = (PositionViewHelper.Holder) view.getTag();
        PositionViewHelper.populateWithPlayer(holder, player, summaryStats);

        return view;
    }
}
