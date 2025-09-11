package com.sportsbeep.app.adapter;

import com.sportsbeep.app.R;
import com.sportsbeep.app.model.ticket.Scoresheet;
import com.sportsbeep.app.model.ticket.TicketPlayer;
import com.sportsbeep.app.ui.view.FontTextView;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import java.util.List;

import butterknife.ButterKnife;
import butterknife.InjectView;

public class PlayerScoringAdapter extends ArrayAdapter<Scoresheet.TicketStat> {

    public PlayerScoringAdapter(Context context, List<Scoresheet.TicketStat> objects) {
        super(context, 0, objects);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view = convertView;
        if (view == null) {
            view = LayoutInflater.from(getContext()).inflate(R.layout.item_score_stat, parent, false);
            view.setTag(new Holder(view));
        }

        Scoresheet.TicketStat stat = getItem(position);
        Holder holder = (Holder) view.getTag();

        holder.statFontTextView.setText(stat.getName());
        holder.amountFontTextView.setText(stat.getAmount());
        holder.pointsFontTextView.setText(stat.getPointsPer());
        holder.totalFontTextView.setText(stat.getPoints());

        return view;
    }

    @Override
    public boolean isEnabled(int position) {
        // makes list items unclickable
        return false;
    }

    class Holder {

        @InjectView(R.id.stat_FontTextView)
        FontTextView statFontTextView;

        @InjectView(R.id.amount_FontTextView)
        FontTextView amountFontTextView;

        @InjectView(R.id.points_FontTextView)
        FontTextView pointsFontTextView;

        @InjectView(R.id.total_FontTextView)
        FontTextView totalFontTextView;

        public Holder(View v) {
            ButterKnife.inject(this, v);
        }
    }
}
