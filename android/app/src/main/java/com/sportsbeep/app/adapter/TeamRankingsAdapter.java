package com.sportsbeep.app.adapter;

import com.sportsbeep.app.R;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.model.team.TeamRanking;
import com.sportsbeep.app.ui.view.FontTextView;
import com.sportsbeep.app.util.NumberUtil;

import android.content.Context;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.RelativeSizeSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;

import java.util.List;

import butterknife.ButterKnife;
import butterknife.InjectView;

public class TeamRankingsAdapter extends ArrayAdapter<TeamRanking> {

    Team mTeam;

    public TeamRankingsAdapter(Context context, Team team, List<TeamRanking> objects) {
        super(context, 0, objects);
        mTeam = team;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view = convertView;
        if (view == null) {
            view = LayoutInflater.from(getContext()).inflate(R.layout.item_team_ranking, parent, false);

            Holder holder = new Holder(view);
            holder.nameFontTextView.setBackgroundColor(mTeam.getPrimaryColor());
            holder.nameFontTextView.setTextColor(mTeam.getSecondaryColor());
            holder.rankingFontTextView.setTextColor(mTeam.getSecondaryColor());
            holder.valueFontTextView.setTextColor(mTeam.getSecondaryColor());

            view.setTag(holder);
        }

        Holder holder = (Holder) view.getTag();
        TeamRanking ranking = getItem(position);

        holder.nameFontTextView.setText(ranking.getName());

        SpannableString rank = new SpannableString(NumberUtil.decimalToOrdinal(ranking.getRank()));
        rank.setSpan(new RelativeSizeSpan(0.5f), rank.length() - 2, rank.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        holder.rankingFontTextView.setText(rank);

        holder.valueFontTextView.setText(ranking.getValue());

        return view;
    }

    @Override
    public boolean isEnabled(int position) {
        return false;
    }

    public static class Holder {

        @InjectView(R.id.name_FontTextView)
        FontTextView nameFontTextView;

        @InjectView(R.id.ranking_FontTextView)
        FontTextView rankingFontTextView;

        @InjectView(R.id.value_FontTextView)
        FontTextView valueFontTextView;

        public Holder(View v) {
            ButterKnife.inject(this, v);
        }
    }
}
