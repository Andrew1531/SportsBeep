package com.sportsbeep.app.adapter;

import com.sportsbeep.app.R;
import com.sportsbeep.app.model.ticket.IncompleteTicket;
import com.sportsbeep.app.util.GameViewHelper;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import java.util.List;

import butterknife.ButterKnife;

public class IncompleteContestAdapter extends ArrayAdapter<IncompleteTicket> {

    public IncompleteContestAdapter(Context context, List<IncompleteTicket> objects) {
        super(context, 0, objects);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View v = convertView;
        if (v == null) {
            v = LayoutInflater.from(getContext()).inflate(R.layout.item_incomplete_contest, parent, false);
            v.setTag(new Holder(v));
        }

        IncompleteTicket ticket = getItem(position);
        Holder holder = (Holder) v.getTag();
        GameViewHelper.populateWithGame(ticket.getGame(), holder.gameViewHolder);

        return v;
    }

    class Holder {

        final GameViewHelper.Holder gameViewHolder;

        public Holder(View v) {
            ButterKnife.inject(this, v);
            gameViewHolder = new GameViewHelper.Holder(v);
        }
    }
}
