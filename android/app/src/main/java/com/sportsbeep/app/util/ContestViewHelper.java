package com.sportsbeep.app.util;

import com.sportsbeep.app.R;
import com.sportsbeep.app.model.game.Game;
import com.sportsbeep.app.model.ticket.Ticket;
import com.sportsbeep.app.ui.view.FontTextView;

import android.content.Context;
import android.view.View;
import android.widget.ProgressBar;

import java.text.NumberFormat;
import java.util.Locale;

import butterknife.ButterKnife;
import butterknife.InjectView;

public class ContestViewHelper {

    public static void populateWithContest(Context context, Ticket ticket, Holder holder) {
        String placement = NumberUtil.decimalToOrdinal(ticket.getPlacing());

        double prizePool = ticket.getPrizePool();
        String prizePoolText = formatCurrency(context, prizePool);

        holder.placementFontTextView.setText(context.getString(R.string.pool_placement, placement, prizePoolText));
        holder.pointsFontTextView.setText(context.getString(R.string.points, ticket.getScore()));
    }

    public static void populateWithGame(Game game, Holder holder) {
        GameViewHelper.populateWithGame(game, holder.gameViewHolder);

        if (holder.progressBar.getVisibility() == View.VISIBLE) {
            AnimUtil.crossfade(holder.progressBar, holder.gameViewHolder.gameLinearLayout);
        }
    }

    public static void showProgress(Holder holder) {
        holder.gameViewHolder.gameLinearLayout.setVisibility(View.INVISIBLE);
        holder.progressBar.setVisibility(View.VISIBLE);
    }

    public static void hideProgress(Holder holder) {
        holder.gameViewHolder.gameLinearLayout.setVisibility(View.VISIBLE);
        holder.progressBar.setVisibility(View.INVISIBLE);
    }

    private static String formatCurrency(Context context, double value) {
        if (value == 0f) {
            return context.getString(R.string.free);
        }

        return NumberFormat.getCurrencyInstance(Locale.US).format(value);
    }

    public static class Holder {

        final GameViewHelper.Holder gameViewHolder;

        @InjectView(R.id.pool_placement_FontTextView)
        FontTextView placementFontTextView;

        @InjectView(R.id.points_FontTextView)
        FontTextView pointsFontTextView;

        @InjectView(R.id.contest_ProgressBar)
        ProgressBar progressBar;

        public Holder(View v) {
            ButterKnife.inject(this, v);
            gameViewHolder = new GameViewHelper.Holder(v);
        }
    }
}
