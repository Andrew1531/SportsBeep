package com.sportsbeep.app.util;

import com.sportsbeep.app.R;
import com.sportsbeep.app.model.player.Player;
import com.sportsbeep.app.model.player.stats.Stats;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.ui.view.FontTextView;

import android.content.Context;
import android.graphics.Color;
import android.view.View;
import android.widget.LinearLayout;

import java.util.List;

import butterknife.ButterKnife;
import butterknife.InjectView;
import butterknife.Optional;

public class PositionViewHelper {

    private PositionViewHelper() {

    }

    public static void populateWithPlayer(Holder holder, Player player) {
        populateWithPlayer(holder, player, null);
    }

    public static void populateWithPlayer(Holder holder, Player player, List<? extends Stats.Stat> stats) {
        int primaryColor;
        int secondaryColor;
        String abbr;
        if (player.getTeam() != null) {
            primaryColor = player.getTeam().getPrimaryColor();
            secondaryColor = player.getTeam().getSecondaryColor();
            abbr = player.getTeam().getAbbr();
        } else {
            primaryColor = Color.WHITE;
            secondaryColor = Color.BLACK;
            abbr = " ";
        }
        applyTeamColors(holder, primaryColor, secondaryColor);
        holder.abbrFontTextView.setText(abbr);

        holder.numberFontTextView.setText(Integer.toString(player.getNumber()));
        holder.nameFontTextView.setText(player.getName());

        if (holder.positionFontTextView != null) {
            holder.positionFontTextView.setText(player.getPosition().getAbbreviation());
        }

        if (stats != null && holder.statView != null) {
            StringBuilder sb = new StringBuilder();
            for (Stats.Stat stat : stats) {
                if (sb.length() != 0) {
                    sb.append("  ");
                }
                sb.append(stat.getAbbr() + " " + stat.getAmount());
            }

            holder.statView.setText(sb);
        }
    }

    public static void populateWithTeam(Holder holder, Team team) {
        populateWithTeam(holder, team, team.toString());
    }

    public static void populateWithTeam(Holder holder, Team team, String text) {
        applyTeamColors(holder, team.getPrimaryColor(), team.getSecondaryColor());

        holder.abbrFontTextView.setText(team.getAbbr());
        holder.nameFontTextView.setText(text);

        if (holder.statView != null) {
            Context context = holder.playerLinearLayout.getContext();
            holder.statView.setText(context.getString(R.string.wins_losses_stat, team.getWins(), team.getLosses()));
        }
    }

    private static void applyTeamColors(Holder holder, int primary, int secondary) {

        holder.playerLinearLayout.setBackgroundColor(primary);
        if (holder.numberFontTextView != null) {
            holder.numberFontTextView.setTextColor(secondary);
        }
        holder.abbrFontTextView.setTextColor(secondary);
        holder.nameFontTextView.setTextColor(secondary);
        if (holder.positionFontTextView != null) {
            holder.positionFontTextView.setTextColor(secondary);
        }

        if(holder.statView != null) {
            holder.statView.setTextColor(secondary);
        }
    }

    public static class Holder {

        @InjectView(R.id.player_LinearLayout)
        LinearLayout playerLinearLayout;

        @Optional
        @InjectView(R.id.number_FontTextView)
        FontTextView numberFontTextView;

        @InjectView(R.id.abbr_FontTextView)
        FontTextView abbrFontTextView;

        @InjectView(R.id.name_FontTextView)
        FontTextView nameFontTextView;

        @Optional
        @InjectView(R.id.position_FontTextView)
        FontTextView positionFontTextView;

        @Optional
        @InjectView(R.id.stat_FontTextView)
        FontTextView statView;

        public Holder(View view) {
            ButterKnife.inject(this, view);
        }
    }
}
