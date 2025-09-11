package com.sportsbeep.app.util;

import com.sportsbeep.app.R;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.team.Team;
import com.sportsbeep.app.ui.view.FontTextView;
import com.sportsbeep.app.ui.view.SplitColorRelativeLayout;

import android.view.View;
import android.widget.LinearLayout;

import butterknife.ButterKnife;
import butterknife.InjectView;

public class GameViewHelper {

    public GameViewHelper() {

    }

    public static void populateWithGame(Game game, View v) {
        populateWithGame(game, new Holder(v), null);
    }

    public static void populateWithGame(Game game, View v, final OnTeamClickedListener listener) {
        populateWithGame(game, new Holder(v), listener);
    }

    public static void populateWithGame(Game game, Holder holder) {
        populateWithGame(game, holder, null);
    }

    public static void populateWithGame(Game game, Holder holder, final OnTeamClickedListener listener) {
        if (game.getStartTime() != null) {
            holder.dateTextView.setText(DateFormatUtils.getDateFormat().format(game.getStartTime()));
            holder.timeTextView.setText(DateFormatUtils.getTimeFormat().format(game.getStartTime()));
        }

        if (game.getHomeTeam() != null) {
            holder.splitColorRelativeLayout.setBottomRightBackgroundColor(game.getHomeTeam().getPrimaryColor());
            holder.teamMarket2TextView.setText(game.getHomeTeam().getMarket());
            holder.teamMarket2TextView.setTextColor(game.getHomeTeam().getSecondaryColor());
            holder.teamName2TextView.setText(game.getHomeTeam().getName());
            holder.teamName2TextView.setTextColor(game.getHomeTeam().getSecondaryColor());
        }

        if (game.getAwayTeam() != null) {
            holder.splitColorRelativeLayout.setTopLeftBackgroundColor(game.getAwayTeam().getPrimaryColor());
            holder.teamMarket1TextView.setText(game.getAwayTeam().getMarket());
            holder.teamMarket1TextView.setTextColor(game.getAwayTeam().getSecondaryColor());
            holder.teamName1TextView.setText(game.getAwayTeam().getName());
            holder.teamName1TextView.setTextColor(game.getAwayTeam().getSecondaryColor());
        }

        if (listener != null) {
            final Team homeTeam = game.getHomeTeam();
            final Team awayTeam = game.getAwayTeam();
            holder.splitColorRelativeLayout.setOnTopLeftClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    listener.onTeamClicked(awayTeam);
                }
            });
            holder.splitColorRelativeLayout.setOnTopLeftLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    listener.onTeamLongClicked(awayTeam);
                    return true;
                }
            });
            holder.splitColorRelativeLayout.setOnBottomRightClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    listener.onTeamClicked(homeTeam);
                }
            });
            holder.splitColorRelativeLayout.setOnBottomRightLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    listener.onTeamLongClicked(homeTeam);
                    return true;
                }
            });
        }
    }

    public interface OnTeamClickedListener {

        public void onTeamClicked(Team team);

        public void onTeamLongClicked(Team team);
    }

    public static class Holder {

        @InjectView(R.id.game_LinearLayout)
        public LinearLayout gameLinearLayout;

        @InjectView(R.id.parent_SplitColorRelativeLayout)
        public SplitColorRelativeLayout splitColorRelativeLayout;

        @InjectView(R.id.date_FontTextView)
        public FontTextView dateTextView;

        @InjectView(R.id.time_FontTextView)
        public FontTextView timeTextView;

        @InjectView(R.id.teamMarket1_FontTextView)
        public FontTextView teamMarket1TextView;

        @InjectView(R.id.teamName1_FontTextView)
        public FontTextView teamName1TextView;

        @InjectView(R.id.teamMarket2_FontTextView)
        public FontTextView teamMarket2TextView;

        @InjectView(R.id.teamName2_FontTextView)
        public FontTextView teamName2TextView;

        public Holder(View v) {
            ButterKnife.inject(this, v);
        }
    }
}
